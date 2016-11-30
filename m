From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: ipvlan: Remove useless member mtu_adj of struct ipvl_dev
Date: Wed, 30 Nov 2016 08:48:44 +0800
Message-ID: <1480466924-2436-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:54936 "EHLO smtpbg291.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752167AbcK3Atb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 19:49:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The mtu_adj is initialized to zero when alloc mem, there is no any
assignment to mtu_adj. It is only used in ipvlan_adjust_mtu as one
right value.
So it is useless member of struct ipvl_dev, then remove it.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/ipvlan/ipvlan.h      | 1 -
 drivers/net/ipvlan/ipvlan_main.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 7e0732f..05a62d2 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -73,7 +73,6 @@ struct ipvl_dev {
 	DECLARE_BITMAP(mac_filters, IPVLAN_MAC_FILTER_SIZE);
 	netdev_features_t	sfeatures;
 	u32			msg_enable;
-	u16			mtu_adj;
 };
 
 struct ipvl_addr {
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index ab90b22..c6aa667 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -32,7 +32,7 @@
 
 static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
 {
-	ipvlan->dev->mtu = dev->mtu - ipvlan->mtu_adj;
+	ipvlan->dev->mtu = dev->mtu;
 }
 
 static int ipvlan_register_nf_hook(void)
-- 
1.9.1
