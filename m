From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH] Ethtool: Free memory leak in do_sprivflags()
Date: Wed, 12 Jun 2013 14:59:58 +0300
Message-ID: <1371038398-15934-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yuval Mintz" <yuvalmin@broadcom.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4740 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573Ab3FLMAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 08:00:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cmdline is allocated for usage in parse_generic_cmdline(), but is not
released after its final usage.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ethtool.c b/ethtool.c
index 8cc10b5..b80494d 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3521,6 +3521,7 @@ static int do_sprivflags(struct cmd_context *ctx)
 		cmdline[i].seen_val = &seen_flags;
 	}
 	parse_generic_cmdline(ctx, &any_changed, cmdline, strings->len);
+	free(cmdline);
 
 	flags.cmd = ETHTOOL_GPFLAGS;
 	if (send_ioctl(ctx, &flags)) {
-- 
1.8.1.227.g44fe835
