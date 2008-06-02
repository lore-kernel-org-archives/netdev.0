From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Tue, 3 Jun 2008 00:08:55 +1000
Message-ID: <20080602140855.GA25944@gondor.apana.org.au>
References: <E1K33OH-0005QX-00@gondolin.me.apana.org.au> <Pine.LNX.4.64.0806021442450.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnpol@2ka.mipt.ru, ray-lk@madrabbit.org, mingo@elte.hu,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36595 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753928AbYFBOJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 10:09:10 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806021442450.16829@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2008 at 02:53:09PM +0300, Ilpo J=E4rvinen wrote:
>
> Shouldn't that be already visible in the ingo's sysrq-t dump, no? The=
re:
>=20
>   http://marc.info/?l=3Dlinux-kernel&m=3D121182099131520&w=3D2

No, we need an actual strace rather than the static stack back-trace.
So start with netstat -lntp to locate the process listening on that
port, and then strace it to see if it's calling accept.

> There are many sys_accepts at least (if I understand that dump at all=
).=20
> There were some ip_local_outs there as well, which made me wonder if =
the=20
> totally innocent looking commit 1ac06e0306d0192a7a4d9ea1c9e06d355ce7e=
7d3=20
> (ipsec: Use the correct ip_local_out function) has something to do wi=
th=20
> this (I definately don't understand that part at all).

This patch only has an effect for IPsec.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
