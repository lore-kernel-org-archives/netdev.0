From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/20] igb: rename igb define to be more generic
Date: Tue, 23 Feb 2016 20:26:19 -0800
Message-ID: <1456287984-10459-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757478AbcBXE0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:35 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

E1000_MRQC_ENABLE_RSS_4Q enables 4 and 8 queues depending on the part
so rename to be generic.

Similarly, E1000_MRQC_ENABLE_VMDQ_RSS_2Q has no numeric meaning so
rename to be more generic.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h | 4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index 2154aea..de8805a 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -56,10 +56,10 @@ s32 igb_write_i2c_byte(struct e1000_hw *hw, u8 byte_offset, u8 dev_addr,
 #define E1000_SRRCTL_TIMESTAMP                          0x40000000
 
 
-#define E1000_MRQC_ENABLE_RSS_4Q            0x00000002
+#define E1000_MRQC_ENABLE_RSS_MQ            0x00000002
 #define E1000_MRQC_ENABLE_VMDQ              0x00000003
 #define E1000_MRQC_RSS_FIELD_IPV4_UDP       0x00400000
-#define E1000_MRQC_ENABLE_VMDQ_RSS_2Q       0x00000005
+#define E1000_MRQC_ENABLE_VMDQ_RSS_MQ       0x00000005
 #define E1000_MRQC_RSS_FIELD_IPV6_UDP       0x00800000
 #define E1000_MRQC_RSS_FIELD_IPV6_UDP_EX    0x01000000
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index cd3708b..855eebf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3584,12 +3584,12 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 			wr32(E1000_VT_CTL, vtctl);
 		}
 		if (adapter->rss_queues > 1)
-			mrqc |= E1000_MRQC_ENABLE_VMDQ_RSS_2Q;
+			mrqc |= E1000_MRQC_ENABLE_VMDQ_RSS_MQ;
 		else
 			mrqc |= E1000_MRQC_ENABLE_VMDQ;
 	} else {
 		if (hw->mac.type != e1000_i211)
-			mrqc |= E1000_MRQC_ENABLE_RSS_4Q;
+			mrqc |= E1000_MRQC_ENABLE_RSS_MQ;
 	}
 
 	igb_vmm_control(adapter);
-- 
2.5.0
