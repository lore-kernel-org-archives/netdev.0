From: "D.S. Ljungmark" <ljungmark@modio.se>
Subject: Re: [PATCH net-next] Revert "net/ipv6: add sysctl option
 accept_ra_min_hop_limit"
Date: Fri, 11 Sep 2015 13:09:26 +0200
Message-ID: <55F2B666.5070601@modio.se>
References: <20150902094301.GA6434@via.ecp.fr>
 <20150902.161110.223512323094619164.davem@davemloft.net>
 <20150909101054.GA6753@bistromath.redhat.com>
 <55F11AAD.3030209@miraclelinux.com>
 <20150910094037.GB22575@bistromath.redhat.com>
 <55F245B8.3060903@miraclelinux.com> <20150911105300.GJ24810@breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="lRxUXW4VSBWI5rIL6bsjnKh8wjPQR98rc"
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	liuhangbin@gmail.com, hannes@stressinduktion.org
To: Florian Westphal <fw@strlen.de>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:34518 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbIKLJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 07:09:33 -0400
Received: by lahg1 with SMTP id g1so15491012lah.1
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 04:09:31 -0700 (PDT)
In-Reply-To: <20150911105300.GJ24810@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lRxUXW4VSBWI5rIL6bsjnKh8wjPQR98rc
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/09/15 12:53, Florian Westphal wrote:
> YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com> wrote:
>> Sabrina Dubroca wrote:
>>> 2015-09-10, 14:52:45 +0900, YOSHIFUJI Hideaki wrote:
>>>> Sabrina Dubroca wrote:
>>>>> Would you agree with a default of 64, as Florian suggested?
>>>>
>>>> 1 was chosen to restore our behavior before introduction of current
>>>> hoplimit check.  I am not in favor of changing that value.
>>>
>>> But our old behavior had a security issue, which is why the >=3D curr=
ent
>>> check was introduced.
>>
>> We have the knob to "protect" ourselves now but it has drawbacks no to=

>> accept lower values than specified.  We can never have ultimate defaul=
t
>> for everybody.  The knob might "mitigate" the issue but once we have
>> any rouge routers on our L2, we lose anyway.  So, I do want to keep it=

>> as-is not to change our traditional behavior.
>=20
> If that argument is brough forward (and it's a good point!), then the
> entire case for rejecting 'low' hoplimit values in first place becomes =
moot.
>=20
> If this is an important security issue, then either the sysctl has to b=
e
> removed or the default raised to some 'safe' value (32, for example).
>=20
> If its not a security issue -- and it isn't if we think "1" is a good
> default choice -- then we should seriously consider reverting both
> the added sysctl and the 'original' commit (6fd99094de2b; "ipv6: Don't
> reduce hop limit for an interface").
>=20


The most common use-case for this is public WiFi.  So far, a negible
amount of access points have even remote ability to filter "unwanted" L2
traffic.

The fact that a single, empty RA packet with a hop limit of 2 will take
down your entire ipv6, even if your infrastructure uses DHCPv6 for
addressing is problematic.

There are scenarios where an L2 agent can push a link-local or
Peer-to-peer routes with a low hoplimit. These routes would then lower
the interface-level hop limit to something that breaks your other routing=
=2E

Personally, I think the concept of hop-limit being per interface in IPv6
is disasterously stupid, but I'm not arguing against the RFC there.

//D.S.



--=20
8362 CB14 98AD 11EF CEB6  FA81 FCC3 7674 449E 3CFC


--lRxUXW4VSBWI5rIL6bsjnKh8wjPQR98rc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV8rZmAAoJEPzDdnREnjz8Z9oP/0UEB7rLNnlSeHO1XZxolM36
C9aCFDIEpc2BBpxFfNnppNBRiqJrAc+cBcZpAVPyttskWqRaJUBJYvh7Xf9OX/IS
YcULiVw2XSaFCIbH9d8Q0531kHKE1CkNNAwMc6AEyOJTuRo7l1kzzurRhnosV0/p
o0JMuo0b8FpxMSSTiSd6aNfc+1ZtrUrTOwx8K/ufQ6wgWrPaLFk0OOw5CdjA1rTP
rxEx18sPSPFM0CruZcIXxh5CaofxRQhfMTcnS+OnFqoulbAEFrfUWc7t4t0uxfqw
0s57wJncYp3Dup3VAIBtWIWm7NtfVBYc3BqSHP/YMTEBhmx9atFNFRC5kdnhl7AY
/KsNKTLPJfAVu32Mrq5mh1yCCVBQr5t+qGvmEwxakTh2bYf6TDMh9rKxWIJclHUG
26NKF6C+jXETJtCkWi02pBhrLFwSY4cawVeptzgVRzAHSEZLoZNwMMK9tNNeqEVB
RcK9/zFGnbcVIuma2Hb+1GOcXsp/Yp5o4V/jG4sf7EaMUJOF5+ikN0FjR8uDacn6
cgyvErzzv9r3j9Zqe+vJLWYAZj69/t2CzUNjAxOJN86srYre0s1maoy08a6EqIbx
3lTBEWXu6I4dE9h9/zf0qS1vBiH7KisIZkJuZAZCLPs2vACOdjSwLX4ZnQnSy4n1
RlYY6TDfPQqrPJTl3PJX
=Fwef
-----END PGP SIGNATURE-----

--lRxUXW4VSBWI5rIL6bsjnKh8wjPQR98rc--
