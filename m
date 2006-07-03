From: Brice Goglin <brice@myri.com>
Subject: Re: [patch 3/4] myri10ge - Use dev_info() when printing parameters
 after probe
Date: Mon, 03 Jul 2006 18:44:47 -0400
Message-ID: <44A99DDF.7010306@myri.com>
References: <20060703220230.606593000@myri.com> <20060703220517.236511000@loulous.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:48314 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751158AbWGCWow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 18:44:52 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060703220517.236511000@loulous.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please forget this one, something went wrong, it contains both #3 and
#4. I have resent #3 and #4 separately.

Brice



brice@myri.com wrote:
> Displaying the interface name when listing the device parameters
> at the end of myri10ge_probe is not a good idea since udev might
> rename the interface soon afterwards.
> Print the bus id instead, using dev_info().
>
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>
> Index: linux-mm/drivers/net/myri10ge/myri10ge.c
> ===================================================================
> --- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:02:52.000000000 -0400
> +++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:04:15.000000000 -0400
> @@ -2734,11 +2734,10 @@
>  		dev_err(&pdev->dev, "register_netdev failed: %d\n", status);
>  		goto abort_with_irq;
>  	}
> -
> -	printk(KERN_INFO "myri10ge: %s: %s IRQ %d, tx bndry %d, fw %s, WC %s\n",
> -	       netdev->name, (mgp->msi_enabled ? "MSI" : "xPIC"),
> -	       pdev->irq, mgp->tx.boundary, mgp->fw_name,
> -	       (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
> +	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
> +		 (mgp->msi_enabled ? "MSI" : "xPIC"),
> +		 pdev->irq, mgp->tx.boundary, mgp->fw_name,
> +		 (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
>  
>  	return 0;
>  
> >From bgoglin@loulous.org Mon Jul  3 18:05:17 2006
> Message-Id: <20060703220517.426089000@loulous.org>
> References: <20060703220230.606593000@myri.com>
> User-Agent: quilt/0.45-1
> Date: Mon, 03 Jul 2006 18:02:34 -0400
> From: brice@myri.com
> To: netdev@vger.kernel.org
> Cc: Brice Goglin <brice@myri.com>
> Subject: [patch 4/4] myri10ge - Export more parameters to ethtool.
> Content-Disposition: inline; filename=myri10ge4-export_more_parameters_to_ethtool.patch
>
> Add the IRQ line, the tx_boundary, and whether Write-combining and MSI
> are enabled to the list of parameters that are exported to ethtool.
>
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    5 +++++
>  1 file changed, 5 insertions(+)
>
> Index: linux-mm/drivers/net/myri10ge/myri10ge.c
> ===================================================================
> --- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:04:47.000000000 -0400
> +++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:39:29.000000000 -0400
> @@ -1288,6 +1288,7 @@
>  	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
>  	"tx_heartbeat_errors", "tx_window_errors",
>  	/* device-specific stats */
> +	"tx_boundary", "WC", "irq", "MSI",
>  	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
>  	"serial_number", "tx_pkt_start", "tx_pkt_done",
>  	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
> @@ -1326,6 +1327,10 @@
>  	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
>  		data[i] = ((unsigned long *)&mgp->stats)[i];
>  
> +	data[i++] = (unsigned int)mgp->tx.boundary;
> +	data[i++] = (unsigned int)(mgp->mtrr >= 0);
> +	data[i++] = (unsigned int)mgp->pdev->irq;
> +	data[i++] = (unsigned int)mgp->msi_enabled;
>  	data[i++] = (unsigned int)mgp->read_dma;
>  	data[i++] = (unsigned int)mgp->write_dma;
>  	data[i++] = (unsigned int)mgp->read_write_dma;
>
>   

