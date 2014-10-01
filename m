From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Wed, 01 Oct 2014 15:50:09 -0400 (EDT)
Message-ID: <20141001.155009.2277009117294992988.davem@davemloft.net>
References: <20141001185604.GG17706@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbaJATuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:50:12 -0400
In-Reply-To: <20141001185604.GG17706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 1 Oct 2014 14:56:04 -0400

> 
> The existing sunvnet implementation does all the packet interception
> in LDC interrupt context. Patch 1 of this series moves the data
> processing to a bottom-half handler.
> 
> Some context for the reasons for choosing a BH handler over NAPI:
>    A NAPI (or simple tasklet) based implementation provides softirq
>    context, which allows the driver to safely invoke netif_receive_skb()
>    to deliver the packet to the IP stack. But in the case of sunvnet,
>    we are already receiving multiple packets for a single ldc_rx
>    interrupt, so the budget-based softirq-vs-polling infra does not
>    provide a significant optimization. Rather, it can get in the way,
>    if we constrain the vnet-rx path to a poorly chosen budget, and force
>    ourselves to send a STOPPED/START ldc exchange needlessly.
> 
>    A BH Rx handler is a simpler way to  avoid the weaknesses of processing
>    packets in LDC interrupt context, and also provides Rx load-spreading
>    across multiple CPUs.

I think you want to re-evaluate this considering napi_gro_receive() which
is what you should really be calling in a NAPI driver.
