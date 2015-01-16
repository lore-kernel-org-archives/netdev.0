From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next 5/5] bonding: cleanup and remove dead code
Date: Fri, 16 Jan 2015 10:57:28 -0500
Message-ID: <1421423848-414-6-git-send-email-jtoppins@cumulusnetworks.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: Jonathan Toppins <jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:45562 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756546AbbAPP5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 10:57:46 -0500
Received: by mail-qg0-f51.google.com with SMTP id i50so16842438qgf.10
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 07:57:45 -0800 (PST)
In-Reply-To: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix sparse warning about non-static function

drivers/net/bonding/bond_main.c:3737:5: warning: symbol
'bond_3ad_xor_xmit' was not declared. Should it be static?

Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 include/net/bond_3ad.h          |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c475d90..67437f3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3734,7 +3734,7 @@ out:
  * usable slave array is formed in the control path. The xmit function
  * just calculates hash and sends the packet out.
  */
-int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
+static int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bonding *bond = netdev_priv(dev);
 	struct slave *slave;
diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
index e01d903..f04cdbb 100644
--- a/include/net/bond_3ad.h
+++ b/include/net/bond_3ad.h
@@ -274,7 +274,6 @@ void bond_3ad_handle_link_change(struct slave *slave, char link);
 int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
 int  __bond_3ad_get_active_agg_info(struct bonding *bond,
 				    struct ad_info *ad_info);
-int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
 int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
-- 
1.7.10.4
