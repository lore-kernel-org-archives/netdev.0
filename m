From: Andreas Schwab <schwab@suse.de>
Subject: Re: [XFRM] Probe selected algorithm only
Date: Fri, 04 Feb 2005 22:29:49 +0100
Message-ID: <m3fz0cj9o2.fsf@igel.m5r.de>
References: <20050121101938.GA1133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050121101938.GA1133@gondor.apana.org.au> (Herbert Xu's
 message of "Fri, 21 Jan 2005 21:19:38 +1100")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> writes:

> =3D=3D=3D=3D=3D net/xfrm/xfrm_algo.c 1.15 vs edited =3D=3D=3D=3D=3D
> --- 1.15/net/xfrm/xfrm_algo.c	2004-12-28 13:33:32 +11:00
> +++ edited/net/xfrm/xfrm_algo.c	2005-01-21 21:17:12 +11:00
> @@ -13,6 +13,7 @@
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/pfkeyv2.h>
> +#include <linux/crypto.h>
>  #include <net/xfrm.h>
>  #if defined(CONFIG_INET_AH) || defined(CONFIG_INET_AH_MODULE) || defin=
ed(CONFIG_INET6_AH) || defined(CONFIG_INET6_AH_MODULE)
>  #include <net/ah.h>
> @@ -346,58 +347,48 @@
>  	return NULL;
>  }
> =20
> -struct xfrm_algo_desc *xfrm_aalg_get_byname(char *name)
> +static struct xfrm_algo_desc *xfrm_get_byname(struct xfrm_algo_desc *l=
ist,
> +					      int entries, char *name,
> +					      int probe)
>  {
> -	int i;
> +	int i, status;
> =20
>  	if (!name)
>  		return NULL;
> =20
> -	for (i=3D0; i < aalg_entries(); i++) {
> -		if (strcmp(name, aalg_list[i].name) =3D=3D 0) {
> -			if (aalg_list[i].available)
> -				return &aalg_list[i];
> -			else
> -				break;
> -		}
> +	for (i =3D 0; i < entries; i++) {
> +		if (!strcmp(name, list[i].name))
> +			continue;

You probably didn't mean this. :-)

Return the first matching entry in xfrm_get_byname instead of the first
non-matching one.

Signed-off-by: Andreas Schwab <schwab@suse.de>

--- linux-2.6.11-rc3/net/xfrm/xfrm_algo.c.~1~	2005-02-03 22:54:42.0000000=
00 +0100
+++ linux-2.6.11-rc3/net/xfrm/xfrm_algo.c	2005-02-04 21:56:11.000000000 +=
0100
@@ -357,7 +357,7 @@ static struct xfrm_algo_desc *xfrm_get_b
 		return NULL;
=20
 	for (i =3D 0; i < entries; i++) {
-		if (!strcmp(name, list[i].name))
+		if (strcmp(name, list[i].name) !=3D 0)
 			continue;
=20
 		if (list[i].available)

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=C3=9Fe 5, 90409 N=C3=BCrnberg, Germ=
any
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
