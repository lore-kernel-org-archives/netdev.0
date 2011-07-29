From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 5/5] qlcnic: Added debug info
Date: Fri, 29 Jul 2011 16:30:29 -0700
Message-ID: <1311982230-10543-5-git-send-email-anirban.chakraborty@qlogic.com>
References: <1311982230-10543-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:25747
	"EHLO VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753211Ab1G2Xjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 19:39:52 -0400
In-Reply-To: <1311982230-10543-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Now printing states of essential registers once fw hang has been detected.
Bumped up the driver version to 5.0.22

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    4 ++--
 drivers/net/qlcnic/qlcnic_main.c |   13 ++++++++++++-
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 5f0141b..53c6e5d 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -36,8 +36,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 21
-#define QLCNIC_LINUX_VERSIONID  "5.0.21"
+#define _QLCNIC_LINUX_SUBVERSION 22
+#define QLCNIC_LINUX_VERSIONID  "5.0.22"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index d287a2b..ec8ef72 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -3109,7 +3109,18 @@ qlcnic_check_health(struct qlcnic_adapter *adapter)
 		clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
 
 	dev_info(&netdev->dev, "firmware hang detected\n");
-
+	dev_info(&adapter->pdev->dev, "Dumping hw/fw registers\n"
+			"PEG_HALT_STATUS1: 0x%x, PEG_HALT_STATUS2: 0x%x,\n"
+			"PEG_NET_0_PC: 0x%x, PEG_NET_1_PC: 0x%x,\n"
+			"PEG_NET_2_PC: 0x%x, PEG_NET_3_PC: 0x%x,\n"
+			"PEG_NET_4_PC: 0x%x\n",
+			QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS1),
+			QLCRD32(adapter, QLCNIC_PEG_HALT_STATUS2),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c),
+			QLCRD32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c));
 detach:
 	adapter->dev_state = (state == QLCNIC_DEV_NEED_QUISCENT) ? state :
 		QLCNIC_DEV_NEED_RESET;
-- 
1.7.4.1


