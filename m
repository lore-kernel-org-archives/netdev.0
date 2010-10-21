From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/12] qlge: make local functions static
Date: Thu, 21 Oct 2010 10:50:54 -0700
Message-ID: <20101021175148.828292944@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: David Miller <davem@davemloft.net>,
	Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36321 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756434Ab0JUSBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:07 -0400
Content-Disposition: inline; filename=qlge-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/qlge/qlge.h      |    2 --
 drivers/net/qlge/qlge_main.c |    7 +++++--
 drivers/net/qlge/qlge_mpi.c  |    6 +++---
 3 files changed, 8 insertions(+), 7 deletions(-)

--- a/drivers/net/qlge/qlge.h	2010-10-21 09:45:37.330416381 -0700
+++ b/drivers/net/qlge/qlge.h	2010-10-21 09:54:17.264568433 -0700
@@ -2226,7 +2226,6 @@ int ql_dump_risc_ram_area(struct ql_adap
 int ql_core_dump(struct ql_adapter *qdev,
 		struct ql_mpi_coredump *mpi_coredump);
 int ql_mb_about_fw(struct ql_adapter *qdev);
-int ql_wol(struct ql_adapter *qdev);
 int ql_mb_wol_set_magic(struct ql_adapter *qdev, u32 enable_wol);
 int ql_mb_wol_mode(struct ql_adapter *qdev, u32 wol);
 int ql_mb_set_led_cfg(struct ql_adapter *qdev, u32 led_config);
@@ -2243,7 +2242,6 @@ netdev_tx_t ql_lb_send(struct sk_buff *s
 void ql_check_lb_frame(struct ql_adapter *, struct sk_buff *);
 int ql_own_firmware(struct ql_adapter *qdev);
 int ql_clean_lb_rx_ring(struct rx_ring *rx_ring, int budget);
-void qlge_set_multicast_list(struct net_device *ndev);
 
 #if 1
 #define QL_ALL_DUMP
--- a/drivers/net/qlge/qlge_main.c	2010-10-21 09:45:37.366420363 -0700
+++ b/drivers/net/qlge/qlge_main.c	2010-10-21 09:45:58.112710386 -0700
@@ -94,6 +94,9 @@ static DEFINE_PCI_DEVICE_TABLE(qlge_pci_
 
 MODULE_DEVICE_TABLE(pci, qlge_pci_tbl);
 
+static int ql_wol(struct ql_adapter *qdev);
+static void qlge_set_multicast_list(struct net_device *ndev);
+
 /* This hardware semaphore causes exclusive access to
  * resources shared between the NIC driver, MPI firmware,
  * FCOE firmware and the FC driver.
@@ -3842,7 +3845,7 @@ static void ql_display_dev_info(struct n
 		   "MAC address %pM\n", ndev->dev_addr);
 }
 
-int ql_wol(struct ql_adapter *qdev)
+static int ql_wol(struct ql_adapter *qdev)
 {
 	int status = 0;
 	u32 wol = MB_WOL_DISABLE;
@@ -4242,7 +4245,7 @@ static struct net_device_stats *qlge_get
 	return &ndev->stats;
 }
 
-void qlge_set_multicast_list(struct net_device *ndev)
+static void qlge_set_multicast_list(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 	struct netdev_hw_addr *ha;
--- a/drivers/net/qlge/qlge_mpi.c	2010-10-21 09:45:37.390423021 -0700
+++ b/drivers/net/qlge/qlge_mpi.c	2010-10-21 09:54:43.955281045 -0700
@@ -87,7 +87,7 @@ exit:
 	return status;
 }
 
-int ql_soft_reset_mpi_risc(struct ql_adapter *qdev)
+static int ql_soft_reset_mpi_risc(struct ql_adapter *qdev)
 {
 	int status;
 	status = ql_write_mpi_reg(qdev, 0x00001010, 1);
@@ -681,7 +681,7 @@ int ql_mb_get_fw_state(struct ql_adapter
 /* Send and ACK mailbox command to the firmware to
  * let it continue with the change.
  */
-int ql_mb_idc_ack(struct ql_adapter *qdev)
+static int ql_mb_idc_ack(struct ql_adapter *qdev)
 {
 	struct mbox_params mbc;
 	struct mbox_params *mbcp = &mbc;
@@ -744,7 +744,7 @@ int ql_mb_set_port_cfg(struct ql_adapter
 	return status;
 }
 
-int ql_mb_dump_ram(struct ql_adapter *qdev, u64 req_dma, u32 addr,
+static int ql_mb_dump_ram(struct ql_adapter *qdev, u64 req_dma, u32 addr,
 	u32 size)
 {
 	int status = 0;


