From: Doug Ledford <dledford@redhat.com>
Subject: Re: 4.4-rc7 failure report
Date: Mon, 28 Dec 2015 20:26:44 -0500
Message-ID: <5681E154.7040101@redhat.com>
References: <5681AF69.4040204@redhat.com> <5681B594.70304@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="j7nvJ6MP6AtTeWGxLl38LJoq36kBqCXeW"
Cc: David Miller <davem@davemloft.net>,
	David Miller <davem@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752754AbbL2B0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2015 20:26:46 -0500
In-Reply-To: <5681B594.70304@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--j7nvJ6MP6AtTeWGxLl38LJoq36kBqCXeW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 12/28/2015 05:20 PM, Daniel Borkmann wrote:
> On 12/28/2015 10:53 PM, Doug Ledford wrote:
>> The 4.4-rc7 kernel is failing for me.  In my case, all of my vlan
>> interfaces are failing to obtain a dhcp address using dhclient.  I've
>> tried a hand built 4.4-rc7, and the Fedora rawhide 4.4-rc7 kernel, bot=
h
>> failed.  I've tried NetworkManager and the old SysV network service,
>> both fail.  I tried a working dhclient from rhel7 on the Fedora rawhid=
e
>> install and it failed too.  Running tcpdump on the interface shows the=

>> dhcp request going out, and a dhcp response coming back in.  Running
>> strace on dhclient shows that it writes the dhcp request, but it never=

>> recvs a dhcp response.  If I manually bring the interface up with a
>> static IP address then I'm able to run typical IP traffic across the
>> link (aka, ping).  It would seem that when dhclient registers a packet=

>> filter on the socket, that filter is preventing it from ever getting t=
he
>> dhcp response.  The same dhclient works on any non-vlan interfaces in
>> the system, so the filter must work for non-vlan interfaces.  Aside fr=
om
>> the fact that the interface is a vlan, we also use a priority egress m=
ap
>> on the interface, and we use PFC flow control.  Let me know if you nee=
d
>> anymore to debug the issue, or email me off list and I can get you
>> logins to my reproducer machines.
>=20
> When you say 4.4-rc7 kernel is failing for you, what latest kernel vers=
ion
> was working, where the socket filter was properly receiving the respons=
e on
> your vlan iface?

v4.3 final works.  I haven't bisected where in the 4.4 series it quits
working.  I can do that tomorrow.

> Are you reasonably sure that the skb is dropped at the BPF
> filter attached to the dhcp's packet socket?

No.  I'm only reasonably sure that without a filter it works, I don't
know if it gets dropped at the BPF filter or something else when the
filter is added.  It could be an interaction between the filter and PFC
or vlan or anything else for all I know.  But I figured the level of
detail I gave should make it easy to reproduce locally by interested
parties.

> Can you dump the BPF code of
> the filter?

It's whatever the filter is that dhclient uses.  I'm pretty sure that's
a pretty standard filter.  And I tried known working dhclients in order
to make sure it wasn't the latest dhclient's fault.

> Are there any vlan offloading settings the filter is not taking
> into account (in the sense of classic BPF extensions, tcpdump/libpcap
> finally
> managed to cope with this)?

Have no clue.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--j7nvJ6MP6AtTeWGxLl38LJoq36kBqCXeW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWgeFUAAoJELgmozMOVy/dZcQQALE2k4+6YHdJcnxnr/13XFgI
fwwX3FmCxp+LJs5si0DXr/tEKcfnOO5EtMGz86FE59yP17UV7zUHZAoTgT+Q/338
GeBrigvqMw1e+ocG6CB1RZGt5VqzywjAdzAycUzDVjkGvf2+bmiYcmWph7pyNbCB
9ORSBfoW0XoEqIBJ6IA0R6so5DoSmgHdsd+JMU2jt4KELb7MTlgIgJzRMLaBbi1M
hrl9cOeXvYjvpqopXDVK7v2ioIEbj7THGGXDzOVm4559rjNdEK9U4RhiSDPsC4nF
FNM5u2NBpHA0lXrM3/L9YJhhmGAFJNd0kDvrvj7WmnkFJykdB4naZwMq27EVpoTj
qr+GP0Lsi6g+7LKcr6DG+h9b1UpDHpohTHZmEi4w9AwB9v0b2aM6hGgQMLVY5KP+
p3CQw9WBByXlBVcUYLIRvPtzcHuea3z2HIt3CNjynlLtMXlsf8Cdf9W7IBaGJj6F
gBC9fSwPGF7OMCafD3/F84K46N5SmZJjxhTOkkzTEow2ZQnTsjuYlItFRtZpLrwQ
j4zaiBM88hAO9eyA5isRrDCeW1mmooejF65MzmixyScxfuYKB+4azXa4oykIiSWk
kRtv7/5zB6KIlkDRJZjFS5+UfcMzcyEnPyLqDGHUms2WPK7yM/A/mtRrpQ08jWAQ
yboRVwoyiOW/7sV6RiHS
=NgSp
-----END PGP SIGNATURE-----

--j7nvJ6MP6AtTeWGxLl38LJoq36kBqCXeW--
