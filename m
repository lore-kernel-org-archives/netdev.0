From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 1/3] netxen: fix link event handling
Date: Tue, 28 Apr 2009 18:29:09 -0700
Message-ID: <1240968551-13186-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33179 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753915AbZD2B3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 21:29:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware starting 4.0.402 started supporting link events, disable
it for older firmwares.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c  |    1 +
 drivers/net/netxen/netxen_nic_main.c     |    2 +-
 drivers/net/netxen/netxen_nic_phan_reg.h |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index a452b2f..e16ea46 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -247,6 +247,7 @@ skip:
 		case LINKEVENT_MODULE_TWINAX_UNSUPPORTED_CABLELEN:
 		case LINKEVENT_MODULE_TWINAX:
 			ecmd->port = PORT_TP;
+			break;
 		default:
 			ecmd->port = -1;
 		}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index e877eef..8331580 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -797,7 +797,7 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (adapter->max_sds_rings > 1)
 		netxen_config_rss(adapter, 1);
 
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+	if (adapter->capabilities & NX_FW_CAPABILITY_LINK_NOTIFICATION)
 		netxen_linkevent_request(adapter, 1);
 
 	return 0;
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 845dcf4..b73a62c 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -126,6 +126,7 @@
 #define CRB_SW_INT_MASK_2	   NETXEN_NIC_REG(0x1e4)
 #define CRB_SW_INT_MASK_3	   NETXEN_NIC_REG(0x1e8)
 
+#define CRB_FW_CAPABILITIES_1      NETXEN_CAM_RAM(0x128)
 #define CRB_MAC_BLOCK_START        NETXEN_CAM_RAM(0x1c0)
 
 /*
@@ -136,7 +137,6 @@
 #define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
 #define CRB_NIC_MSI_MODE_HOST		NETXEN_NIC_REG(0x270)
 #define CRB_NIC_MSI_MODE_FW	  	NETXEN_NIC_REG(0x274)
-#define CRB_FW_CAPABILITIES_1		NETXEN_NIC_REG(0x128)
 
 #define INTR_SCHEME_PERPORT	      	0x1
 #define MSI_MODE_MULTIFUNC	      	0x1
-- 
1.6.0.2

