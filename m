From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 11/15] igbvf: add support for i350 VF device
Date: Fri, 24 Dec 2010 22:06:10 -0800
Message-ID: <1293257174-15498-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754Ab0LYGHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:07:09 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add support to igbvf for the new i350 virtual function device.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igbvf/igbvf.h  |    1 +
 drivers/net/igbvf/netdev.c |    9 +++++++++
 drivers/net/igbvf/vf.h     |    2 ++
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index 9d4d63e..990c329 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -97,6 +97,7 @@ struct igbvf_adapter;
 
 enum igbvf_boards {
 	board_vf,
+	board_i350_vf,
 };
 
 struct igbvf_queue_stats {
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 4fb023b..6352c81 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -64,8 +64,16 @@ static struct igbvf_info igbvf_vf_info = {
 	.init_ops               = e1000_init_function_pointers_vf,
 };
 
+static struct igbvf_info igbvf_i350_vf_info = {
+	.mac			= e1000_vfadapt_i350,
+	.flags			= 0,
+	.pba			= 10,
+	.init_ops		= e1000_init_function_pointers_vf,
+};
+
 static const struct igbvf_info *igbvf_info_tbl[] = {
 	[board_vf]              = &igbvf_vf_info,
+	[board_i350_vf]		= &igbvf_i350_vf_info,
 };
 
 /**
@@ -2865,6 +2873,7 @@ static struct pci_error_handlers igbvf_err_handler = {
 
 static DEFINE_PCI_DEVICE_TABLE(igbvf_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_VF), board_vf },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I350_VF), board_i350_vf },
 	{ } /* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, igbvf_pci_tbl);
diff --git a/drivers/net/igbvf/vf.h b/drivers/net/igbvf/vf.h
index c36ea21..d7ed58f 100644
--- a/drivers/net/igbvf/vf.h
+++ b/drivers/net/igbvf/vf.h
@@ -39,6 +39,7 @@
 struct e1000_hw;
 
 #define E1000_DEV_ID_82576_VF                 0x10CA
+#define E1000_DEV_ID_I350_VF                  0x1520
 #define E1000_REVISION_0 0
 #define E1000_REVISION_1 1
 #define E1000_REVISION_2 2
@@ -133,6 +134,7 @@ struct e1000_adv_tx_context_desc {
 enum e1000_mac_type {
 	e1000_undefined = 0,
 	e1000_vfadapt,
+	e1000_vfadapt_i350,
 	e1000_num_macs  /* List is 1-based, so subtract 1 for true count. */
 };
 
-- 
1.7.3.4

