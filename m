From: Brian Allen Vanderburg II <brianvanderburg2@aim.com>
Subject: iproute2/vlan: Idea: Support untagged VLAN interfaces
Date: Wed, 02 Apr 2014 07:54:38 -0400
Message-ID: <533BFA7E.9020001@aim.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="pboJxaMPccpRFfUQQRC3QmNedDwJhGV9j"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from omr-m10.mx.aol.com ([64.12.143.86]:38106 "EHLO
	omr-m10.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758426AbaDBLwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 07:52:42 -0400
Received: from mtaout-mab01.mx.aol.com (mtaout-mab01.mx.aol.com [172.26.249.81])
	by omr-m10.mx.aol.com (Outbound Mail Relay) with ESMTP id 9765470242A5D
	for <netdev@vger.kernel.org>; Wed,  2 Apr 2014 07:52:41 -0400 (EDT)
Received: from [192.168.1.109] (cpe-069-132-214-147.carolina.res.rr.com [69.132.214.147])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mtaout-mab01.mx.aol.com (MUA/Third Party Client Interface) with ESMTPSA id 62A6A380000B1
	for <netdev@vger.kernel.org>; Wed,  2 Apr 2014 07:52:41 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--pboJxaMPccpRFfUQQRC3QmNedDwJhGV9j
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I've been recent playing around with some of the new VLAN filtering
features.  One feature I want to be able to do is to create an interface
that handles untagged data for VLANs as a sub-interface instead.=20
Currently, untagged data is only handled by the main interface.  I can
think of some reasons to have untagged data on its own VLAN interface.

* The ability to bring up and down the untagged interface without
affecting all tagged interfaces as well.
* The ability to bridge only untagged traffic for mapping/translating.=20
If an untagged sub-interface exists, then VLAN mapping can be performed
by bridging the VLAN interfaces of two NICs with differing VLANs and
including the untagged traffic.  Without untagged VLAN sub-interfaces
only tagged traffic could be mapped.  The bridge VLAN filtering allows
filtering of VLANs per port, but does not seem to allow mapping or
translating VLANs.
* Misc

The bridge VLAN filtering feature seems to make it possible, but
requires a rather large amount of configuration.  This first section
will take any traffic on eth0 and pass it in to br0.  VLAN 1 is untagged
on eth0, but is treated as tagged as it passes to br0.

    ip link add dev br0 type bridge
    ip link set dev eth0 master br0
    ip link set dev eth0 promisc on
    echo 1 > /sys/class/net/br0/bridge/vlan_filtering

    bridge vlan add dev eth0 vid 1 pvid untagged
    bridge vlan add dev eth0 vid 10
    bridge vlan add dev eth0 vid 99

    bridge vlan add dev br0 vid 1 self
    bridge vlan add dev br0 vid 10 self
    bridge vlan add dev br0 vid 99 self

Because br0 sees even the original untagged traffic as tagged, I can now
add a separate interface for the untagged VLAN as desired:

    ip link add link br0 name br0_user type vlan id 1
    ip link add link br0 name br0_priv type vlan id 10
    ip link add link br0 name br0_mgmt type vlan id 99

The interfaces can then be configured as normal.  I can bring down any
interface and it will not affect the others, or do anything else.  I
have managed to confirm this seems to work fine in a VM where untagged
traffic on eth0 was received on br0_user as expected.

This is a bit of work to get a "sub-interface" for an untagged VLAN.=20
One idea I had was that if the groundwork already exists, it may be
possible to add something similar directly to the interface without the
bridge and VLAN filtering setup.  I could imagine a command such as

    ip link add link eth0 name eth0_user type vlan id 1 pvid untagged

as being able to accomplish the same thing without the overhead of
creating a bridge and assigning all the VLANs to both the physical
device and bridge device.


--pboJxaMPccpRFfUQQRC3QmNedDwJhGV9j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJTO/qCAAoJEOdzerRR63OMEPEQAIIdhdmBJLm3kZR5JuijmB1R
0b4rdnYuwzROsPF2LNJwYqtOhnRERPsa4vBkQIQZ4DF7jNBS0+B9PO+ScYpq1GVt
8VCXiHuEd5OH0ByyBv1Up/HF7/2UHor617ZGCh0c3ldSxz4MVxbFw9EOXW2p+Vsy
4ntSR6VZrjt5DGOb/u7wI5f9SliVkE4Zy1Yg1TFOFNvh/qb9HnR+jaXNjr8KMyWQ
Q+B7GuJxdnFIA0FJF3tDNcjSGw4VVAEvOlxwXMB1UQsp6dOpOHSErGbQadHVozmx
fqmOiqoEyDQnD9fQm1eI28R7bYCFtcMIMISFwKz5SqOAH5OcENqBeFUjW7/65HW0
fp/9LT9OcwbhmJlviy8MFdeUioZcJ7FJmN4m5WL94ap9GmVYS4wS5UPIt+9q88bd
aAXdVDV7N80uFhY/KxTKh34tmb2H1MMyHvDICvvEyGY1LFBiiTFWeALAtHrwFivM
ttoG2KbLmkMWe35Ci0eVsBZYqWjNETiXRwuoeafObQ5NIV+qr69Wr/e6UU57cPBm
vuKWJi1MFgUpVOjRkwze+Q7rDHOFUrFpv8ZmbwkqBee04KDDiqeTfrTOys+o2DWI
qQSPyQHq6k8JCgHutXUFaxG5t0tMnImlDdlWE5qrOh04BVxTxyeJGSEK1AOtPpXH
BROqkrmZrcfDkinj4Pa6
=Rh3W
-----END PGP SIGNATURE-----

--pboJxaMPccpRFfUQQRC3QmNedDwJhGV9j--
