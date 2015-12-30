From: Doug Ledford <dledford@redhat.com>
Subject: Re: 4.4-rc7 failure report
Date: Wed, 30 Dec 2015 13:47:51 -0500
Message-ID: <568426D7.9000108@redhat.com>
References: <5683A630.2070401@iogearbox.net>
 <20151230151123.GB4874@codemonkey.org.uk>
 <1451494525.8255.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151230.125003.301825767708169401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="LHKwKvoMDB0pKDA54I1HTjF4q6RDsDNJo"
Cc: davej@codemonkey.org.uk, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbbL3SsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 13:48:01 -0500
In-Reply-To: <20151230.125003.301825767708169401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LHKwKvoMDB0pKDA54I1HTjF4q6RDsDNJo
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/30/2015 12:50 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Dec 2015 11:55:25 -0500
>=20
>> On Wed, 2015-12-30 at 10:11 -0500, Dave Jones wrote:
>>> On Wed, Dec 30, 2015 at 10:38:56AM +0100, Daniel Borkmann wrote:
>>>
>>>  > Given that this drop doesn't strictly need to be caused by filter =
code,
>>>  > it would be nice if you could pin the location down where the pack=
et gets
>>>  > dropped exactly. Perhaps dropwatch or perf with '-e skb:kfree_skb =
-a -g
>>>  > dhclient <iface>', etc could help to get a first overview to dig i=
nto
>>>  > details then.
>>>
>>> Wild stab in the dark, but..
>>> Could this bug be another symptom fixed by http://article.gmane.org/g=
mane.linux.network/392885 ?
>>
>> dhclient does not use async io
>=20
> But the bug causes requests to "LOOK" like async I/O, right?
>=20

I got my hands on a machine that's reliable, so the bisecting is finally
progressing again.  The machines with ocrdma devices can have link
issues, the machines with mlx5 devices don't support vlans in all kernel
versions, and some of my machines with mlx4 devices simply didn't have
their Ethernet port plugged in.  I managed to check out a machine with
mlx4 in IB/Eth mode that is otherwise reliable on all of the kernel
versions the bisection covers and modified its setup to show me at a
glance if the dhcp on vlan is working and now I'm probably over half
down with the bisection.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--LHKwKvoMDB0pKDA54I1HTjF4q6RDsDNJo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWhCbXAAoJELgmozMOVy/dvQ4P/A6KBM1vhKvzhaqwAm6r4Hmw
EzMw1sv5jgHdGQ+/Pn3+G8qJJDB+2U2U/QnoIZfWUzAhCiJJezRO09OJqzxlEnrb
z2WXpHMinGIRdeqwRFoS87rNggh7XtFewwhtdS0EXL/YyugI+rqq/wsxOVKCaML6
J+MKCqk4FbiTM6IlKyvvshp/6C940ai8Zl5EwZma4FC8LnHcgfBzR+XbYbp+0urQ
W4olFH2dkvE92qL7+cbincVZVECcuxatV+72UDhiD+ORHw3urrPqa3nWK7U2B4fc
zrxUxTWatIqiRLteRDczqIw4f7SYh+Gd1KQEL2uH58vwpopvbk5xyIBvWkSlW7WD
UeS1yF75LwBNHz1+VvGgd21m2KgegiAL6i3X+eqfpGf0tE8ZeywzfZghdAy8n7R7
KYDjlCABuYCOiuJE2NHoj0K7MVu+AZErNrBSVFy6BlUoAD87HMYsIoGqHyc2pWbK
oxPMzHMMRJVVsME7hvFgPg3L75oXO5oMx5qHP55daCwWkpuRN3wHpuwgPcyzAKIm
9gMIsqut0ltSgCMS1MFfasWyyo/3vQe+VNkjSZjpWG8zGYj/aN8J+YW7IN6FqN1b
eGHAImsV56ZofB7x/qGj2pXmqkRbccg9BYRiE1+viiPkySaxit2GStEonkGcH3f7
PIW+yrIRBdQxIzAG47+P
=4DQl
-----END PGP SIGNATURE-----

--LHKwKvoMDB0pKDA54I1HTjF4q6RDsDNJo--
