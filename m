From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-02-10
Date: Wed, 10 Feb 2010 11:07:56 -0800 (PST)
Message-ID: <20100210.110756.201335073.davem@davemloft.net>
References: <20100210185816.GB3286@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100210185816.GB3286@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 10 Feb 2010 13:58:16 -0500

> Please let me know if there are problems!

I see one:

> diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
> index 5681ebe..03dfd27 100644
> --- a/drivers/ssb/main.c
> +++ b/drivers/ssb/main.c
> @@ -494,8 +494,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
>  #endif
>  			break;
>  		case SSB_BUSTYPE_SDIO:
> -#ifdef CONFIG_SSB_SDIO
> -			sdev->irq = bus->host_sdio->dev.irq;
> +#ifdef CONFIG_SSB_SDIOHOST
>  			dev->parent = &bus->host_sdio->dev;
>  #endif
>  			break;

The commit message says "fix a typo" but it's also removing
the assignment of sdev->irq

All the bus types assign the sdev->irq, so it looks like
this was removed unintentionally.

If it was intentional, it needs to be explained in the
commit message or a code comment.
