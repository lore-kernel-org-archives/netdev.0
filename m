From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: [PATCH 1/4 ethtool] ethtool: Support for configurable RSS hash key.
Date: Fri, 17 Jan 2014 13:02:16 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8C0@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:56772 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbaAQNCS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 08:02:18 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new definitions related to set/get hashkey feature.
Kernel tree head was at  commit abfce3ef58b6a6c95de389f9d20047a05b10e484
Date:   Thu Jan 16 16:25:19 2014 +0800

Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
---
 ethtool-copy.h |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h index b5515c2..d8454e8 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -678,6 +678,22 @@ struct ethtool_rx_ntuple {
 	struct ethtool_rx_ntuple_flow_spec	fs;
 };
 
+
+/**
+ * struct ethtool_rss_hkey - command to set/get RSS hash key of the device.
+ * @cmd: Command number - %ETHTOOL_SET_RSS_HKEY/ETHTOOL_GET_RSS_HKEY
+ * @data: 40 or 16 byte rss hash key
+ * @data_len: rss hash key length
+ */
+
+#define RSS_HASH_KEY_LEN	40
+/* RSS Hash key */
+struct ethtool_rss_hkey {
+	__u32   cmd;            /* ETHTOOL_SET/GET_RSS_HKEY */
+	__u8    data[RSS_HASH_KEY_LEN];
+	__u32	data_len;
+};
+
 #define ETHTOOL_FLASH_MAX_FILENAME	128
 enum ethtool_flash_op_type {
 	ETHTOOL_FLASH_ALL_REGIONS	= 0,
@@ -901,6 +917,9 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GEEE		0x00000044 /* Get EEE settings */
 #define ETHTOOL_SEEE		0x00000045 /* Set EEE settings */
 
+#define ETHTOOL_SET_RSS_HKEY	0x00000046 /* Set RSS hash key */
+#define ETHTOOL_GET_RSS_HKEY	0x00000047 /* Get RSS hash key */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
@@ -993,8 +1012,8 @@ enum ethtool_sfeatures_retval_bits {
 #define PORT_OTHER		0xff
 
 /* Which transceiver to use. */
-#define XCVR_INTERNAL		0x00
-#define XCVR_EXTERNAL		0x01
+#define XCVR_INTERNAL		0x00 /* PHY and MAC are in the same package */
+#define XCVR_EXTERNAL		0x01 /* PHY and MAC are in different packages */
 #define XCVR_DUMMY1		0x02
 #define XCVR_DUMMY2		0x03
 #define XCVR_DUMMY3		0x04
--
1.7.1
