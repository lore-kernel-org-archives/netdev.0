From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 04/15] ax25/kiss: Replace ax_header_ops with ax25_header_ops
Date: Mon, 02 Mar 2015 00:03:02 -0600
Message-ID: <87twy47x7t.fsf_-_@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
	<871tl8dlxn.fsf@x220.int.ebiederm.org>
	<87lhjg9byo.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53229 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbCBGGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 01:06:35 -0500
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The two sets of header operations are functionally identical remove the
duplicate definition.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/hamradio/mkiss.c | 33 +--------------------------------
 1 file changed, 1 insertion(+), 32 deletions(-)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index f990bb1c3e02..e37c8d515ce8 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -573,32 +573,6 @@ static int ax_open_dev(struct net_device *dev)
 	return 0;
 }
 
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-
-/* Return the frame type ID */
-static int ax_header(struct sk_buff *skb, struct net_device *dev,
-		     unsigned short type, const void *daddr,
-		     const void *saddr, unsigned len)
-{
-#ifdef CONFIG_INET
-	if (type != ETH_P_AX25)
-		return ax25_hard_header(skb, dev, type, daddr, saddr, len);
-#endif
-	return 0;
-}
-
-
-static int ax_rebuild_header(struct sk_buff *skb)
-{
-#ifdef CONFIG_INET
-	return ax25_rebuild_header(skb);
-#else
-	return 0;
-#endif
-}
-
-#endif	/* CONFIG_{AX25,AX25_MODULE} */
-
 /* Open the low-level part of the AX25 channel. Easy! */
 static int ax_open(struct net_device *dev)
 {
@@ -662,11 +636,6 @@ static int ax_close(struct net_device *dev)
 	return 0;
 }
 
-static const struct header_ops ax_header_ops = {
-	.create    = ax_header,
-	.rebuild   = ax_rebuild_header,
-};
-
 static const struct net_device_ops ax_netdev_ops = {
 	.ndo_open            = ax_open_dev,
 	.ndo_stop            = ax_close,
@@ -682,7 +651,7 @@ static void ax_setup(struct net_device *dev)
 	dev->addr_len        = 0;
 	dev->type            = ARPHRD_AX25;
 	dev->tx_queue_len    = 10;
-	dev->header_ops      = &ax_header_ops;
+	dev->header_ops      = &ax25_header_ops;
 	dev->netdev_ops	     = &ax_netdev_ops;
 
 
-- 
2.2.1
