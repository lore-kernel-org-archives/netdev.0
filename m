From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 18:01:24 +0100
Message-ID: <1300986084.3747.101.camel@edumazet-laptop>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
	 <1300980118.3747.42.camel@edumazet-laptop>
	 <AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
	 <1300983340.3747.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300983340.3747.44.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 24 mars 2011 =C3=A0 17:15 +0100, Eric Dumazet a =C3=A9crit :

> I am testing following patch :
>=20
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 622ac4c..654ef5b 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -251,7 +251,7 @@ static struct fib_info *fib_find_info(const struc=
t fib_info *nfi)
>  		    nfi->fib_prefsrc =3D=3D fi->fib_prefsrc &&
>  		    nfi->fib_priority =3D=3D fi->fib_priority &&
>  		    memcmp(nfi->fib_metrics, fi->fib_metrics,
> -			   sizeof(fi->fib_metrics)) =3D=3D 0 &&
> +			   sizeof(u32) * RTAX_MAX) =3D=3D 0 &&
>  		    ((nfi->fib_flags ^ fi->fib_flags) & ~RTNH_F_DEAD) =3D=3D 0 &&
>  		    (nfi->fib_nhs =3D=3D 0 || nh_comp(fi, nfi) =3D=3D 0))
>  			return fi;
>=20
>=20

This works. Here is the formal submission :

Thanks !

[PATCH] ipv4: fix fib metrics

Alessandro Suardi reported that we could not change route metrics :

ip ro change default .... advmss 1400

This regression came with commit 9c150e82ac50 (Allocate fib metrics
dynamically). fib_metrics is no longer an array, but a pointer to an
array.

Reported-by: Alessandro Suardi <alessandro.suardi@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_semantics.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 622ac4c..75b9fb5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -251,7 +251,7 @@ static struct fib_info *fib_find_info(const struct =
fib_info *nfi)
 		    nfi->fib_prefsrc =3D=3D fi->fib_prefsrc &&
 		    nfi->fib_priority =3D=3D fi->fib_priority &&
 		    memcmp(nfi->fib_metrics, fi->fib_metrics,
-			   sizeof(fi->fib_metrics)) =3D=3D 0 &&
+			   sizeof(u32) * RTAX_MAX) =3D=3D 0 &&
 		    ((nfi->fib_flags ^ fi->fib_flags) & ~RTNH_F_DEAD) =3D=3D 0 &&
 		    (nfi->fib_nhs =3D=3D 0 || nh_comp(fi, nfi) =3D=3D 0))
 			return fi;
