From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH] net: ieee802154: constify ieee802154_ops structures
Date: Mon, 21 Nov 2016 21:39:53 +0100
Message-ID: <2ede4944-b26a-dce4-74f0-80a55e0b2af4@osg.samsung.com>
References: <1479760214-32624-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        michael.hennerich@analog.com, aar@pengutronix.de,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479760214-32624-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 21/11/16 21:30, Bhumika Goyal wrote:
> Declare the structure ieee802154_ops as const as it is only passed as an
> argument to the function  ieee802154_alloc_hw. This argument is of type
> const struct ieee802154_ops *, so ieee80254_ops structures having this
> property can be declared as const.
> Done using Coccinelle:
>
> @r1 disable optional_qualifier @
> identifier i;
> position p;
> @@
> static struct ieee802154_ops i@p = {...};
>
> @ok1@
> identifier r1.i;
> position p;
> expression e1;
> @@
> ieee802154_alloc_hw(e1,&i@p)
>
> @bad@
> position p!={r1.p,ok1.p};
> identifier r1.i;
> @@
> i@p
>
> @depends on !bad disable optional_qualifier@
> identifier r1.i;
> @@
> static
> +const
> struct ieee802154_ops  i={...};
>
> @depends on !bad disable optional_qualifier@
> identifier r1.i;
> @@
> +const
> struct ieee802154_ops  i;
>
> The before and after size details of the affected files are:
>
>    text	   data	    bss	    dec	    hex	filename
>    8669	   1176	     16	   9861	   2685	drivers/net/ieee802154/adf7242.o
>    8805	   1048	     16	   9869	   268d	drivers/net/ieee802154/adf7242.o
>
>    text	   data	    bss	    dec	    hex	filename
>    7211	   2296	     32	   9539	   2543	drivers/net/ieee802154/atusb.o
>    7339	   2160	     32	   9531	   253b	drivers/net/ieee802154/atusb.o
>
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
>  drivers/net/ieee802154/adf7242.c | 2 +-
>  drivers/net/ieee802154/atusb.c   | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ieee802154/adf7242.c b/drivers/net/ieee802154/adf7242.c
> index 9fa7ac9..4ff4c7d 100644
> --- a/drivers/net/ieee802154/adf7242.c
> +++ b/drivers/net/ieee802154/adf7242.c
> @@ -874,7 +874,7 @@ static int adf7242_rx(struct adf7242_local *lp)
>  	return 0;
>  }
>
> -static struct ieee802154_ops adf7242_ops = {
> +static const struct ieee802154_ops adf7242_ops = {
>  	.owner = THIS_MODULE,
>  	.xmit_sync = adf7242_xmit,
>  	.ed = adf7242_ed,
> diff --git a/drivers/net/ieee802154/atusb.c b/drivers/net/ieee802154/atusb.c
> index 1056ed1..322864a 100644
> --- a/drivers/net/ieee802154/atusb.c
> +++ b/drivers/net/ieee802154/atusb.c
> @@ -567,7 +567,7 @@ static void atusb_stop(struct ieee802154_hw *hw)
>  	return 0;
>  }
>
> -static struct ieee802154_ops atusb_ops = {
> +static const struct ieee802154_ops atusb_ops = {
>  	.owner			= THIS_MODULE,
>  	.xmit_async		= atusb_xmit,
>  	.ed			= atusb_ed,
>


Acked-by: Stefan Schmidt <stefan@osg.samsung.com>

regards
Stefan Schmidt
