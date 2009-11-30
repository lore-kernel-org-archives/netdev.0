From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2: avoid flushing statistics when doing a MTU change
Date: Mon, 30 Nov 2009 14:32:55 +0100
Message-ID: <4B13C987.3090409@gmail.com>
References: <C27F8246C663564A84BB7AB34397724218065B9851@IRVEXCHCCR01.corp.ad.broadcom.com> <4B13C5FE.7060403@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35610 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbZK3Ncy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 08:32:54 -0500
In-Reply-To: <4B13C5FE.7060403@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno Leitao a =C3=A9crit :
  	if (netif_running(bp->dev)) {
>  		bnx2_netif_stop(bp);
> +
> +		/* Save statistics that is going to be reseted */
> +		REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
> +				BNX2_HC_COMMAND_STATS_NOW);
> +		REG_RD(bp, BNX2_HC_COMMAND);
> +		udelay(5);

I see nothing in the driver/patch that will consolidate bp->dev->stats=20
before your memcpy(). DMA transfert doesnt touch bp->dev->stats.

Please take a look at bnx2_get_stats()

> +		memcpy(&bp->stats_extra, &bp->dev->stats,
> +			sizeof(struct net_device_stats));
> +
>  		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
