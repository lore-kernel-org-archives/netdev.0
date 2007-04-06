From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] mii: add kernel-doc notation
Date: Fri, 6 Apr 2007 11:08:24 -0700
Message-ID: <20070406110824.b113fff1.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:28037 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934126AbXDFSG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 14:06:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Add kernel-doc notation to drivers/net/mii.c functions.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/mii.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

--- linux-2.6.21-rc6.orig/drivers/net/mii.c
+++ linux-2.6.21-rc6/drivers/net/mii.c
@@ -33,6 +33,13 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 
+/**
+ * mii_ethtool_gset - get settings that are specified in @ecmd
+ * @mii: MII interface
+ * @ecmd: requested ethtool_cmd
+ *
+ * Returns 0 for success, negative on error.
+ */
 int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 {
 	struct net_device *dev = mii->dev;
@@ -114,6 +121,13 @@ int mii_ethtool_gset(struct mii_if_info 
 	return 0;
 }
 
+/**
+ * mii_ethtool_sset - set settings that are specified in @ecmd
+ * @mii: MII interface
+ * @ecmd: requested ethtool_cmd
+ *
+ * Returns 0 for success, negative on error.
+ */
 int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 {
 	struct net_device *dev = mii->dev;
@@ -207,6 +221,10 @@ int mii_ethtool_sset(struct mii_if_info 
 	return 0;
 }
 
+/**
+ * mii_check_gmii_support - check if the MII supports Gb interfaces
+ * @mii: the MII interface
+ */
 int mii_check_gmii_support(struct mii_if_info *mii)
 {
 	int reg;
@@ -221,6 +239,12 @@ int mii_check_gmii_support(struct mii_if
 	return 0;
 }
 
+/**
+ * mii_link_ok - is link status up/ok
+ * @mii: the MII interface
+ *
+ * Returns 1 if the MII reports link status up/ok, 0 otherwise.
+ */
 int mii_link_ok (struct mii_if_info *mii)
 {
 	/* first, a dummy read, needed to latch some MII phys */
@@ -230,6 +254,12 @@ int mii_link_ok (struct mii_if_info *mii
 	return 0;
 }
 
+/**
+ * mii_nway_restart - restart NWay (autonegotiation) for this interface
+ * @mii: the MII interface
+ *
+ * Returns 0 on success, negative on error.
+ */
 int mii_nway_restart (struct mii_if_info *mii)
 {
 	int bmcr;
@@ -247,6 +277,14 @@ int mii_nway_restart (struct mii_if_info
 	return r;
 }
 
+/**
+ * mii_check_link - check MII link status
+ * @mii: MII interface
+ *
+ * If the link status changed (previous != current), call
+ * netif_carrier_on() if current link status is Up or call
+ * netif_carrier_off() if current link status is Down.
+ */
 void mii_check_link (struct mii_if_info *mii)
 {
 	int cur_link = mii_link_ok(mii);
@@ -258,6 +296,15 @@ void mii_check_link (struct mii_if_info 
 		netif_carrier_off(mii->dev);
 }
 
+/**
+ * mii_check_media - check the MII interface for a duplex change
+ * @mii: the MII interface
+ * @ok_to_print: OK to print link up/down messages
+ * @init_media: OK to save duplex mode in @mii
+ *
+ * Returns 1 if the duplex mode changed, 0 if not.
+ * If the media type is forced, always returns 0.
+ */
 unsigned int mii_check_media (struct mii_if_info *mii,
 			      unsigned int ok_to_print,
 			      unsigned int init_media)
@@ -326,6 +373,16 @@ unsigned int mii_check_media (struct mii
 	return 0; /* duplex did not change */
 }
 
+/**
+ * generic_mii_ioctl - main MII ioctl interface
+ * @mii_if: the MII interface
+ * @mii_data: MII ioctl data structure
+ * @cmd: MII ioctl command
+ * @duplex_chg_out: pointer to @duplex_changed status if there was no
+ *	ioctl error
+ *
+ * Returns 0 on success, negative on error.
+ */
 int generic_mii_ioctl(struct mii_if_info *mii_if,
 		      struct mii_ioctl_data *mii_data, int cmd,
 		      unsigned int *duplex_chg_out)
