From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next] net/sched: cls_flower: Use a proper mask value for enc key id parameter
Date: Tue, 27 Sep 2016 11:21:18 +0300
Message-ID: <1474964478-4483-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirva@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:58852 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751633AbcI0IVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 04:21:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code use the encapsulation key id value as the mask of that
parameter which is wrong. Fix that by using a full mask.

Fixes: bc3103f1ed40 ('net/sched: cls_flower: Classify packet in ip tunnels')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 net/sched/cls_flower.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 2af09c8..f6f40fb 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -481,7 +481,7 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 	}
 
 	fl_set_key_val(tb, &key->enc_key_id.keyid, TCA_FLOWER_KEY_ENC_KEY_ID,
-		       &mask->enc_key_id.keyid, TCA_FLOWER_KEY_ENC_KEY_ID,
+		       &mask->enc_key_id.keyid, TCA_FLOWER_UNSPEC,
 		       sizeof(key->enc_key_id.keyid));
 
 	return 0;
@@ -919,7 +919,7 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		goto nla_put_failure;
 
 	if (fl_dump_key_val(skb, &key->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
-			    &mask->enc_key_id, TCA_FLOWER_KEY_ENC_KEY_ID,
+			    &mask->enc_key_id, TCA_FLOWER_UNSPEC,
 			    sizeof(key->enc_key_id)))
 		goto nla_put_failure;
 
-- 
1.8.3.1
