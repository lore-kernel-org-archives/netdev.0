From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/4] igb: fix error code in igb_add_ethtool_nfc_entry()
Date: Thu, 18 Aug 2016 22:30:50 -0700
Message-ID: <1471584650-14645-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471584650-14645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Gangfeng Huang <gangfeng.huang@ni.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41875 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754874AbcHSFaz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 01:30:55 -0400
In-Reply-To: <1471584650-14645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gangfeng Huang <gangfeng.huang@ni.com>

Use error "rmgr: Cannot insert RX class rule: Operation not supported" is
more meaningful than "rmgr: Cannot insert RX class rule: Unknown error 524"

Signed-off-by: Gangfeng Huang <gangfeng.huang@ni.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index ef5408b..0c33eca 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2851,7 +2851,7 @@ static int igb_add_ethtool_nfc_entry(struct igb_adapter *adapter,
 	int err = 0;
 
 	if (!(netdev->hw_features & NETIF_F_NTUPLE))
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 
 	/* Don't allow programming if the action is a queue greater than
 	 * the number of online Rx queues.
-- 
2.7.4
