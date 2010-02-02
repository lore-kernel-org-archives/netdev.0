From: Yury Polyanskiy <ypolyans@princeton.edu>
Subject: Re: [PATCH]  hrtimer, softirq: Fix hrtimer->softirq trampoline
Date: Tue, 2 Feb 2010 09:28:14 -0500
Message-ID: <20100202092814.064a89c0@penta.localdomain>
References: <4B66A670.70503@cn.fujitsu.com>
	<20100202074914.GD11081@gondor.apana.org.au>
	<20100202085117.7a5c3530@penta.localdomain>
	<1265120401.24455.306.camel@laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/V7LzS+8Min1qOl9EyBP8I=H"; protocol="application/pgp-signature"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, polyanskiy@gmail.com,
	Thomas Gleixner <tglx@linutronix.de>,
	lkml <linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppa02.Princeton.EDU ([128.112.128.216]:35068 "EHLO
	ppa02.Princeton.EDU" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab0BBO2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 09:28:43 -0500
In-Reply-To: <1265120401.24455.306.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/V7LzS+8Min1qOl9EyBP8I=H
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 02 Feb 2010 15:20:01 +0100
Peter Zijlstra <peterz@infradead.org> wrote:
>  static enum hrtimer_restart __hrtimer_tasklet_trampoline(struct hrtimer =
*timer)
>  {
>  	struct tasklet_hrtimer *ttimer =3D
>  		container_of(timer, struct tasklet_hrtimer, timer);
> =20
> -	if (hrtimer_is_hres_active(timer)) {
> -		tasklet_hi_schedule(&ttimer->tasklet);
> -		return HRTIMER_NORESTART;
> -	}
> -	return ttimer->function(timer);
> +	tasklet_hi_schedule(&ttimer->tasklet);
> +	return HRTIMER_NORESTART;
>  }
> =20

Are you totally against if(in_irq())?

Yury

--Sig_/V7LzS+8Min1qOl9EyBP8I=H
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktoNn4ACgkQemuRe3zuqOSzZQCfbxHjBimZg9hUOXh1lpEfNAXV
y98Anje4TDRX1F5NKK8dm2B8wJ2yi364
=CsGx
-----END PGP SIGNATURE-----

--Sig_/V7LzS+8Min1qOl9EyBP8I=H--
