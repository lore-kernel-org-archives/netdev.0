From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Information about napi_struct and net_device
Date: Sat, 27 Oct 2012 20:22:07 +0200
Message-ID: <20121027182207.GA12858@electric-eye.fr.zoreil.com>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com> <1351357421.30380.328.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:32814 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758499Ab2J0Sni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 14:43:38 -0400
Content-Disposition: inline
In-Reply-To: <1351357421.30380.328.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> # grep -n napi drivers/net/ethernet/realtek/8139cp.c
> 327:	struct napi_struct	napi;
> 436:	napi_gro_receive(&cp->napi, skb);
> 468:static int cp_rx_poll(struct napi_struct *napi, int budget)
> 470:	struct cp_private *cp = container_of(napi, struct cp_private, napi);
> 566:		napi_gro_flush(napi, false);
> 568:		__napi_complete(napi);
> 605:		if (napi_schedule_prep(&cp->napi)) {
> 607:			__napi_schedule(&cp->napi);
> 1132:	napi_enable(&cp->napi);
> 1149:	napi_disable(&cp->napi);
> 1160:	napi_disable(&cp->napi);
> 1933:	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);

Not all drivers use napi_gro_receive/napi_gro_flush.

It could be worth comparing with drivers/net/ethernet/via/via-rhine.c (small)
or drivers/net/ethernet/broadcom/tg3.c (bigger).

-- 
Ueimor
