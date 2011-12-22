From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Thu, 22 Dec 2011 07:16:32 +0100
Message-ID: <1324534592.2621.37.camel@edumazet-laptop>
References: <20111222170726.b16565ef7d1434cc4ec170d7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus <torvalds@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111222170726.b16565ef7d1434cc4ec170d7@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 17:07 +1100, Stephen Rothwell a =C3=
=A9crit :
> Hi all,
>=20
> After merging the final tree, today's linux-next build (sparc32 defco=
nfig)
> failed like this:
>=20
> net/ipv4/route.c: In function 'rt_check_expire':
> net/ipv4/route.c:873:4: error: implicit declaration of function 'pref=
etch' [-Werror=3Dimplicit-function-declaration]
>=20
> Caused by commit 9f28a2fc0bd7 ("ipv4: reintroduce route cache garbage
> collector").
>=20
> Linus, that commit is in the latest pull request you have from Dave .=
=2E.
>=20
> I applied the following patch for today:
>=20
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 22 Dec 2011 17:03:29 +1100
> Subject: [PATCH] ipv4: using prefetch requires including prefetch.h
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  net/ipv4/route.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 7460483..9c01f56 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -91,6 +91,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/times.h>
>  #include <linux/slab.h>
> +#include <linux/prefetch.h>
>  #include <net/dst.h>
>  #include <net/net_namespace.h>
>  #include <net/protocol.h>
> --=20
> 1.7.8.197.g73c6b
>=20

Thanks Stephen

I did a revert of a previous patch, and at that time prefetch() was
probably included in some header.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
