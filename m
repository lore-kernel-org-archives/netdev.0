From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] net: sched: cls_u32: use hash_ptr() for tc_u_hash
Date: Wed, 18 Oct 2017 10:33:37 +0200
Message-ID: <20171018083403.3236142-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After the change to the tp hash, we now get a build warning
on 32-bit architectures:

net/sched/cls_u32.c: In function 'tc_u_hash':
net/sched/cls_u32.c:338:17: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
  return hash_64((u64) tp->chain->block, U32_HASH_SHIFT);

Using hash_ptr() instead of hash_64() lets us drop the cast
and fixes the warning while still resulting in the same hash
value.

Fixes: 7fa9d974f3c2 ("net: sched: cls_u32: use block instead of q in tc_u_common")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/sched/cls_u32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index b6d46065f661..49d96b45a8ce 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -335,7 +335,7 @@ static struct hlist_head *tc_u_common_hash;
 
 static unsigned int tc_u_hash(const struct tcf_proto *tp)
 {
-	return hash_64((u64) tp->chain->block, U32_HASH_SHIFT);
+	return hash_ptr(tp->chain->block, U32_HASH_SHIFT);
 }
 
 static struct tc_u_common *tc_u_common_find(const struct tcf_proto *tp)
-- 
2.9.0
