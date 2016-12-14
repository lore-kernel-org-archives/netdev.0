From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH net 2/2] net/sched: cls_flower: Use masked key when calling HW offloads
Date: Wed, 14 Dec 2016 19:00:58 +0200
Message-ID: <1481734858-37474-3-git-send-email-paulb@mellanox.com>
References: <1481734858-37474-1-git-send-email-paulb@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44451 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753943AbcLNRID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 12:08:03 -0500
In-Reply-To: <1481734858-37474-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zero bits on the mask signify a "don't care" on the corresponding bits
in key. Some HWs require those bits on the key to be zero. Since these
bits are masked anyway, it's okay to provide the masked key to all
drivers.

Fixes: 5b33f48842fa ('net/flower: Introduce hardware offload support')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 9758f5a..35ac28d 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -252,7 +252,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	offload.cookie = (unsigned long)f;
 	offload.dissector = dissector;
 	offload.mask = mask;
-	offload.key = &f->key;
+	offload.key = &f->mkey;
 	offload.exts = &f->exts;
 
 	tc->type = TC_SETUP_CLSFLOWER;
-- 
1.8.3.1
