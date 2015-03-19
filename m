From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4/cxgb4vf/csiostor: Make PCI Device ID Tables be "const"
Date: Thu, 19 Mar 2015 22:27:36 +0530
Message-ID: <1426784256-5689-3-git-send-email-hariprasad@chelsio.com>
References: <1426784256-5689-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13344 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751202AbbCSQwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:52:13 -0400
In-Reply-To: <1426784256-5689-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make PCI Device ID Tables be "const" to move them out of the data segment and
remove a redundant check on CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN in
t4_pci_id_tbl.h to guard the contents of the include file.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h |    4 ----
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 +-
 drivers/scsi/csiostor/csio_init.c                  |    2 +-
 4 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4af8a9f..dd4b2da 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -124,7 +124,7 @@ struct filter_entry {
 /* Macros needed to support the PCI Device ID Table ...
  */
 #define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-	static struct pci_device_id cxgb4_pci_tbl[] = {
+	static const struct pci_device_id cxgb4_pci_tbl[] = {
 #define CH_PCI_DEVICE_ID_FUNCTION 0x4
 
 /* Include PCI Device IDs for both PF4 and PF0-3 so our PCI probe() routine is
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index ee877c0..1a9a6f3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -60,8 +60,6 @@
  *   -- Used to finish the definition of the PCI ID Table.  Note that we
  *   -- will be adding a trailing semi-colon (";") here.
  */
-#ifdef CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
-
 #ifndef CH_PCI_DEVICE_ID_FUNCTION
 #error CH_PCI_DEVICE_ID_FUNCTION not defined!
 #endif
@@ -157,6 +155,4 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5090),	/* Custom T540-CR */
 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
 
-#endif /* CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN */
-
 #endif /* __T4_PCI_ID_TBL_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 122e296..1d893b0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -3034,7 +3034,7 @@ static void cxgb4vf_pci_shutdown(struct pci_dev *pdev)
 /* Macros needed to support the PCI Device ID Table ...
  */
 #define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-	static struct pci_device_id cxgb4vf_pci_tbl[] = {
+	static const struct pci_device_id cxgb4vf_pci_tbl[] = {
 #define CH_PCI_DEVICE_ID_FUNCTION	0x8
 
 #define CH_PCI_ID_TABLE_ENTRY(devid) \
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index d9631e1..dbe416f 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -1172,7 +1172,7 @@ static struct pci_error_handlers csio_err_handler = {
  *  Macros needed to support the PCI Device ID Table ...
  */
 #define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-	static struct pci_device_id csio_pci_tbl[] = {
+	static const struct pci_device_id csio_pci_tbl[] = {
 /* Define for FCoE uses PF6 */
 #define CH_PCI_DEVICE_ID_FUNCTION	0x6
 
-- 
1.7.1
