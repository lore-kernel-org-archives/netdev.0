From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 1/6 Linux-2.6.7-bk13] prism54 cleanup functions
Date: Wed, 30 Jun 2004 19:39:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406301939.51868.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_nrv4AA/yDaRfJpt"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_nrv4AA/yDaRfJpt
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-06-28 Margit Schubert-While <margitsw@t-online.de>

* Clean up function definitions (missing static, extraneous inline)

--Boundary-00=_nrv4AA/yDaRfJpt
Content-Type: text/x-diff;
  charset="us-ascii";
  name="01_function_clean.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="01_function_clean.patch"

diff -Naur linux-2.6.7-01/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.7-02/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.7-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-06-25 19:48:40.000000000 +0200
+++ linux-2.6.7-02/drivers/net/wireless/prism54/isl_ioctl.c	2004-06-25 20:08:48.000000000 +0200
@@ -577,7 +577,7 @@
  * the "Aironet driver for 4500 and 4800 series cards" (GPL)
  */
 
-inline char *
+static char *
 prism54_translate_bss(struct net_device *ndev, char *current_ev,
 		      char *end_buf, struct obj_bss *bss, char noise)
 {
@@ -1502,7 +1502,7 @@
 
 /* Translate a TRAP oid into a wireless event. Called in islpci_mgt_receive. */
 
-static inline void
+static void
 format_event(islpci_private *priv, char *dest, const char *str,
 	     const struct obj_mlme *mlme, u16 *length, int error)
 {
diff -Naur linux-2.6.7-01/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.7-02/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.7-01/drivers/net/wireless/prism54/islpci_dev.c	2004-06-25 19:48:40.000000000 +0200
+++ linux-2.6.7-02/drivers/net/wireless/prism54/islpci_dev.c	2004-06-25 20:08:48.000000000 +0200
@@ -41,6 +41,9 @@
 #define ISL3877_IMAGE_FILE	"isl3877"
 #define ISL3890_IMAGE_FILE	"isl3890"
 
+static int prism54_bring_down(islpci_private *);
+static int islpci_alloc_memory(islpci_private *);
+
 /* Temporary dummy MAC address to use until firmware is loaded.
  * The idea there is that some tools (such as nameif) may query
  * the MAC address before the netdev is 'open'. By using a valid
@@ -390,7 +393,7 @@
 	return prism54_bring_down(priv);
 }
 
-int
+static int
 prism54_bring_down(islpci_private *priv)
 {
 	void *device_base = priv->device_base;
@@ -601,7 +604,7 @@
 /******************************************************************************
     Network device configuration functions
 ******************************************************************************/
-int
+static int
 islpci_alloc_memory(islpci_private *priv)
 {
 	int counter;
diff -Naur linux-2.6.7-01/drivers/net/wireless/prism54/islpci_dev.h linux-2.6.7-02/drivers/net/wireless/prism54/islpci_dev.h
--- linux-2.6.7-01/drivers/net/wireless/prism54/islpci_dev.h	2004-06-25 19:48:40.000000000 +0200
+++ linux-2.6.7-02/drivers/net/wireless/prism54/islpci_dev.h	2004-06-25 20:08:48.000000000 +0200
@@ -210,8 +210,6 @@
 
 struct net_device_stats *islpci_statistics(struct net_device *);
 
-int prism54_bring_down(islpci_private *);
-int islpci_alloc_memory(islpci_private *);
 int islpci_free_memory(islpci_private *);
 struct net_device *islpci_setup(struct pci_dev *);
 #endif				/* _ISLPCI_DEV_H */
diff -Naur linux-2.6.7-01/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.7-02/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.7-01/drivers/net/wireless/prism54/oid_mgt.c	2004-06-25 19:48:40.000000000 +0200
+++ linux-2.6.7-02/drivers/net/wireless/prism54/oid_mgt.c	2004-06-25 20:08:48.000000000 +0200
@@ -675,7 +675,7 @@
 
 /* This will tell you if you are allowed to answer a mlme(ex) request .*/
 
-inline int
+int
 mgt_mlme_answer(islpci_private *priv)
 {
 	u32 mlmeautolevel;
@@ -692,7 +692,7 @@
 		(mlmeautolevel >= DOT11_MLME_INTERMEDIATE));
 }
 
-inline enum oid_num_t
+enum oid_num_t
 mgt_oidtonum(u32 oid)
 {
 	int i;

--Boundary-00=_nrv4AA/yDaRfJpt--
