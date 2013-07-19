From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] arcnet: cleanup sizeof parameter
Date: Fri, 19 Jul 2013 08:48:05 +0300
Message-ID: <20130719054805.GB9729@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27611 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965404Ab3GSFsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 01:48:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch doesn't change the compiled code because ARC_HDR_SIZE is 4
and sizeof(int) is 4, but the intent was to use the header size and not
the sizeof the header size.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index a746ba2..a956053 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -1007,7 +1007,7 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
 
 	soft = &pkt.soft.rfc1201;
 
-	lp->hw.copy_from_card(dev, bufnum, 0, &pkt, sizeof(ARC_HDR_SIZE));
+	lp->hw.copy_from_card(dev, bufnum, 0, &pkt, ARC_HDR_SIZE);
 	if (pkt.hard.offset[0]) {
 		ofs = pkt.hard.offset[0];
 		length = 256 - ofs;
