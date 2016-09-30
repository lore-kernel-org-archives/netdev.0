From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 1/7] ethtool: avoid NULL pointer dereference in do_permaddr
Date: Fri, 30 Sep 2016 15:56:15 -0400
Message-ID: <1475265381-28937-2-git-send-email-linville@tuxdriver.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38660 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbcI3UAV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:00:21 -0400
In-Reply-To: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity issue: 1363118
Fixes: fef1c4a19703 ("ethtool: add get permanent address option")

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 ethtool.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 6287b559c699..aa3ef5ed2f75 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3941,6 +3941,11 @@ static int do_permaddr(struct cmd_context *ctx)
 	struct ethtool_perm_addr *epaddr;
 
 	epaddr = malloc(sizeof(struct ethtool_perm_addr) + MAX_ADDR_LEN);
+	if (!epaddr) {
+		perror("Cannot allocate memory for operation");
+		return 1;
+	}
+
 	epaddr->cmd = ETHTOOL_GPERMADDR;
 	epaddr->size = MAX_ADDR_LEN;
 
-- 
2.7.4
