From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 v2 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Tue, 30 Apr 2013 15:35:28 -0400 (EDT)
Message-ID: <20130430.153528.689893142405978330.davem@davemloft.net>
References: <1367118508-12340-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, r.schwebel@pengutronix.de,
	l.stach@pengutronix.de, netdev@vger.kernel.org, festevam@gmail.com,
	shawn.guo@linaro.org, lznuaa@gmail.com
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932746Ab3D3Tfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:35:30 -0400
In-Reply-To: <1367118508-12340-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Sun, 28 Apr 2013 11:08:28 +0800

> @@ -403,6 +403,12 @@ fec_restart(struct net_device *ndev, int duplex)
>  	const struct platform_device_id *id_entry =
>  				platform_get_device_id(fep->pdev);
>  	int i;
> +	if (netif_running(ndev)) {
> +		napi_disable(&fep->napi);
> +		netif_stop_queue(ndev);
> +		netif_tx_lock(ndev);
> +	}
> +
>  	u32 temp_mac[2];
>  	u32 rcntl = OPT_FRAME_SIZE | 0x04;
>  	u32 ecntl = 0x2; /* ETHEREN */

Please don't put real statements in the middle of function variable
declarations.

Thanks.
