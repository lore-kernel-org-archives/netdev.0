From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net] qlcnic: Bug fix for LRO
Date: Fri, 23 Mar 2012 09:32:34 -0700
Message-ID: <1332520354-22519-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:18470
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752294Ab2CWQq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 12:46:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Anirban

 - After FW reset, IP addresses need to be reprogrammed to FW for LRO to work. This
   was not happening in context reset path. Fixed it here.
 - Updated driver version to 5.0.27

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 +++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 2b5af22..385a4d5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -36,8 +36,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 25
-#define QLCNIC_LINUX_VERSIONID  "5.0.26"
+#define _QLCNIC_LINUX_SUBVERSION 27
+#define QLCNIC_LINUX_VERSIONID  "5.0.27"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 81bb1a6..75c32e8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1458,8 +1458,10 @@ qlcnic_reset_context(struct qlcnic_adapter *adapter)
 
 		if (netif_running(netdev)) {
 			err = qlcnic_attach(adapter);
-			if (!err)
+			if (!err) {
 				__qlcnic_up(adapter, netdev);
+				qlcnic_restore_indev_addr(netdev, NETDEV_UP);
+			}
 		}
 
 		netif_device_attach(netdev);
-- 
1.7.1
