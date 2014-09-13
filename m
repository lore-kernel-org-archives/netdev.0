From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH ethtool 2/3] ethtool: Add rx_copybreak support
Date: Sat, 13 Sep 2014 15:26:46 +0530
Message-ID: <1410602207-9084-3-git-send-email-_govind@gmx.com>
References: <1410602207-9084-1-git-send-email-_govind@gmx.com>
Cc: netdev@vger.kernel.org, ssujith@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:52382 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbaIMJ5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2014 05:57:34 -0400
In-Reply-To: <1410602207-9084-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 ethtool.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 19b8b0c..09fdc95 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1668,6 +1668,57 @@ static int do_spause(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_srx_copybreak(struct cmd_context *ctx)
+{
+	struct ethtool_tunable *etuna;
+	int ret;
+	__u32 *rx;
+
+	if (ctx->argc != 1)
+		exit_bad_args();
+	etuna = malloc(sizeof(*etuna) + sizeof(__u32));
+	if (!etuna)
+		return 1;
+	rx = (void *)etuna + sizeof(*etuna);
+	*rx = get_u32(ctx->argp[0], 0);
+	etuna->cmd = ETHTOOL_STUNABLE;
+	etuna->id = ETHTOOL_RX_COPYBREAK;
+	etuna->type_id = ETHTOOL_TUNABLE_U32;
+	etuna->len = sizeof(__u32);
+	ret = send_ioctl(ctx, etuna);
+	if (ret)
+		perror("Cannot set rx_copybreak");
+
+	free(etuna);
+	return ret;
+}
+
+static int do_grx_copybreak(struct cmd_context *ctx)
+{
+	struct ethtool_tunable *etuna;
+	int ret;
+	__u32 *rx_copybreak;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+	etuna = malloc(sizeof(*etuna) + sizeof(__u32));
+	if (!etuna)
+		return 1;
+	etuna->cmd = ETHTOOL_GTUNABLE;
+	etuna->id = ETHTOOL_RX_COPYBREAK;
+	etuna->type_id = ETHTOOL_TUNABLE_U32;
+	etuna->len = sizeof(__u32);
+	ret = send_ioctl(ctx, etuna);
+	rx_copybreak = (void *)etuna + sizeof(*etuna);
+	if (ret)
+		perror("Cannot get rx_copybreak");
+	else
+		fprintf(stdout, "rx_copybreak : %u\n", *rx_copybreak);
+
+	free(etuna);
+	return ret;
+}
+
 static int do_sring(struct cmd_context *ctx)
 {
 	struct ethtool_ringparam ering;
@@ -3787,6 +3838,9 @@ static const struct option {
 	  "		[ rx-mini N ]\n"
 	  "		[ rx-jumbo N ]\n"
 	  "		[ tx N ]\n" },
+	{ "-b|--show-rx_copybreak", 1, do_grx_copybreak, "Show rx_copybreak value" },
+	{ "-B|--set-rx_copybreak", 1, do_srx_copybreak, "Set rx_copybreak value",
+	  "		N\n" },
 	{ "-k|--show-features|--show-offload", 1, do_gfeatures,
 	  "Get state of protocol offload and other features" },
 	{ "-K|--features|--offload", 1, do_sfeatures,
-- 
2.1.0
