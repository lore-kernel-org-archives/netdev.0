From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH] ethtool: Add support for 20G link speed
Date: Mon, 23 May 2011 16:38:00 +0300
Message-ID: <1306157880.20872.102.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eilong@broadcom.com
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2939 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531Ab1EWNie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 May 2011 09:38:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 20G link speed

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
---
 ethtool-copy.h |    5 +++++
 ethtool.c      |   18 +++++++++++++++++-
 2 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 22215e9..c02a98b 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -749,6 +749,8 @@ enum ethtool_sfeatures_retval_bits {
 #define SUPPORTED_10000baseKX4_Full	(1 << 18)
 #define SUPPORTED_10000baseKR_Full	(1 << 19)
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
+#define SUPPORTED_20000baseMLD2_Full	(1 << 21)
+#define SUPPORTED_20000baseKR2_Full	(1 << 22)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -772,6 +774,9 @@ enum ethtool_sfeatures_retval_bits {
 #define ADVERTISED_10000baseKX4_Full	(1 << 18)
 #define ADVERTISED_10000baseKR_Full	(1 << 19)
 #define ADVERTISED_10000baseR_FEC	(1 << 20)
+#define ADVERTISED_20000baseMLD2_Full	(1 << 21)
+#define ADVERTISED_20000baseKR2_Full	(1 << 22)
+
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
diff --git a/ethtool.c b/ethtool.c
index cfdac65..a099a23 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1238,6 +1238,20 @@ static void dump_supported(struct ethtool_cmd *ep)
 	if (mask & SUPPORTED_10000baseT_Full) {
 		did1++; fprintf(stdout, "10000baseT/Full ");
 	}
+	if (did1 && (mask & SUPPORTED_20000baseMLD2_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	                        ");
+	}
+	if (mask & SUPPORTED_20000baseMLD2_Full) {
+		did1++; fprintf(stdout, "20000baseMLD2/Full ");
+	}
+	if (did1 && (mask & SUPPORTED_20000baseKR2_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	                        ");
+	}
+	if (mask & SUPPORTED_20000baseKR2_Full) {
+		did1++; fprintf(stdout, "20000baseKR2/Full ");
+	}
 	fprintf(stdout, "\n");
 
 	fprintf(stdout, "	Supports auto-negotiation: ");
@@ -2581,7 +2595,9 @@ static int do_sset(int fd, struct ifreq *ifr)
 					 ADVERTISED_1000baseT_Half |
 					 ADVERTISED_1000baseT_Full |
 					 ADVERTISED_2500baseX_Full |
-					 ADVERTISED_10000baseT_Full);
+					 ADVERTISED_10000baseT_Full |
+					 ADVERTISED_20000baseMLD2_Full |
+					 ADVERTISED_20000baseKR2_Full);
 			} else if (advertising_wanted > 0) {
 				ecmd.advertising = advertising_wanted;
 			}
-- 
1.7.1





