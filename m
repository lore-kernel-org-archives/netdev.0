From: Rob Herring <robh+dt@kernel.org>
Subject: Re: [PATCH v2 2/3] net: macb: Remove CONFIG_OF around DT match table
Date: Wed, 12 Apr 2017 15:51:34 -0500
Message-ID: <CAL_JsqLm_cP7zF71HwX8UZOLaWQf0Q90zOrXyXjU96xc5Cchrg@mail.gmail.com>
References: <20170412044156.17351-1-f.fainelli@gmail.com> <20170412044156.17351-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Lee Jones <lee.jones@linaro.org>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        Frank Rowand <frowand.list@gmail.com>,
        "open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
        <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:35300 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751131AbdDLUv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 16:51:59 -0400
In-Reply-To: <20170412044156.17351-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 11, 2017 at 11:41 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> A subsequent patch is going to make of_match_node() an inline stub when
> CONFIG_OF is disabled, which will let the compiler eliminate unused variables.
> In order not to clutter the code more, remove the CONFIG_OF #ifdef such that
> macb_dt_ids and what it references are always defined.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 30606b11b128..01016e9525ee 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2811,7 +2811,6 @@ static int macb_init(struct platform_device *pdev)
>         return 0;
>  }
>
> -#if defined(CONFIG_OF)
>  /* 1518 rounded up */
>  #define AT91ETHER_MAX_RBUFF_SZ 0x600
>  /* max number of receive buffers */
> @@ -3215,7 +3214,6 @@ static const struct of_device_id macb_dt_ids[] = {
>         { /* sentinel */ }
>  };
>  MODULE_DEVICE_TABLE(of, macb_dt_ids);

Did you actually check that the compiler can eliminate things when
modules are enabled? Because it's not going to be able to eliminate
MODULE_DEVICE_TABLE entry AFAICT.

Rob
