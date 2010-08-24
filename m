From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] bridge: fix locking comment
Date: Tue, 24 Aug 2010 16:08:10 -0700
Message-ID: <20100824160810.2fd5007c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50622 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756619Ab0HXXIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 19:08:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The carrier check is not called from work queue in current code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_if.c	2010-08-20 15:17:26.306400002 -0700
+++ b/net/bridge/br_if.c	2010-08-20 15:18:20.826400002 -0700
@@ -61,11 +61,7 @@ static int port_cost(struct net_device *
 }
 
 
-/*
- * Check for port carrier transistions.
- * Called from work queue to allow for calling functions that
- * might sleep (such as speed check), and to debounce.
- */
+/* Check for port carrier transistions. */
 void br_port_carrier_check(struct net_bridge_port *p)
 {
 	struct net_device *dev = p->dev;
