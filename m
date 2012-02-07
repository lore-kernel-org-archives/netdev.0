From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] caif: remove duplicate initialization
Date: Tue, 7 Feb 2012 10:20:15 +0300
Message-ID: <20120207072015.GB21047@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:42967 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537Ab2BGHUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 02:20:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"priv" is initialized twice.  I kept the second one, because it is next
to the check for NULL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index a751d9b..e866234 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -72,13 +72,12 @@ static void robust_list_del(struct list_head *delete_node)
 static int chnl_recv_cb(struct cflayer *layr, struct cfpkt *pkt)
 {
 	struct sk_buff *skb;
-	struct chnl_net *priv  = container_of(layr, struct chnl_net, chnl);
+	struct chnl_net *priv;
 	int pktlen;
 	const u8 *ip_version;
 	u8 buf;
 
 	priv = container_of(layr, struct chnl_net, chnl);
-
 	if (!priv)
 		return -EINVAL;
 
