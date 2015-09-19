From: Matthew Monaco <Matthew.Monaco@Colorado.EDU>
Subject: sr-iov and bridges (mlx4)
Date: Sat, 19 Sep 2015 17:58:23 -0600
Message-ID: <55FDF69F.6000105@colorado.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Q5kWemDN8KPFknIxPkQH5McRh9sXjmq9q"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33417 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbbISX63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 19:58:29 -0400
Received: by iofh134 with SMTP id h134so89311130iof.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 16:58:29 -0700 (PDT)
Received: from joshua.monaco.cx (c-67-176-93-83.hsd1.co.comcast.net. [67.176.93.83])
        by smtp.gmail.com with ESMTPSA id v98sm7009779ioi.24.2015.09.19.16.58.27
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 16:58:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Q5kWemDN8KPFknIxPkQH5McRh9sXjmq9q
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello. I have a Mellanox ConnectX-3 Pro EN (MCX314A-BCCT). I'm only using=
 a
single port so it must provide IP for my host as well as connectivity for=
 VMs.
SR-IOV VFs are working great, my KVM VMs have Ethernet and RDMA.

However, I also want to support virtio VMs. Assuming eth0 is the first po=
rt on
my mlx nic, I've tried placing VMs on a bridge with the primary physical
interface, and giving an IP for management to a VF:

br0
|--- eth0
|--- VM
|--- VM
vf0 (IP)
vf1 -> VM
vf2 -> VM
vf3 -> VM

I've tried placing VMs on a bridge with one of the VFs and using the prim=
ary
iface for IP.

eth0 (IP)
br0
|--- vf0
|--- VM
|--- VM
vf1 -> VM
vf2 -> VM
vf3 -> VM

And I've also tried using a veth pair to really spread things out:

br0 (IP)
|--- eth0
|--- veth-a
br1       |
|--- veth-b
|--- VM
|--- VM
vf1 -> VM
vf2 -> VM
vf3 -> VM

In all cases, VMs with SR-IOV work fine, IP on the host works fine, outbo=
und
DHCP from the virtio VMs work fine, but inbound frames are not making it =
back to
the VM.

Is there a know limitation of mixing SR-IOV and bridges in general? Does =
the
SR-IOV switch specific to the mlx4 hardware not work well with linux brid=
ges? ...?

Thanks!
Matt


--Q5kWemDN8KPFknIxPkQH5McRh9sXjmq9q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCgAGBQJV/fafAAoJEAi+uryZEuPokVsIAIBbzxPt9ax5XgOVZjPBqa2V
zjLZXp7n5YFOMM0TaOuRSEMqFXk3k5CP9Dqgk2YOpebfiTTcPnKBeErEGhChfm9h
tCfrnSwaMkI2LOe4qMZOXPkBPOWF7AavKO+j+zMMxtO0vVbyfIcDPAigUB0oFDlz
/cHb/kkzIBhdr2pBmDPHq+asfWdQ5m7aXT+mWOUiHfUfauf9pLoWeO8DjKmeUUR+
Uo3ZuGJONsLn7LhH5ggGG1RfSuB6KwdmAxPWXngYv6uLMS+u2nokb1lXhMQ0xkaL
bqxoLiuBRCIDmbdlQWext+ZyFQaa1wV/3mn30+JKa3/1EzScRiZqAOh7ZWveWGE=
=73NT
-----END PGP SIGNATURE-----

--Q5kWemDN8KPFknIxPkQH5McRh9sXjmq9q--
