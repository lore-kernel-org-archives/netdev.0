From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] intel: pci_register_driver tail return
Date: Thu, 5 Sep 2013 10:22:04 -0700
Message-ID: <20130905102204.7bb21dd0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:38663 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab3IERWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 13:22:09 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so2067285pbb.24
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 10:22:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary assignment, just return result of pci_register_driver
Glad to see that Intel does lots of code reuse :-)

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/ethernet/intel/e1000e/netdev.c        |    5 +----
 drivers/net/ethernet/intel/igb/igb_main.c         |    4 +---
 drivers/net/ethernet/intel/igbvf/netdev.c         |    5 +----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    4 +---
 4 files changed, 4 insertions(+), 14 deletions(-)

--- a/drivers/net/ethernet/intel/e1000e/netdev.c	2013-08-25 20:40:29.798995725 -0700
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c	2013-09-05 10:18:11.322040468 -0700
@@ -7054,13 +7054,10 @@ static struct pci_driver e1000_driver =
  **/
 static int __init e1000_init_module(void)
 {
-	int ret;
 	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
 		e1000e_driver_version);
 	pr_info("Copyright(c) 1999 - 2013 Intel Corporation.\n");
-	ret = pci_register_driver(&e1000_driver);
-
-	return ret;
+	return pci_register_driver(&e1000_driver);
 }
 module_init(e1000_init_module);
 
--- a/drivers/net/ethernet/intel/igb/igb_main.c	2013-09-05 08:10:16.494868469 -0700
+++ b/drivers/net/ethernet/intel/igb/igb_main.c	2013-09-05 09:52:11.914731506 -0700
@@ -680,7 +680,6 @@ struct net_device *igb_get_hw_dev(struct
  **/
 static int __init igb_init_module(void)
 {
-	int ret;
 	pr_info("%s - version %s\n",
 	       igb_driver_string, igb_driver_version);
 
@@ -689,8 +688,7 @@ static int __init igb_init_module(void)
 #ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
 #endif
-	ret = pci_register_driver(&igb_driver);
-	return ret;
+	return pci_register_driver(&igb_driver);
 }
 
 module_init(igb_init_module);
--- a/drivers/net/ethernet/intel/igbvf/netdev.c	2013-08-10 10:36:10.293516206 -0700
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c	2013-09-05 09:55:11.644534238 -0700
@@ -2891,13 +2891,10 @@ static struct pci_driver igbvf_driver =
  **/
 static int __init igbvf_init_module(void)
 {
-	int ret;
 	pr_info("%s - version %s\n", igbvf_driver_string, igbvf_driver_version);
 	pr_info("%s\n", igbvf_copyright);
 
-	ret = pci_register_driver(&igbvf_driver);
-
-	return ret;
+	return pci_register_driver(&igbvf_driver);
 }
 module_init(igbvf_init_module);
 
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c	2013-09-05 08:10:16.494868469 -0700
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c	2013-09-05 09:53:27.937592738 -0700
@@ -3614,14 +3614,12 @@ static struct pci_driver ixgbevf_driver
  **/
 static int __init ixgbevf_init_module(void)
 {
-	int ret;
 	pr_info("%s - version %s\n", ixgbevf_driver_string,
 		ixgbevf_driver_version);
 
 	pr_info("%s\n", ixgbevf_copyright);
 
-	ret = pci_register_driver(&ixgbevf_driver);
-	return ret;
+	return pci_register_driver(&ixgbevf_driver);
 }
 
 module_init(ixgbevf_init_module);
