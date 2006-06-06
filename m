From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.18 1/3] tg3: Remove unnecessary tx_lock
Date: Mon, 5 Jun 2006 22:10:56 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BCBA@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4621 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S932109AbWFFFLL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 01:11:11 -0400
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> The paths where full lock is preceded by netif_tx_disable are 
> obviously
> safe (well, once you take off the LLTX flag anyway).  
> However, there are
> paths that don't do netif_tx_disable (e.g., tg3_set_rx_mode), are they
> safe as well?
> 

In places where we don't call tg3_netif_stop() before tg3_full_lock(),
we are typically doing one of the following:

- changing tg3_flags or tg3_flags2
- reprogramming MAC address
- reprogramming interrupt coalescing values
- reprogramming the PHY
- setting the rx mode

The TX code does not do any of these so it is safe.

tg3_set_rx_mode() is actually called with xmit_lock held through
dev->set_multicast_list(). Or it is called after tg3_netif_stop() in
the VLAN registration calls (in my patch #3).

