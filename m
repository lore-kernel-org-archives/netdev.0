From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: set carrier off in probe
Date: Fri, 30 Oct 2009 08:34:52 -0700
Message-ID: <20091030083452.68ca227e@nehalam>
References: <20091030035128.GA3380@jenkins.home.ifup.org>
	<20091029.211219.182331672.davem@davemloft.net>
	<20091030043050.GB3380@jenkins.home.ifup.org>
	<20091029.213816.35637194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bphilips@suse.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53037 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932394AbZJ3PfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 11:35:04 -0400
In-Reply-To: <20091029.213816.35637194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Why not fix the problem in a generic way?


---
Subject: ethtool: link is only up if device is running


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/ethtool.c	2009-10-30 08:32:52.584728610 -0700
+++ b/net/core/ethtool.c	2009-10-30 08:33:31.806667877 -0700
@@ -27,7 +27,7 @@
 
 u32 ethtool_op_get_link(struct net_device *dev)
 {
-	return netif_carrier_ok(dev) ? 1 : 0;
+	return netif_running(dev) && netif_carrier_ok(dev);
 }
 
 u32 ethtool_op_get_rx_csum(struct net_device *dev)
