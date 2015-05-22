From: Arun Parameswaran <aparames@broadcom.com>
Subject: [PATCH 1/2] ethtool: Clear the command data structure before sending requests
Date: Fri, 22 May 2015 15:43:28 -0700
Message-ID: <1432334609-3971-2-git-send-email-aparames@broadcom.com>
References: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jdzheng@broadcom.com>,
	<aparames@broadcom.com>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:35346 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756896AbbEVWng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 18:43:36 -0400
In-Reply-To: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'ethtool' is not clearing the command data structure in the
do_gset() & do_sset() API's while sending commands to get/set
parametres. This used to work since the Kernel clears the
data structure (which was a bug and is being fixed).

This patch adds a 'memset' to the do_gset() & do_sset() to clear
the command data structure. This will prevent the 'ethtool' from
passing wrong parametres, for example incorrect 'phyad'.

Signed-off-by: Arun Parameswaran <aparames@broadcom.com>
Reviewed-by: JD (Jiandong) Zheng <jdzheng@broadcom.com>
---
 ethtool.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 01b13a6..668c189 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2275,6 +2275,7 @@ static int do_gset(struct cmd_context *ctx)
 
 	fprintf(stdout, "Settings for %s:\n", ctx->devname);
 
+	memset(&ecmd, 0, sizeof(struct ethtool_cmd));
 	ecmd.cmd = ETHTOOL_GSET;
 	err = send_ioctl(ctx, &ecmd);
 	if (err == 0) {
@@ -2520,6 +2521,8 @@ static int do_sset(struct cmd_context *ctx)
 	if (gset_changed) {
 		struct ethtool_cmd ecmd;
 
+		memset(&ecmd, 0, sizeof(struct ethtool_cmd));
+
 		ecmd.cmd = ETHTOOL_GSET;
 		err = send_ioctl(ctx, &ecmd);
 		if (err < 0) {
-- 
1.7.9.5
