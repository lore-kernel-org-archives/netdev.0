From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 3/3] qlcnic: change module parameter permissions
Date: Mon, 10 Jan 2011 02:15:23 -0800
Message-ID: <1294654523-3085-4-git-send-email-amit.salecha@qlogic.com>
References: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:42614 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753410Ab1AJKPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 05:15:41 -0500
In-Reply-To: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Updating module parameter after driver load is not supported
  except auto_fw_reset parameter. Changing these parameter after
  driver load, can have weird result.

o Update driver version to 5.0.15.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    4 ++--
 drivers/net/qlcnic/qlcnic_main.c |   10 +++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 14b6322..44e316f 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -34,8 +34,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 14
-#define QLCNIC_LINUX_VERSIONID  "5.0.14"
+#define _QLCNIC_LINUX_SUBVERSION 15
+#define QLCNIC_LINUX_VERSIONID  "5.0.15"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 11e3a46..37c04b4 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -31,15 +31,15 @@ static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
 
 static struct workqueue_struct *qlcnic_wq;
 static int qlcnic_mac_learn;
-module_param(qlcnic_mac_learn, int, 0644);
+module_param(qlcnic_mac_learn, int, 0444);
 MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
 
 static int use_msi = 1;
-module_param(use_msi, int, 0644);
+module_param(use_msi, int, 0444);
 MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled");
 
 static int use_msi_x = 1;
-module_param(use_msi_x, int, 0644);
+module_param(use_msi_x, int, 0444);
 MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled");
 
 static int auto_fw_reset = AUTO_FW_RESET_ENABLED;
@@ -47,11 +47,11 @@ module_param(auto_fw_reset, int, 0644);
 MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled");
 
 static int load_fw_file;
-module_param(load_fw_file, int, 0644);
+module_param(load_fw_file, int, 0444);
 MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");
 
 static int qlcnic_config_npars;
-module_param(qlcnic_config_npars, int, 0644);
+module_param(qlcnic_config_npars, int, 0444);
 MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled");
 
 static int __devinit qlcnic_probe(struct pci_dev *pdev,
-- 
1.7.3.2

