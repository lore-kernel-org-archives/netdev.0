From: Chaitanya Lala <clala@riverbed.com>
Subject: Re-submit [PATCH 1/1] ethtool: Expose MDI-X status
Date: Wed, 10 Jun 2009 12:11:07 -0700
Message-ID: <20090610191106.GA5930@clala-laptop>
References: <1243353768.3188.2.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: jgarzik@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:38536 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123AbZFJTKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:10:01 -0400
Content-Disposition: inline
In-Reply-To: <1243353768.3188.2.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDI-X status is a useful tool for diagnosing network
connectivity issues. We expose MDI-X status as a tri-state value
status which drivers can optionally implement.

Signed-off-by: Chaitanya Lala <clala@riverbed.com>
Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 ethtool-copy.h |    8 +++++++-
 ethtool.c      |   13 +++++++++++++
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..48fb1d3 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -26,7 +26,8 @@ struct ethtool_cmd {
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;
-	__u16	reserved2;
+	__u8	is_mdix;
+	__u8	reserved2;
 	__u32	reserved[3];
 };
 
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

