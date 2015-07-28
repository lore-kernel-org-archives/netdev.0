From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH 2/2] drivers: net: cpsw: add separate napi for
 tx packet handling for performance improvment
Date: Tue, 28 Jul 2015 11:32:43 +0530
Message-ID: <55B71B03.5030002@ti.com>
References: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com> <1437995941-5857-3-git-send-email-mugunthanvnm@ti.com> <20150727212206.GA8912@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:58757 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753903AbbG1GC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2015 02:02:56 -0400
In-Reply-To: <20150727212206.GA8912@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 28 July 2015 02:52 AM, Francois Romieu wrote:
> Mugunthan V N <mugunthanvnm@ti.com> :
> [...]
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index d68d759..4f98537 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -752,13 +753,22 @@ static irqreturn_t cpsw_tx_interrupt(int irq, void *dev_id)
>>  	struct cpsw_priv *priv = dev_id;
>>  
>>  	cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_TX);
>> -	cpdma_chan_process(priv->txch, 128);
>> +	writel(0, &priv->wr_regs->tx_en);
>> +
>> +	if (netif_running(priv->ndev)) {
>> +		napi_schedule(&priv->napi_tx);
>> +		return IRQ_HANDLED;
>> +	}
> 
> 
> cpsw_ndo_stop calls napi_disable: you can remove netif_running.
> 

Hmmmm, Will fix in v2.

Regards
Mugunthan V N
