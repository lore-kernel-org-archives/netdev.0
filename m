From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 4/4] qlcnic: Fix API unlock
Date: Fri, 3 Feb 2012 15:45:44 -0800
Message-ID: <1328312745-19245-4-git-send-email-sony.chacko@qlogic.com>
References: <1328312745-19245-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <manish.chopra@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:53634
	"EHLO AM1EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753925Ab2BDABn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 19:01:43 -0500
In-Reply-To: <1328312745-19245-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

Log dump status.
Remove unmatched qlcnic_api_unlock call.
Update version to 5.0.26.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 60976fc..2b5af22 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -37,7 +37,7 @@
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
 #define _QLCNIC_LINUX_SUBVERSION 25
-#define QLCNIC_LINUX_VERSIONID  "5.0.25"
+#define QLCNIC_LINUX_VERSIONID  "5.0.26"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 6b2cf8b..30dcbfb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1152,7 +1152,6 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 
 	if (!fw_dump->clr) {
 		netdev_info(netdev, "Dump not available\n");
-		qlcnic_api_unlock(adapter);
 		return -EINVAL;
 	}
 	/* Copy template header first */
@@ -1171,7 +1170,7 @@ qlcnic_get_dump_data(struct net_device *netdev, struct ethtool_dump *dump,
 	vfree(fw_dump->data);
 	fw_dump->data = NULL;
 	fw_dump->clr = 0;
-
+	netdev_info(netdev, "extracted the FW dump Successfully\n");
 	return 0;
 }
 
@@ -1189,7 +1188,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 			return ret;
 		}
 		if (fw_dump->clr) {
-			dev_info(&adapter->pdev->dev,
+			netdev_info(netdev,
 			"Previous dump not cleared, not forcing dump\n");
 			return ret;
 		}
-- 
1.6.4.4
