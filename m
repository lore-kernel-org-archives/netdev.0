From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH] ethtool: Add support for 20G link speed
Date: Sun, 5 Jun 2011 20:39:43 +0300
Message-ID: <1307295583.20872.123.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3489 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754277Ab1FERjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2011 13:39:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,
I'm resubmitting the addition of 20G with your corrections to ethtool.

Thanks,
Yaniv

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
---
 ethtool.8.in |    2 ++
 ethtool.c    |   18 +++++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7b1cdf5..2983b3e 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -499,6 +499,8 @@ lB	l	lB.
 0x020	1000 Full
 0x8000	2500 Full	(not supported by IEEE standards)
 0x1000	10000 Full
+0x20000	20000MLD2 Full	(not supported by IEEE standards)
+0x40000	20000KR2 Full	(not supported by IEEE standards)
 .TE
 .TP
 .BI phyad \ N
diff --git a/ethtool.c b/ethtool.c
index c189c78..35c3733 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1244,6 +1244,20 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
 	if (mask & ADVERTISED_10000baseT_Full) {
 		did1++; fprintf(stdout, "10000baseT/Full ");
 	}
+	if (did1 && (mask & ADVERTISED_20000baseMLD2_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	%*s", indent, "");
+	}
+	if (mask & ADVERTISED_20000baseMLD2_Full) {
+		did1++; fprintf(stdout, "20000baseMLD2/Full ");
+	}
+	if (did1 && (mask & ADVERTISED_20000baseKR2_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	%*s", indent, "");
+	}
+	if (mask & ADVERTISED_20000baseKR2_Full) {
+		did1++; fprintf(stdout, "20000baseKR2/Full ");
+	}
 	if (did1 == 0)
 		 fprintf(stdout, "Not reported");
 	fprintf(stdout, "\n");
@@ -2474,7 +2488,9 @@ static int do_sset(int fd, struct ifreq *ifr)
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




