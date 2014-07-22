From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool 1/1] ethtool: add support for rxcopybreak
Date: Tue, 22 Jul 2014 23:04:00 +0530
Message-ID: <1406050440-13447-2-git-send-email-_govind@gmx.com>
References: <1406050440-13447-1-git-send-email-_govind@gmx.com>
Cc: davem@davemloft.net, ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:60393 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756349AbaGVReo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 13:34:44 -0400
In-Reply-To: <1406050440-13447-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for setting and displaying driver's rx_copybreak.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 ethtool-copy.h |  2 ++
 ethtool.c      | 18 +++++++++++++-----
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index b5515c2..22f1a78 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -291,6 +291,7 @@ struct ethtool_ringparam {
 	__u32	rx_mini_max_pending;
 	__u32	rx_jumbo_max_pending;
 	__u32	tx_max_pending;
+	__u32	rx_max_copybreak_pending;
 
 	/* Values changeable by the user.  The valid values are
 	 * in the range 1 to the "*_max_pending" counterpart above.
@@ -299,6 +300,7 @@ struct ethtool_ringparam {
 	__u32	rx_mini_pending;
 	__u32	rx_jumbo_pending;
 	__u32	tx_pending;
+	__u32	rx_copybreak_pending;
 };
 
 /**
diff --git a/ethtool.c b/ethtool.c
index 19b8b0c..b552738 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1064,22 +1064,26 @@ static int dump_ring(const struct ethtool_ringparam *ering)
 		"RX:		%u\n"
 		"RX Mini:	%u\n"
 		"RX Jumbo:	%u\n"
-		"TX:		%u\n",
+		"TX:		%u\n"
+		"RX copybreak:	%u\n",
 		ering->rx_max_pending,
 		ering->rx_mini_max_pending,
 		ering->rx_jumbo_max_pending,
-		ering->tx_max_pending);
+		ering->tx_max_pending,
+		ering->rx_max_copybreak_pending);
 
 	fprintf(stdout,
 		"Current hardware settings:\n"
 		"RX:		%u\n"
 		"RX Mini:	%u\n"
 		"RX Jumbo:	%u\n"
-		"TX:		%u\n",
+		"TX:		%u\n"
+		"RX copybreak:	%u\n",
 		ering->rx_pending,
 		ering->rx_mini_pending,
 		ering->rx_jumbo_pending,
-		ering->tx_pending);
+		ering->tx_pending,
+		ering->rx_copybreak_pending);
 
 	fprintf(stdout, "\n");
 	return 0;
@@ -1676,6 +1680,7 @@ static int do_sring(struct cmd_context *ctx)
 	s32 ring_rx_mini_wanted = -1;
 	s32 ring_rx_jumbo_wanted = -1;
 	s32 ring_tx_wanted = -1;
+	s32 ring_rx_copybreak_wanted = -1;
 	struct cmdline_info cmdline_ring[] = {
 		{ "rx", CMDL_S32, &ring_rx_wanted, &ering.rx_pending },
 		{ "rx-mini", CMDL_S32, &ring_rx_mini_wanted,
@@ -1683,6 +1688,8 @@ static int do_sring(struct cmd_context *ctx)
 		{ "rx-jumbo", CMDL_S32, &ring_rx_jumbo_wanted,
 		  &ering.rx_jumbo_pending },
 		{ "tx", CMDL_S32, &ring_tx_wanted, &ering.tx_pending },
+		{ "rx-copybreak", CMDL_S32, &ring_rx_copybreak_wanted,
+		  &ering.rx_copybreak_pending },
 	};
 	int err, changed = 0;
 
@@ -3786,7 +3793,8 @@ static const struct option {
 	  "		[ rx N ]\n"
 	  "		[ rx-mini N ]\n"
 	  "		[ rx-jumbo N ]\n"
-	  "		[ tx N ]\n" },
+	  "		[ tx N ]\n"
+	  "		[ rx-copybreak N ]\n" },
 	{ "-k|--show-features|--show-offload", 1, do_gfeatures,
 	  "Get state of protocol offload and other features" },
 	{ "-K|--features|--offload", 1, do_sfeatures,
-- 
2.0.2
