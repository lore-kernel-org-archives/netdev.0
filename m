From: Nelson Elhage <nelhage@ksplice.com>
Subject: Re: [PATCH] NET: pktgen - fix compile warning
Date: Sun, 7 Nov 2010 08:16:24 -0500
Message-ID: <20101107131624.GD3032@ksplice.com>
References: <20101107061138.GA6601@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:57577 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab0KGNQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 08:16:29 -0500
Received: by qyk10 with SMTP id 10so4210035qyk.19
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 05:16:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20101107061138.GA6601@core.coreip.homeip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good catch; sorry I missed that.

Reviewed-by: Nelson Elhage <nelhage@ksplice.com>

On Sat, Nov 06, 2010 at 11:11:38PM -0700, Dmitry Torokhov wrote:
> This should fix the following warning:
>=20
> net/core/pktgen.c: In function =E2=80=98pktgen_if_write=E2=80=99:
> net/core/pktgen.c:890: warning: comparison of distinct pointer types =
lacks a cast
>=20
> Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
> ---
>=20
> Unless somebody already beat me to it...
>=20
>  net/core/pktgen.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
>=20
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index fbce4b0..1992cd0 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -887,7 +887,7 @@ static ssize_t pktgen_if_write(struct file *file,
>  	i +=3D len;
> =20
>  	if (debug) {
> -		size_t copy =3D min(count, 1023);
> +		size_t copy =3D min_t(size_t, count, 1023);
>  		char tb[copy + 1];
>  		if (copy_from_user(tb, user_buffer, copy))
>  			return -EFAULT;
>=20
> --=20
> Dmitry
