From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH net-next v2 5/5] bonding: cleanup and remove dead code
Date: Mon, 26 Jan 2015 01:17:01 -0500
Message-ID: <1422253021-3798-6-git-send-email-jtoppins@cumulusnetworks.com>
References: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:60423 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbbAZGUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 01:20:19 -0500
Received: by mail-qc0-f171.google.com with SMTP id s11so5694275qcv.2
        for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 22:20:19 -0800 (PST)
In-Reply-To: <1422253021-3798-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix sparse warning about non-static function

drivers/net/bonding/bond_main.c:3737:5: warning: symbol
'bond_3ad_xor_xmit' was not declared. Should it be static?

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
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
