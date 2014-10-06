From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool v2 1/3] ethtool-copy.h: Sync with net-next 3.17.0-rc7
Date: Tue,  7 Oct 2014 04:42:19 +0530
Message-ID: <1412637141-3205-2-git-send-email-_govind@gmx.com>
References: <1412637141-3205-1-git-send-email-_govind@gmx.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:58453 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbaJFXNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 19:13:10 -0400
In-Reply-To: <1412637141-3205-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers kernel changes up to:

commit:	1255a5055449781a92076fc5429952f2b33cf309
Author:	Eric Dumazet <edumazet@google.com>
Date:	Sun Oct 5 12:35:21 2014 +0300

	ethtool: Ethtool parameter to dynamically change tx_copybreak

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 ethtool-copy.h | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 61b78fc..3c89379 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -209,6 +209,33 @@ struct ethtool_value {
 	__u32	data;
 };
 
+enum tunable_id {
+	ETHTOOL_ID_UNSPEC,
+	ETHTOOL_RX_COPYBREAK,
+	ETHTOOL_TX_COPYBREAK,
+};
+
+enum tunable_type_id {
+	ETHTOOL_TUNABLE_UNSPEC,
+	ETHTOOL_TUNABLE_U8,
+	ETHTOOL_TUNABLE_U16,
+	ETHTOOL_TUNABLE_U32,
+	ETHTOOL_TUNABLE_U64,
+	ETHTOOL_TUNABLE_STRING,
+	ETHTOOL_TUNABLE_S8,
+	ETHTOOL_TUNABLE_S16,
+	ETHTOOL_TUNABLE_S32,
+	ETHTOOL_TUNABLE_S64,
+};
+
+struct ethtool_tunable {
+	__u32	cmd;
+	__u32	id;
+	__u32	type_id;
+	__u32	len;
+	void	*data[0];
+};
+
 /**
  * struct ethtool_regs - hardware register dump
  * @cmd: Command number = %ETHTOOL_GREGS
@@ -1152,6 +1179,8 @@ enum ethtool_sfeatures_retval_bits {
 
 #define ETHTOOL_GRSSH		0x00000046 /* Get RX flow hash configuration */
 #define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
+#define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
+#define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
-- 
2.1.0
