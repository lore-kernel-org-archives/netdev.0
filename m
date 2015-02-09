From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 ethtool 3/3] ethtool: Add support to get expansion ROM version in ethtool getdrvinfo
Date: Mon,  9 Feb 2015 12:07:31 +0530
Message-ID: <1423463851-19073-4-git-send-email-hariprasad@chelsio.com>
References: <1423463851-19073-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30302 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759189AbbBIGcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 01:32:04 -0500
In-Reply-To: <1423463851-19073-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 ethtool-copy.h |    4 +++-
 ethtool.c      |    2 ++
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 61b78fc..7ec0f94 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -139,6 +139,7 @@ static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 
 #define ETHTOOL_FWVERS_LEN	32
 #define ETHTOOL_BUSINFO_LEN	32
+#define ETHTOOL_EROMVERS_LEN	32
 
 /**
  * struct ethtool_drvinfo - general driver and device information
@@ -148,6 +149,7 @@ static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
  *	not be an empty string.
  * @version: Driver version string; may be an empty string
  * @fw_version: Firmware version string; may be an empty string
+ * @erom_version: Expansion ROM version string; may be an empty string
  * @bus_info: Device bus address.  This should match the dev_name()
  *	string for the underlying bus device, if there is one.  May be
  *	an empty string.
@@ -176,7 +178,7 @@ struct ethtool_drvinfo {
 	char	version[32];
 	char	fw_version[ETHTOOL_FWVERS_LEN];
 	char	bus_info[ETHTOOL_BUSINFO_LEN];
-	char	reserved1[32];
+	char	erom_version[ETHTOOL_EROMVERS_LEN];
 	char	reserved2[12];
 	__u32	n_priv_flags;
 	__u32	n_stats;
diff --git a/ethtool.c b/ethtool.c
index bf583f3..b7d2206 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -701,6 +701,7 @@ static int dump_drvinfo(struct ethtool_drvinfo *info)
 		"driver: %.*s\n"
 		"version: %.*s\n"
 		"firmware-version: %.*s\n"
+		"expansion-rom-version: %.*s\n"
 		"bus-info: %.*s\n"
 		"supports-statistics: %s\n"
 		"supports-test: %s\n"
@@ -710,6 +711,7 @@ static int dump_drvinfo(struct ethtool_drvinfo *info)
 		(int)sizeof(info->driver), info->driver,
 		(int)sizeof(info->version), info->version,
 		(int)sizeof(info->fw_version), info->fw_version,
+		(int)sizeof(info->erom_version), info->erom_version,
 		(int)sizeof(info->bus_info), info->bus_info,
 		info->n_stats ? "yes" : "no",
 		info->testinfo_len ? "yes" : "no",
-- 
1.7.1
