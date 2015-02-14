From: Joe Perches <joe@perches.com>
Subject: chelsio: Use a more common const struct pci_device_id foo[] style
Date: Fri, 13 Feb 2015 18:05:50 -0800
Message-ID: <1423879550.2795.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-scsi <linux-scsi@vger.kernel.org>
To: Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0026.hostedemail.com ([216.40.44.26]:59410 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753881AbbBNCFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 21:05:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chelsio code shares a pci_device_table from an #include file.
Make the include guard simpler and make the arrays const.

Reduces data by moving tables to text.

Removed unnecessary macros:
o CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
o CH_PCI_DEVICE_ID_TABLE_DEFINE_END
o CH_PCI_ID_TABLE_ENTRY (moved to the .h file)
Added new macro define:
o CH_PCI_ID_TABLE_ENTRY_DATA

  text	   data	    bss	    dec	    hex	filename
  50550	    923	    172	  51645	   c9bd	drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.o.new
  46935	   4531	    172	  51638	   c9b6	drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.o.old
  27864	    355	      8	  28227	   6e43	drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.o.new
  26072	   2203	      8	  28283	   6e7b	drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.o.old
   9734	    450	     24	  10208	   27e0	drivers/scsi/csiostor/csio_init.o.new
   7942	   2242	     24	  10208	   27e0	drivers/scsi/csiostor/csio_init.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 17 ++++------
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 38 ++++++++--------------
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 10 ++----
 drivers/scsi/csiostor/csio_init.c                  | 11 +++----
 4 files changed, 27 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a22cf93..8a01eeb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -123,23 +123,18 @@ struct filter_entry {
 
 /* Macros needed to support the PCI Device ID Table ...
  */
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-	static struct pci_device_id cxgb4_pci_tbl[] = {
-#define CH_PCI_DEVICE_ID_FUNCTION 0x4
+
+#define CH_PCI_DEVICE_ID_FUNCTION	0x4
+#define CH_PCI_ID_TABLE_ENTRY_DATA	4
 
 /* Include PCI Device IDs for both PF4 and PF0-3 so our PCI probe() routine is
  * called for both.
  */
-#define CH_PCI_DEVICE_ID_FUNCTION2 0x0
-
-#define CH_PCI_ID_TABLE_ENTRY(devid) \
-		{PCI_VDEVICE(CHELSIO, (devid)), 4}
-
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_END \
-		{ 0, } \
-	}
+#define CH_PCI_DEVICE_ID_FUNCTION2	0x0
 
+static const struct pci_device_id cxgb4_pci_tbl[] = {
 #include "t4_pci_id_tbl.h"
+};
 
 #define FW4_FNAME "cxgb4/t4fw.bin"
 #define FW5_FNAME "cxgb4/t5fw.bin"
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index ddfb5b8..f648091 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -39,9 +39,6 @@
  *
  * The macros are:
  *
- * CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
- *   -- Used to start the definition of the PCI ID Table.
- *
  * CH_PCI_DEVICE_ID_FUNCTION
  *   -- The PCI Function Number to use in the PCI Device ID Table.  "0"
  *   -- for drivers attaching to PF0-3, "4" for drivers attaching to PF4,
@@ -51,25 +48,17 @@
  *   -- If defined, create a PCI Device ID Table with both
  *   -- CH_PCI_DEVICE_ID_FUNCTION and CH_PCI_DEVICE_ID_FUNCTION2 populated.
  *
- * CH_PCI_ID_TABLE_ENTRY(DeviceID)
+ * CH_PCI_ID_TABLE_ENTRY_DATA(DeviceID)
  *   -- Used for the individual PCI Device ID entries.  Note that we will
  *   -- be adding a trailing comma (",") after all of the entries (and
  *   -- between the pairs of entries if CH_PCI_DEVICE_ID_FUNCTION2 is defined).
- *
- * CH_PCI_DEVICE_ID_TABLE_DEFINE_END
- *   -- Used to finish the definition of the PCI ID Table.  Note that we
- *   -- will be adding a trailing semi-colon (";") here.
  */
-#ifdef CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 
 #ifndef CH_PCI_DEVICE_ID_FUNCTION
 #error CH_PCI_DEVICE_ID_FUNCTION not defined!
 #endif
-#ifndef CH_PCI_ID_TABLE_ENTRY
-#error CH_PCI_ID_TABLE_ENTRY not defined!
-#endif
-#ifndef CH_PCI_DEVICE_ID_TABLE_DEFINE_END
-#error CH_PCI_DEVICE_ID_TABLE_DEFINE_END not defined!
+#ifndef CH_PCI_ID_TABLE_ENTRY_DATA
+#error CH_PCI_ID_TABLE_ENTRY_DATA not defined!
 #endif
 
 /* T4 and later ASICs use a PCI Device ID scheme of 0xVFPP where:
@@ -81,19 +70,22 @@
  * We use this consistency in order to create the proper PCI Device IDs
  * for the specified CH_PCI_DEVICE_ID_FUNCTION.
  */
+
+#define CH_PCI_ID_TABLE_ENTRY(devid)					\
+	{ PCI_VDEVICE(CHELSIO, devid), CH_PCI_ID_TABLE_ENTRY_DATA }
+
 #ifndef CH_PCI_DEVICE_ID_FUNCTION2
-#define CH_PCI_ID_TABLE_FENTRY(devid) \
-	CH_PCI_ID_TABLE_ENTRY((devid) | \
+#define CH_PCI_ID_TABLE_FENTRY(devid)					\
+	CH_PCI_ID_TABLE_ENTRY((devid) |					\
 			      ((CH_PCI_DEVICE_ID_FUNCTION) << 8))
 #else
-#define CH_PCI_ID_TABLE_FENTRY(devid) \
-	CH_PCI_ID_TABLE_ENTRY((devid) | \
-			      ((CH_PCI_DEVICE_ID_FUNCTION) << 8)), \
-	CH_PCI_ID_TABLE_ENTRY((devid) | \
+#define CH_PCI_ID_TABLE_FENTRY(devid)					\
+	CH_PCI_ID_TABLE_ENTRY((devid) |					\
+			      ((CH_PCI_DEVICE_ID_FUNCTION) << 8)),	\
+	CH_PCI_ID_TABLE_ENTRY((devid) |					\
 			      ((CH_PCI_DEVICE_ID_FUNCTION2) << 8))
 #endif
 
-CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	/* T4 adapters:
 	 */
 	CH_PCI_ID_TABLE_FENTRY(0x4000),	/* T440-dbg */
@@ -154,8 +146,6 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
 	CH_PCI_ID_TABLE_FENTRY(0x5087),	/* Custom T580-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5088),	/* Custom T570-CR */
 	CH_PCI_ID_TABLE_FENTRY(0x5089),	/* Custom T520-CR */
-CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
-
-#endif /* CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN */
+	{},
 
 #endif /* __T4_PCI_ID_TBL_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 122e296..7b8b834 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -3033,16 +3033,12 @@ static void cxgb4vf_pci_shutdown(struct pci_dev *pdev)
 
 /* Macros needed to support the PCI Device ID Table ...
  */
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-	static struct pci_device_id cxgb4vf_pci_tbl[] = {
 #define CH_PCI_DEVICE_ID_FUNCTION	0x8
+#define CH_PCI_ID_TABLE_ENTRY_DATA	0
 
-#define CH_PCI_ID_TABLE_ENTRY(devid) \
-		{ PCI_VDEVICE(CHELSIO, (devid)), 0 }
-
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_END { 0, } }
-
+static const struct pci_device_id cxgb4vf_pci_tbl[] = {
 #include "../cxgb4/t4_pci_id_tbl.h"
+};
 
 MODULE_DESCRIPTION(DRV_DESC);
 MODULE_AUTHOR("Chelsio Communications");
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/csio_init.c
index d9631e1..0618fbd 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -1171,17 +1171,14 @@ static struct pci_error_handlers csio_err_handler = {
 /*
  *  Macros needed to support the PCI Device ID Table ...
  */
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-	static struct pci_device_id csio_pci_tbl[] = {
+
 /* Define for FCoE uses PF6 */
 #define CH_PCI_DEVICE_ID_FUNCTION	0x6
+#define CH_PCI_ID_TABLE_ENTRY_DATA	0
 
-#define CH_PCI_ID_TABLE_ENTRY(devid) \
-		{ PCI_VDEVICE(CHELSIO, (devid)), 0 }
-
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_END { 0, } }
-
+static const struct pci_device_id csio_pci_tbl[] = {
 #include "t4_pci_id_tbl.h"
+};
 
 static struct pci_driver csio_pci_driver = {
 	.name		= KBUILD_MODNAME,
