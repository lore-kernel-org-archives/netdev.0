From: Chaitanya Lala <clala@riverbed.com>
Subject: [PATCH 1/1] ethtool: Expose MDI-X status
Date: Fri, 22 May 2009 07:54:26 -0700
Message-ID: <20090522145426.GA8470@clala-laptop>
References: <F169D4F5E1F1974DBFAFABF47F60C10A33527C9D@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:1176 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590AbZEVOxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 10:53:51 -0400
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A33527C9D@orsmsx507.amr.corp.intel.com>
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
index 3ca4e2c..37bbeaf 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -23,6 +23,7 @@ struct ethtool_cmd {
 	__u8	phy_address;
 	__u8	transceiver;	/* Which transceiver to use */
 	__u8	autoneg;	/* Enable or disable autonegotiation */
+	__u8	is_mdix;
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;
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

