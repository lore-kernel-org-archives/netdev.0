From: Ashwanth Goli <ashwanth@codeaurora.org>
Subject: [PATCH] net: rps: fix uninitialized symbol warning
Date: Tue, 13 Jun 2017 16:54:55 +0530
Message-ID: <1497353095-8712-1-git-send-email-ashwanth@codeaurora.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:44734 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752083AbdFMLZA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:25:00 -0400
Received: from ashwanth-linux.ap.qualcomm.com. (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
        (No client certificate requested)
        (Authenticated sender: ashwanth@codeaurora.org)
        by smtp.codeaurora.org (Postfix) with ESMTPSA id 72729605A2
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:24:58 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes uninitialized symbol warning that
got introduced by the following commit
773fc8f6e8d6 ("net: rps: send out pending IPI's on CPU hotplug")

Signed-off-by: Ashwanth Goli <ashwanth@codeaurora.org>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 54bb8d9..6d60149 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -8203,7 +8203,7 @@ static int dev_cpu_dead(unsigned int oldcpu)
 	struct sk_buff **list_skb;
 	struct sk_buff *skb;
 	unsigned int cpu;
-	struct softnet_data *sd, *oldsd, *remsd;
+	struct softnet_data *sd, *oldsd, *remsd = NULL;
 
 	local_irq_disable();
 	cpu = smp_processor_id();
-- 
1.9.1
