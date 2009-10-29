From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] bridge: check address size
Date: Thu, 29 Oct 2009 15:24:08 -0700
Message-ID: <20091029152408.6c6cc29f@nehalam>
References: <846C5B546E47494CBBD796CA8CA1617EA3B414@MST-VMAIL1.srv.mst.edu>
	<20091029170631.GA29405@gondor.apana.org.au>
	<846C5B546E47494CBBD796CA8CA1617EA3B428@MST-VMAIL1.srv.mst.edu>
	<20091029130036.1e61f415@nehalam>
	<846C5B546E47494CBBD796CA8CA1617EA3B431@MST-VMAIL1.srv.mst.edu>
	<20091029151222.156945ca@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Neulinger, Nathan" <nneul@mst.edu>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54942 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756743AbZJ2WYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 18:24:09 -0400
In-Reply-To: <20091029151222.156945ca@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check the address size of underlying device because the bridge assumes
the underlying device has ethernet address format. See forwarding table
and STP, for places where this true.

Also, add some comments to explain errors.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_if.c	2009-10-29 15:18:48.363916679 -0700
+++ b/net/bridge/br_if.c	2009-10-29 15:21:38.142667043 -0700
@@ -377,12 +377,17 @@ int br_add_if(struct net_bridge *br, str
 	struct net_bridge_port *p;
 	int err = 0;
 
-	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
+	/* Don't allow bridging non ethernet like devices */
+	if (dev->flags & IFF_LOOPBACK
+	    || dev->type != ARPHRD_ETHER
+	    || dev->addr_len != ETH_ALEN)
 		return -EINVAL;
 
+	/* No bridging of bridges */
 	if (dev->netdev_ops->ndo_start_xmit == br_dev_xmit)
 		return -ELOOP;
 
+	/* Device is already being bridged */
 	if (dev->br_port != NULL)
 		return -EBUSY;
 

