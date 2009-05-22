From: Chaitanya Lala <clala@riverbed.com>
Subject: [PATCH 1/1] ethtool: Expose MDI-X status
Date: Fri, 22 May 2009 10:18:50 -0700
Message-ID: <20090522171850.GA16751@clala-laptop>
References: <1243004704.3192.21.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([206.169.144.12]:52130 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754985AbZEVRSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 13:18:15 -0400
Content-Disposition: inline
In-Reply-To: <1243004704.3192.21.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDI-X status is a useful tool for diagnosing network
connectivity issues. We expose MDI-X status as a tri-state value
status which drivers can optionally implement.

Signed-off-by: Chaitanya Lala <clala@riverbed.com>
Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 ethtool-copy.h |    6 ++++++
 ethtool.c      |   13 +++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..d3e1524 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -28,6 +28,7 @@ struct ethtool_cmd {
 	__u16	speed_hi;
 	__u16	reserved2;
 	__u32	reserved[3];
+	__u8	is_mdix;	/* Tri-state value to expose MDI-X */
 };
 
 static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
@@ -416,6 +417,11 @@ struct ethtool_rxnfc {
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
+/* Mode MDI or MDI-X */
+#define MDI_INVALID 0x00
+#define MDI         0x01
+#define MDI_X       0x02
+
 /* Wake-On-Lan options. */
 #define WAKE_PHY		(1 << 0)
 #define WAKE_UCAST		(1 << 1)
diff --git a/ethtool.c b/ethtool.c
index 0110682..bf12168 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -964,6 +964,19 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	fprintf(stdout, "	Auto-negotiation: %s\n",
 		(ep->autoneg == AUTONEG_DISABLE) ?
 		"off" : "on");
+
+	switch (ep->is_mdix) {
+	case MDI:
+		fprintf(stdout, "	MDI-X: off\n");
+		break;
+	case MDI_X:
+		fprintf(stdout, "	MDI-X: on\n");
+		break;
+	default:
+		fprintf(stdout, "	MDI-X: Unknown\n");
+		break;
+	}
+
 	return 0;
 }
 
-- 
1.6.0.4

