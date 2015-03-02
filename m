From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 05/15] ax25/6pack: Replace sp_header_ops with ax25_header_ops
Date: Mon, 02 Mar 2015 00:03:45 -0600
Message-ID: <87oaoc7x6m.fsf_-_@x220.int.ebiederm.org>
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
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <87lhjg9byo.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 01 Mar 2015 23:59:11 -0600")
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The two sets of header operations are functionally identical remove
the duplicate definition.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-hams@vger.kernel.org
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/hamradio/6pack.c | 28 +---------------------------
 1 file changed, 1 insertion(+), 27 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index daca0dee88f3..2533933c79dc 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -284,18 +284,6 @@ static int sp_close(struct net_device *dev)
 	return 0;
 }
 
-/* Return the frame type ID */
-static int sp_header(struct sk_buff *skb, struct net_device *dev,
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
 static int sp_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr_ax25 *sa = addr;
@@ -309,20 +297,6 @@ static int sp_set_mac_address(struct net_device *dev, void *addr)
 	return 0;
 }
 
-static int sp_rebuild_header(struct sk_buff *skb)
-{
-#ifdef CONFIG_INET
-	return ax25_rebuild_header(skb);
-#else
-	return 0;
-#endif
-}
-
-static const struct header_ops sp_header_ops = {
-	.create		= sp_header,
-	.rebuild	= sp_rebuild_header,
-};
-
 static const struct net_device_ops sp_netdev_ops = {
 	.ndo_open		= sp_open_dev,
 	.ndo_stop		= sp_close,
@@ -337,7 +311,7 @@ static void sp_setup(struct net_device *dev)
 	dev->destructor		= free_netdev;
 	dev->mtu		= SIXP_MTU;
 	dev->hard_header_len	= AX25_MAX_HEADER_LEN;
-	dev->header_ops 	= &sp_header_ops;
+	dev->header_ops 	= &ax25_header_ops;
 
 	dev->addr_len		= AX25_ADDR_LEN;
 	dev->type		= ARPHRD_AX25;
-- 
2.2.1

