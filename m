From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers: net: cpsw: fix kmemleak false-positive
 reports for sk buffers
Date: Wed, 10 Aug 2016 18:00:20 -0700 (PDT)
Message-ID: <20160810.180020.2223832285502216272.davem@davemloft.net>
References: <20160810170253.31825-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, nsekhar@ti.com,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	catalin.marinas@arm.com
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160810170253.31825-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Wed, 10 Aug 2016 20:02:53 +0300

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 0805855..5caef77 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -732,6 +732,11 @@ static void cpsw_rx_handler(void *token, int len, int status)
>  		netif_receive_skb(skb);
>  		ndev->stats.rx_bytes += len;
>  		ndev->stats.rx_packets++;
> +		/* SKB pointer will be stored in CPPI RAM (SRAM) which belongs
> +		 * to MMIO space, as result false positive memory leak report
> +		 * will be generated.
> +		 */
> +		kmemleak_not_leak(new_skb);
>  	} else {
>  		ndev->stats.rx_dropped++;
>  		new_skb = skb;

There is already a kmemleak_not_leak() statement here in the current
driver.

Please always develop and generate patches against current sources.
