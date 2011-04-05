From: Ben Hutchings <bhutchings@solarflare.com>
Subject: NETIF_F_TSO vs NETIF_F_TSO{6,_ECN}
Date: Tue, 05 Apr 2011 16:50:02 +0100
Message-ID: <1302018602.2932.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59856 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135Ab1DEPuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 11:50:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to the commit that introduced NETIF_F_TSO6
(f83ef8c0b58dac17211a4c0b6df0e2b1bd6637b1):
    
        This patch will introduce a new flag NETIF_F_TSO6 which will be used
        to check whether device supports TSO over IPv6. If device support TSO
        over IPv6 then we don't clear of NETIF_F_TSO and which will make the
        TCP layer to create TSO packets. Any device supporting TSO over IPv6
        will set NETIF_F_TSO6 flag in "dev->features" along with NETIF_F_TSO.
    
        In case when user disables TSO using ethtool, NETIF_F_TSO will get
        cleared from "dev->features". So even if we have NETIF_F_TSO6 we don't
        get TSO packets created by TCP layer.

So I think we need to either:
1. Disallow toggling NETIF_F_TSO6 (following the previous rule)
2. Disable NETIF_F_TSO6 when NETIF_F_TSO is disabled

The same presumably applies to NETIF_F_TSO_ECN.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

