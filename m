From: Jon Loeliger <jdl@jdl.com>
Subject: Re: [PATCH RFC] gianfar: Make polling safe with IRQs disabled
Date: Thu, 05 Nov 2009 08:01:10 -0600
Message-ID: <E1N62ti-0003iS-K2@jdl.com>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru>
Cc: David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>,
	Jason Wessel <jason.wessel@windriver.com>
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jdl.com ([208.123.74.7]:58711 "EHLO jdl.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757465AbZKEOjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 09:39:11 -0500
In-reply-to: <20091104225711.GA30844@oksana.dev.rtsoft.ru> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When using KGDBoE, gianfar driver spits 'Interrupt problem' messages,
> which appears to be a legitimate warning, i.e. we may end up calling
> netif_receive_skb() or vlan_hwaccel_receive_skb() with IRQs disabled.
> 
> This patch reworks the RX path so that if netpoll is enabled (the
> only case when the driver don't know from what context the polling
> may be called), we check whether IRQs are disabled, and if so we
> fall back to safe variants of skb receiving functions.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> 
> I'm not sure if this is suitable for mainline since it doesn't
> have KGDBoE support. Jason, if the patch is OK, would you like
> to merge it into KGDB tree?

It's a legitimate problem with or without KGDBoE.  I see it
occasionally when conn_track is enabled as well, for example.

jdl
