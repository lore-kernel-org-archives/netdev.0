From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] net: sh_eth: fix build failure
Date: Fri, 30 Sep 2011 15:55:39 +0900
Message-ID: <CABMQnVLRO1q=Oi7CWE=CJqYcUBD6s+z1JTWrO8W1wVmFwuA45w@mail.gmail.com>
References: <4E8534A9.3050002@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4E8534A9.3050002@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/9/30 Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>:
> The following commit removed some including headers:
> =A0"net: sh_eth: move the asm/sh_eth.h to include/linux/"
> =A0(commit id: d4fa0e35fdbd54acf791fa3793d6d17f7795f7ae)
>
> Then, the build failure happened on the linux-next:
>
> drivers/net/ethernet/renesas/sh_eth.c:601: error: 'THIS_MODULE' undec=
lared here (not in a function)
> drivers/net/ethernet/renesas/sh_eth.c:1970: error: expected declarati=
on specifiers or '...' before string constant
> drivers/net/ethernet/renesas/sh_eth.c:1970: warning: data definition =
has no type or storage class
> drivers/net/ethernet/renesas/sh_eth.c:1970: warning: type defaults to=
 'int' in declaration of 'MODULE_AUTHOR'
> drivers/net/ethernet/renesas/sh_eth.c:1970: warning: function declara=
tion isn't a prototype
> drivers/net/ethernet/renesas/sh_eth.c:1971: error: expected declarati=
on specifiers or '...' before string constant
> drivers/net/ethernet/renesas/sh_eth.c:1971: warning: data definition =
has no type or storage class
> drivers/net/ethernet/renesas/sh_eth.c:1971: warning: type defaults to=
 'int' in declaration of 'MODULE_DESCRIPTION'
> drivers/net/ethernet/renesas/sh_eth.c:1971: warning: function declara=
tion isn't a prototype
> drivers/net/ethernet/renesas/sh_eth.c:1972: error: expected declarati=
on specifiers or '...' before string constant
> drivers/net/ethernet/renesas/sh_eth.c:1972: warning: data definition =
has no type or storage class
> drivers/net/ethernet/renesas/sh_eth.c:1972: warning: type defaults to=
 'int' in declaration of 'MODULE_LICENSE'
> drivers/net/ethernet/renesas/sh_eth.c:1972: warning: function declara=
tion isn't a prototype
>
> This patch fixes the issue. This patch also get back include/kernel.h
> and linux/spinlock.h.
>
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
> =A0drivers/net/ethernet/renesas/sh_eth.c | =A0 =A03 +++
> =A01 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethe=
rnet/renesas/sh_eth.c
> index 6aa0704..9b23074 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -21,6 +21,9 @@
> =A0*/
>
> =A0#include <linux/init.h>
> +#include <linux/module.h>
This is required.

> +#include <linux/kernel.h>
> +#include <linux/spinlock.h>
These are not required.

> =A0#include <linux/interrupt.h>
> =A0#include <linux/dma-mapping.h>
> =A0#include <linux/etherdevice.h>

Best regards,
  Nobuhiro
Nobuhiro Iwamatsu
