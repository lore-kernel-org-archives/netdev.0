From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: Re: [PATCH] ipv6: Fixed source specific default route handling.
Date: Mon, 22 Jun 2015 19:51:14 +0200
Message-ID: <55884B12.7010307@universe-factory.net>
References: <7922B483-7EA7-4B50-BF1C-7681EB7CC454@iki.fi>
 <5586F1F8.1070800@universe-factory.net>
 <0D0CB420-018B-465C-B27B-72016F41C268@iki.fi>
 <55873C46.4090804@universe-factory.net> <5587A418.4000308@midlink.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="PELKNrEw1LiUJ10j7LSp4dbWDq3pvc49w"
Cc: Markus Stenberg <markus.stenberg@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Steven Barth <steven@midlink.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5587A418.4000308@midlink.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PELKNrEw1LiUJ10j7LSp4dbWDq3pvc49w
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 06/22/2015 07:58 AM, Steven Barth wrote:
> On 22.06.2015 00:35, Matthias Schiffer wrote:
>> Could you explain in detail what you mean with "If you want specific S=
A,
>> add same route with higher metric and/or (more) specific src match."?
>> Routes aren't bound to specific addresses except via the "src" attribu=
te
>> (which is called prefsrc in the kernel), which is exactly what it not
>> working. I can't control the chosen source address at all when
>> source-specific routes are involved.
> Except that prefsrc and src are two different beasts and usually ip rou=
te from transates to
> RTA_SRC instead of RTA_PREFSOURCE when used with a prefix length.
>=20
> Try adding two routes to the same destination with the same metric but =
different source values with PREFSRC (e.g. IPv4) and then
> try doing the same with SRC (e.g. IPv6). The former will fail but the l=
atter will succeed.

Ah sorry, I didn't know that "src" and "prefsrc" were distinct concepts.
I meant to refer to "src" whenever I wrote "prefsrc". What are the
precise semantics of the "src" attribute? Any RFC I can read, or is this
a Linux-specific concept?

>=20
>=20
> https://tools.ietf.org/html/draft-troan-homenet-sadr-01
> was the original draft for source-address dependent routing IIRC so mig=
ht be a good read.

Thanks for the link, that helps a bit.

>=20
>=20
>>
>> Even though the source-specific route has a higher metric than the
>> generic one, the source-specific one shadows the generic route.
>=20
> (was a bit ago since I read into this so please correct me if I am wron=
g)
> IIRC this is intentional since longest-prefix-match beats metric here
> and the source-address match counts to being more-specific here. See al=
so above difference between PREFSRC and SRC.

Ah, that would explain the metric issue. I looks like the source of my
confusion is that for source-specific routes *all* addresses are in the
candidate set, not only the addresses of the outgoing interface (which
makes sense as ip6_route_get_saddr() is called with a NULL rt6_info in
the source-specific case).

I'm not sure if this can be fixed in a sane way (as there seems to be a
dependency cycle: source address should depend on outgoing interface,
which depends on the chosen route, which depends on the source address),
but it leads to highly unintuitive source address selection :(

Markus suggested in the commit message not to call ip6_route_output at
all before the source address has been selected. Wouldn't this make it
impossible to choose the source address depending on the outgoing
interface in the non-source-specific case as well?

> Cheers,
>=20
> Steven

Thanks for the explanation,
Matthias


--PELKNrEw1LiUJ10j7LSp4dbWDq3pvc49w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJViEsTAAoJEBbvP2TLIB2cXe4QANWRHfEDtYr48uSGszOG+8CB
OKs5JnDwIr+wDvHtZjp0+t8XxewnCGFpixjNJ71cerPYgI8P6AVmv1MfUszSAKRD
T1HIrDRjAQhgyVbTMOW3i8KC8ZSWOTBEKHBTOHTyqaZAWLK2fi29oxJvcF2AhjOt
INpBHtUPLnrk4AXYYSQ0bLRJikfosnpda0OcYj3jCdFPEKIgWfb3rBOCS43XiEWS
KHFVoG8LCK26DUU5T2vX8xDoiGMCucB6pJR5w2N+kDqEikTCvMhHmhclEunyTh+k
gTm3+Nyftc+gdmxuxPddWo1stNtxc4f2Oq92vtKtN8EqJNWeE9yTkCe/WiKrHA7P
jsUs3J28XsKa7Rpt6sYwjuGg8TRGj2tVbHtljqs6fdb4Kv2s7gpDXkbs33tfC3y0
ji841hqFGi+iHtrXx7bLzUzkSVISOS8l2Kfc3D11mhi3DjYAcukYK3RdK7t25Ft/
Ci758DbbWkapXgsMr+HUN8/7DifvoYV7bbxddgmwQoAKJ0MuqmqBzf5jwNBZrVK8
tyaqIVcrLZjCjxV/GSGuuX2nelBmbyPzI70yf9rHpnF69VcrxdcB21KtFj5D3JSP
eQoNkQHe03GFKxdq473AcmaFximn+tly7CfBHwYZ3UL+9qH9vxNsaxd/enVqR4u2
wEakpcmmDOS5uvoANVdH
=pH9R
-----END PGP SIGNATURE-----

--PELKNrEw1LiUJ10j7LSp4dbWDq3pvc49w--
