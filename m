From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 2/2] tc: flower: Fix incorrect error msg about eth type
Date: Thu, 19 Jan 2017 14:31:20 +0200
Message-ID: <1484829080-18593-3-git-send-email-roid@mellanox.com>
References: <1484829080-18593-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Paul Blakey <paulb@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57973 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752118AbdASMbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 07:31:32 -0500
In-Reply-To: <1484829080-18593-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addattr16 may return an error about the nl msg size
but not about incorrect eth type.

Fixes: 488b41d020fb ("tc: flower no need to specify the ethertype")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
---
 tc/f_flower.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 1272a47..314c2dd 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -530,11 +530,8 @@ parse_done:
 		return ret;
 
 	ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
-	if (ret) {
-		fprintf(stderr, "Illegal \"eth_type\"(0x%x)\n",
-			ntohs(eth_type));
-		return -1;
-	}
+	if (ret)
+		return ret;
 
 	tail->rta_len = (((void *)n)+n->nlmsg_len) - (void *)tail;
 
-- 
1.7.1
