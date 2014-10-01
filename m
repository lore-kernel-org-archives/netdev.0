From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Wed, 01 Oct 2014 12:10:59 -0700
Message-ID: <1412190659.16704.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001185604.GG17706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:53670 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbaJATKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:10:48 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so697575pdj.40
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 12:10:48 -0700 (PDT)
In-Reply-To: <20141001185604.GG17706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-01 at 14:56 -0400, Sowmini Varadhan wrote:
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

I do not think we can accept this.

You basically found a way to overcome NAPI standard limits (budget of
64)
