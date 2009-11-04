From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH]  bridge: prevent bridging wrong device
Date: Wed, 4 Nov 2009 09:47:13 -0800
Message-ID: <20091104094713.1983a0b6@nehalam>
References: <846C5B546E47494CBBD796CA8CA1617EA3B431@MST-VMAIL1.srv.mst.edu>
	<20091029151222.156945ca@nehalam>
	<20091029152408.6c6cc29f@nehalam>
	<20091102.000756.222203879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nneul@mst.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47463 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755362AbZKDRre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 12:47:34 -0500
In-Reply-To: <20091102.000756.222203879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The bridge code assumes ethernet addressing, so be more strict in
the what is allowed. This showed up when GRE had a bug and was not
using correct address format.

Add some more comments for increased clarity.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_if.c	2009-10-29 15:18:48.363916679 -0700
+++ b/net/bridge/br_if.c	2009-11-03 19:39:17.733252912 -0800
@@ -377,12 +377,16 @@ int br_add_if(struct net_bridge *br, str
 	struct net_bridge_port *p;
 	int err = 0;
 
-	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
+	/* Don't allow bridging non-ethernet like devices */
+	if ((dev->flags & IFF_LOOPBACK) ||
+	    dev->type != ARPHRD_ETHER || dev->addr_len != ETH_ALEN)
 		return -EINVAL;
 
+	/* No bridging of bridges */
 	if (dev->netdev_ops->ndo_start_xmit == br_dev_xmit)
 		return -ELOOP;
 
+	/* Device is already being bridged */
 	if (dev->br_port != NULL)
 		return -EBUSY;
 
