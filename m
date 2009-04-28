From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [RFC] Add clause 45 ioctl
Date: Tue, 28 Apr 2009 13:08:54 +0300
Message-ID: <1240913334.8347.6.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yanivr@broadcom.com
To: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1135 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693AbZD1KLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 06:11:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch adds clause 45 definitions to the mii.h. This will allow
enhancing the networking device drivers ioctl to handle clause 45
related operations just as it can handle clause 22 commands today. Since
clause 45 requires additional 16 bits for the bank address, the clause
22 structure cannot be used. The motivation is to allow user space
applications to access PHY registers in clause 45.

I'm sending this as RFC - if anyone has alternative suggestions on how
user space application can access the PHY, I would appreciate it.

Thanks,
Eilon

---
 include/linux/mii.h     |   17 +++++++++++++++++
 include/linux/sockios.h |    3 +++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/mii.h b/include/linux/mii.h
index ad74858..328ad14 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -139,6 +139,13 @@
 #define FLOW_CTRL_TX		0x01
 #define FLOW_CTRL_RX		0x02
 
+/* Generic CL45 device addresses. */
+#define MII_CL45_DEVAD_PMA	0x01	/* The PMA device address */
+#define	MII_CL45_DEVAD_WIS	0x02	/* The WIS device address */
+#define MII_CL45_DEVAD_PCS	0x03	/* The PCS device address */
+#define MII_CL45_DEVAD_XS	0x04	/* The XS device address  */
+#define	MII_CL45_DEVAD_AN	0x07	/* Autoneg device address */
+
 /* This structure is used in all SIOCxMIIxxx ioctl calls */
 struct mii_ioctl_data {
 	__u16		phy_id;
@@ -147,6 +154,16 @@ struct mii_ioctl_data {
 	__u16		val_out;
 };
 
+/* This structure is used in all SIOCxCL45xxx ioctl calls */
+struct mii_cl45_ioctl_data {
+	__u16		phy_id;
+	__u16		devad;
+	__u16		reg_num;
+	__u16		val_in;
+	__u16		val_out;
+	__u16		reserved;
+};
+
 #ifdef __KERNEL__ 
 
 #include <linux/if.h>
diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index 241f179..001e46b 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -83,6 +83,9 @@
 
 #define SIOCWANDEV	0x894A		/* get/set netdev parameters	*/
 
+#define SIOCGCL45PHY	0x894B		/* Get address PHY for CL45 use */
+#define SIOCGCL45REG	0x894C		/* Read PHY register using CL45 */
+#define SIOCSCL45REG	0x894D		/* Write PHY register using CL45*/
 /* ARP cache control calls. */
 		    /*  0x8950 - 0x8952  * obsolete calls, don't re-use */
 #define SIOCDARP	0x8953		/* delete ARP table entry	*/
-- 
1.5.4.3




