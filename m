From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] nlmon: use core MTU range checking in nlmon driver
Date: Wed,  7 Dec 2016 17:26:05 +0800
Message-ID: <1481102765-12021-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: jarod@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:44092 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752366AbcLGJ00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:26:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 61e84623ace3 ("net: centralize net_device min/max MTU checking"),
mtu range is checked at dev_set_mtu().

This patch adds min_mtu for nlmon device and remove unnecessary
ndo_change_mtu() function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/nlmon.c | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index 7b7c70e..2de7fae 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -27,24 +27,6 @@ static netdev_tx_t nlmon_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static int nlmon_is_valid_mtu(int new_mtu)
-{
-	/* Note that in netlink we do not really have an upper limit. On
-	 * default, we use NLMSG_GOODSIZE. Here at least we should make
-	 * sure that it's at least the header size.
-	 */
-	return new_mtu >= (int) sizeof(struct nlmsghdr);
-}
-
-static int nlmon_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if (!nlmon_is_valid_mtu(new_mtu))
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 static int nlmon_dev_init(struct net_device *dev)
 {
 	dev->lstats = netdev_alloc_pcpu_stats(struct pcpu_lstats);
@@ -124,7 +106,6 @@ static u32 always_on(struct net_device *dev)
 	.ndo_stop = nlmon_close,
 	.ndo_start_xmit = nlmon_xmit,
 	.ndo_get_stats64 = nlmon_get_stats64,
-	.ndo_change_mtu = nlmon_change_mtu,
 };
 
 static void nlmon_setup(struct net_device *dev)
@@ -145,6 +126,7 @@ static void nlmon_setup(struct net_device *dev)
 	 * expected in most cases.
 	 */
 	dev->mtu = NLMSG_GOODSIZE;
+	dev->min_mtu = sizeof(struct nlmsghdr);
 }
 
 static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.8.3.1
