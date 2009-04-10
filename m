From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] igbvf: fix unused external references
Date: Fri, 10 Apr 2009 01:49:20 -0700
Message-ID: <20090410084920.14739.64516.stgit@localhost.localdomain>
References: <20090410084901.14739.20428.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:47111
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S939010AbZDJRRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 13:17:49 -0400
In-Reply-To: <20090410084901.14739.20428.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igbvbf driver exposed several unused extrnal references due to the fact
that code was copied from igb and then some functionality was removed.
This changes that so that unused functions are either removed or made
static.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/igbvf.h  |    3 ---
 drivers/net/igbvf/netdev.c |    9 ++++++---
 drivers/net/igbvf/vf.c     |    2 +-
 drivers/net/igbvf/vf.h     |    1 -
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index 936ed2a..4bff35e 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -321,14 +321,11 @@ extern void igbvf_set_ethtool_ops(struct net_device *);
 extern int igbvf_up(struct igbvf_adapter *);
 extern void igbvf_down(struct igbvf_adapter *);
 extern void igbvf_reinit_locked(struct igbvf_adapter *);
-extern void igbvf_reset(struct igbvf_adapter *);
 extern int igbvf_setup_rx_resources(struct igbvf_adapter *, struct igbvf_ring *);
 extern int igbvf_setup_tx_resources(struct igbvf_adapter *, struct igbvf_ring *);
 extern void igbvf_free_rx_resources(struct igbvf_ring *);
 extern void igbvf_free_tx_resources(struct igbvf_ring *);
 extern void igbvf_update_stats(struct igbvf_adapter *);
-extern void igbvf_set_interrupt_capability(struct igbvf_adapter *);
-extern void igbvf_reset_interrupt_capability(struct igbvf_adapter *);
 
 extern unsigned int copybreak;
 
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index c564842..b774666 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -52,6 +52,9 @@ static const char igbvf_driver_string[] =
 static const char igbvf_copyright[] = "Copyright (c) 2009 Intel Corporation.";
 
 static int igbvf_poll(struct napi_struct *napi, int budget);
+static void igbvf_reset(struct igbvf_adapter *);
+static void igbvf_set_interrupt_capability(struct igbvf_adapter *);
+static void igbvf_reset_interrupt_capability(struct igbvf_adapter *);
 
 static struct igbvf_info igbvf_vf_info = {
 	.mac                    = e1000_vfadapt,
@@ -990,7 +993,7 @@ static void igbvf_configure_msix(struct igbvf_adapter *adapter)
 	e1e_flush();
 }
 
-void igbvf_reset_interrupt_capability(struct igbvf_adapter *adapter)
+static void igbvf_reset_interrupt_capability(struct igbvf_adapter *adapter)
 {
 	if (adapter->msix_entries) {
 		pci_disable_msix(adapter->pdev);
@@ -1005,7 +1008,7 @@ void igbvf_reset_interrupt_capability(struct igbvf_adapter *adapter)
  * Attempt to configure interrupts using the best available
  * capabilities of the hardware and kernel.
  **/
-void igbvf_set_interrupt_capability(struct igbvf_adapter *adapter)
+static void igbvf_set_interrupt_capability(struct igbvf_adapter *adapter)
 {
 	int err = -ENOMEM;
 	int i;
@@ -1447,7 +1450,7 @@ static void igbvf_configure(struct igbvf_adapter *adapter)
  * set/changed during runtime. After reset the device needs to be
  * properly configured for Rx, Tx etc.
  */
-void igbvf_reset(struct igbvf_adapter *adapter)
+static void igbvf_reset(struct igbvf_adapter *adapter)
 {
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 	struct net_device *netdev = adapter->netdev;
diff --git a/drivers/net/igbvf/vf.c b/drivers/net/igbvf/vf.c
index aa246c9..2a4faf9 100644
--- a/drivers/net/igbvf/vf.c
+++ b/drivers/net/igbvf/vf.c
@@ -44,7 +44,7 @@ static s32 e1000_set_vfta_vf(struct e1000_hw *, u16, bool);
  *  e1000_init_mac_params_vf - Inits MAC params
  *  @hw: pointer to the HW structure
  **/
-s32 e1000_init_mac_params_vf(struct e1000_hw *hw)
+static s32 e1000_init_mac_params_vf(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 
diff --git a/drivers/net/igbvf/vf.h b/drivers/net/igbvf/vf.h
index ec07228..1e8ce37 100644
--- a/drivers/net/igbvf/vf.h
+++ b/drivers/net/igbvf/vf.h
@@ -259,7 +259,6 @@ struct e1000_hw {
 /* These functions must be implemented by drivers */
 void e1000_rlpml_set_vf(struct e1000_hw *, u16);
 void e1000_init_function_pointers_vf(struct e1000_hw *hw);
-s32  e1000_init_mac_params_vf(struct e1000_hw *hw);
 
 
 #endif /* _E1000_VF_H_ */

