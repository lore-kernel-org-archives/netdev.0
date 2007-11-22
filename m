From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 1/2] [TCP]: MTUprobe: receiver window & data available checks fixed
Date: Thu, 22 Nov 2007 17:27:29 +0800
Message-ID: <20071122092729.GA7897@gondor.apana.org.au>
References: <11956608882424-git-send-email-ilpo.jarvinen@helsinki.fi> <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Heffner <jheffner@psc.edu>, netdev@vger.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1878 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751279AbXKVJ1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 04:27:45 -0500
Content-Disposition: inline
In-Reply-To: <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 06:01:27PM +0200, Ilpo J=E4rvinen wrote:
>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks for the patch Ilpo!

I've just got a couple small questions.

> @@ -1307,6 +1308,7 @@ static int tcp_mtu_probe(struct sock *sk)
>  	/* Very simple search strategy: just double the MSS. */
>  	mss_now =3D tcp_current_mss(sk, 0);
>  	probe_size =3D 2*tp->mss_cache;
> +	size_needed =3D probe_size + (tp->reordering + 1) * mss_now;

Should we use mss_now here or mss_cache? It would seem that an
over-estimate would be safer than an under-estimate.

Also should that be Tcprexmtthresh segments at the current MTU
or the probed MTU?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
