From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 09/13] atmel-mci: convert to dma_request_channel and
 down-level dma_slave
Date: Sat, 31 Jan 2009 01:40:50 +0900 (JST)
Message-ID: <20090131.014050.126762132.anemo@mba.ocn.ne.jp>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	<20081114213503.32354.21080.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:63353 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752464AbZA3Qkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 11:40:51 -0500
In-Reply-To: <20081114213503.32354.21080.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Nov 2008 14:35:03 -0700, Dan Williams <dan.j.williams@intel.com> wrote:
> dma_request_channel provides an exclusive channel, so we no longer need to
> pass slave data through dmaengine.
> 
> Cc: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Sorry for late review... I hope not too late.

> @@ -789,23 +782,17 @@ static int dwc_alloc_chan_resources(struct dma_chan *chan,
>  	cfghi = DWC_CFGH_FIFO_MODE;
>  	cfglo = 0;
>  
> -	slave = client->slave;
> -	if (slave) {
> +	dws = dwc->dws;
> +	if (dws) {
>  		/*
>  		 * We need controller-specific data to set up slave
>  		 * transfers.
>  		 */
> -		BUG_ON(!slave->dma_dev || slave->dma_dev != dw->dma.dev);
> -
> -		dws = container_of(slave, struct dw_dma_slave, slave);
> +		BUG_ON(!dws->dma_dev || dws->dma_dev != dw->dma.dev);
>  
> -		dwc->dws = dws;

How dw_dma_slave passed to the dw_dmac driver?  I cannot see where
dwc->dws is initialized now.  Or am I missing something?

---
Atsushi Nemoto
