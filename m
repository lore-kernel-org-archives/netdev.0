From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] igb: mark igb_rxnfc_write_vlan_prio_filter() static
Date: Sun, 25 Sep 2016 14:05:58 +0800
Message-ID: <1474783558-7384-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34075 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934317AbcIYGGJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 02:06:09 -0400
Received: by mail-pa0-f49.google.com with SMTP id zl8so2208704pac.1
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 23:06:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 1 warning when building kernel with W=1:
drivers/net/ethernet/intel/igb/igb_ethtool.c:2707:5: warning: no previous prototype for 'igb_rxnfc_write_vlan_prio_filter' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
so this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 0c33eca..737b664 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2704,8 +2704,8 @@ static int igb_rxnfc_write_etype_filter(struct igb_adapter *adapter,
 	return 0;
 }
 
-int igb_rxnfc_write_vlan_prio_filter(struct igb_adapter *adapter,
-				     struct igb_nfc_filter *input)
+static int igb_rxnfc_write_vlan_prio_filter(struct igb_adapter *adapter,
+					    struct igb_nfc_filter *input)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u8 vlan_priority;
-- 
2.7.4
