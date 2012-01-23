From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net PATCH 1/1] qlge:Changing netdev msg level to default debug
Date: Mon, 23 Jan 2012 15:38:52 -0800
Message-ID: <1327361932-28774-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe002.messaging.microsoft.com ([213.199.154.205]:31303
	"EHLO AM1EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756443Ab2AWXyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 18:54:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver was passing -1 so that custom default get used but which
makes it even more sane than 15 which was excessively verbose
printing an unusual amount of messages.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   17 +++--------------
 1 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index b548987..6ad006a 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -52,19 +52,8 @@ MODULE_DESCRIPTION(DRV_STRING " ");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-static const u32 default_msg =
-    NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK |
-/* NETIF_MSG_TIMER |	*/
-    NETIF_MSG_IFDOWN |
-    NETIF_MSG_IFUP |
-    NETIF_MSG_RX_ERR |
-    NETIF_MSG_TX_ERR |
-/*  NETIF_MSG_TX_QUEUED | */
-/*  NETIF_MSG_INTR | NETIF_MSG_TX_DONE | NETIF_MSG_RX_STATUS | */
-/* NETIF_MSG_PKTDATA | */
-    NETIF_MSG_HW | NETIF_MSG_WOL | 0;
-
-static int debug = -1;	/* defaults above */
+#define DEFAULT_DEBUG_MSG_LEVEL 3
+static int debug = DEFAULT_DEBUG_MSG_LEVEL;
 module_param(debug, int, 0664);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
@@ -4614,7 +4603,7 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 		err = -EIO;
 		goto err_out2;
 	}
-	qdev->msg_enable = netif_msg_init(debug, default_msg);
+	qdev->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_MSG_LEVEL);
 	spin_lock_init(&qdev->hw_lock);
 	spin_lock_init(&qdev->stats_lock);
 
-- 
1.7.6.rc1.1.g2c162b
