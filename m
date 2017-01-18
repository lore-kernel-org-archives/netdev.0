From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net] bnxt_en: Fix "uninitialized variable" bug in TPA code path.
Date: Tue, 17 Jan 2017 22:07:19 -0500
Message-ID: <1484708839-11745-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, andrew.gospodarek@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35729 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751485AbdARDHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 22:07:44 -0500
Received: by mail-pg0-f44.google.com with SMTP id 194so239940pgd.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 19:07:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the TPA GRO code path, initialize the tcp_opt_len variable to 0 so
that it will be correct for packets without TCP timestamps.  The bug
caused the SKB fields to be incorrectly set up for packets without
TCP timestamps, leading to these packets being rejected by the stack.

Reported-by: Andy Gospodarek <andrew.gospodarek@broadocm.com>
Acked-by: Andy Gospodarek <andrew.gospodarek@broadocm.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9608cb4..53e686f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1099,7 +1099,7 @@ static struct sk_buff *bnxt_gro_func_5730x(struct bnxt_tpa_info *tpa_info,
 {
 #ifdef CONFIG_INET
 	struct tcphdr *th;
-	int len, nw_off, tcp_opt_len;
+	int len, nw_off, tcp_opt_len = 0;
 
 	if (tcp_ts)
 		tcp_opt_len = 12;
-- 
1.8.3.1
