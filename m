From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] net/core/filter.c: Fix build error
Date: Thu, 26 May 2011 14:31:53 +0200
Message-ID: <20110526123153.GA16002@elte.hu>
References: <cover.1305999731.git.joe@perches.com>
 <efa062542c692c3f7743bf2d97b5987ab989e27e.1305999731.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <efa062542c692c3f7743bf2d97b5987ab989e27e.1305999731.git.joe@perches.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Joe Perches <joe@perches.com> wrote:

> A mis-configured filter can spam the logs with lots of stack traces.
>=20
> Rate-limit the warnings and add printout of the bogus filter informat=
ion.
>=20
> Original-patch-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/core/filter.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 0eb8c44..0e3622f 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -350,7 +350,9 @@ load_b:
>  			continue;
>  		}
>  		default:
> -			WARN_ON(1);
> +			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
> +				       fentry->code, fentry->jt,
> +				       fentry->jf, fentry->k);
>  			return 0;
>  		}

This change (now upstream) fails to build in about 20% of all=20
randconfigs. Fix is below.

Thanks,

	Ingo

--------------------->
=46rom b658026bc4915d16ff3e0f59b0edda11dbd6b991 Mon Sep 17 00:00:00 200=
1
=46rom: Ingo Molnar <mingo@elte.hu>
Date: Thu, 26 May 2011 14:11:14 +0200
Subject: [PATCH] net/core/filter.c: Fix build error
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

=46ix:

  net/core/filter.c:353:4: error: invalid storage class for function =E2=
=80=98DEFINE_RATELIMIT_STATE=E2=80=99

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 net/core/filter.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 0e3622f..36f975f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -38,6 +38,7 @@
 #include <asm/unaligned.h>
 #include <linux/filter.h>
 #include <linux/reciprocal_div.h>
+#include <linux/ratelimit.h>
=20
 /* No hurry in this branch */
 static void *__load_pointer(const struct sk_buff *skb, int k, unsigned=
 int size)
