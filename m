From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [PKT_SCHED] RED: Fix overflow in calculation of queue
 average
Date: Thu, 3 Aug 2006 18:46:56 -0700
Message-ID: <20060803184656.55da3939@localhost.localdomain>
References: <11546408123792-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32443 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932194AbWHDBrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 21:47:09 -0400
To: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
In-Reply-To: <11546408123792-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 04 Aug 2006 00:33:32 +0300
Ilpo  J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi> wrote:

> Overflow can occur very easily with 32 bits, e.g., with 1 second
> us_idle is approx. 2^20, which leaves only 11-Wlog bits for queue
> length. Since the EWMA exponent is typically around 9, queue
> lengths larger than 2^2 cause overflow. Whether the affected
> branch is taken when us_idle is as high as 1 second, depends on
> Scell_log, but with rather reasonable configuration Scell_log is
> large enough to cause p->Stab to have zero index, which always
> results zero shift (typically also few other small indices result
> in zero shift).
>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  include/net/red.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/net/red.h b/include/net/red.h
> index 5ccdbb3..1fc32e1 100644
> --- a/include/net/red.h
> +++ b/include/net/red.h
> @@ -212,7 +212,7 @@ static inline unsigned long red_calc_qav
>  		 * Seems, it is the best solution to
>  		 * problem of too coarse exponent tabulation.
>  		 */
> -		us_idle =3D (p->qavg * us_idle) >> p->Scell_log;
> +		us_idle =3D (p->qavg * (long long)us_idle) >> p->Scell_log;
> =20
>  		if (us_idle < (p->qavg >> 1))
>  			return p->qavg - us_idle;

Use u64 instead of long long.=20

--=20
If one would give me six lines written by the hand of the most honest
man, I would find something in them to have him hanged. -- Cardinal Ric=
hlieu
