From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 1/2] tc: flower: Add missing err check when parsing flower options
Date: Thu, 19 Jan 2017 14:31:19 +0200
Message-ID: <1484829080-18593-2-git-send-email-roid@mellanox.com>
References: <1484829080-18593-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Paul Blakey <paulb@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57975 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752532AbdASMbh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 07:31:37 -0500
In-Reply-To: <1484829080-18593-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addattr32 may return an error.

Fixes: cfcabf18d84a ("tc: flower: Add skip_{hw|sw} support")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
---
 tc/f_flower.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 1dbc532..1272a47 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -525,7 +525,9 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	}
 
 parse_done:
-	addattr32(n, MAX_MSG, TCA_FLOWER_FLAGS, flags);
+	ret = addattr32(n, MAX_MSG, TCA_FLOWER_FLAGS, flags);
+	if (ret)
+		return ret;
 
 	ret = addattr16(n, MAX_MSG, TCA_FLOWER_KEY_ETH_TYPE, eth_type);
 	if (ret) {
-- 
1.7.1
