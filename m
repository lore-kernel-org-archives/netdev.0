From: simran singhal <singhalsimran0@gmail.com>
Subject: [PATCH 1/2] netfilter: ipset: Remove unnecessary cast on void pointer
Date: Tue, 21 Mar 2017 17:49:53 +0530
Message-ID: <1490098794-22518-2-git-send-email-singhalsimran0@gmail.com>
References: <1490098794-22518-1-git-send-email-singhalsimran0@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        outreachy-kernel@googlegroups.com, gregkh@linuxfoundation.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490098794-22518-1-git-send-email-singhalsimran0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following Coccinelle script was used to detect this:
@r@
expression x;
void* e;
type T;
identifier f;
@@
(
  *((T *)e)
|
  ((T *)x)[...]
|
  ((T*)x)->f
|

- (T*)
  e
)

Signed-off-by: simran singhal <singhalsimran0@gmail.com>
---

 --This is my contribution to the netfilter project of
   Outreachy Round 14. 

 net/netfilter/ipset/ip_set_bitmap_gen.h | 4 ++--
 net/netfilter/ipset/ip_set_core.c       | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index 6f09a99..d302d98 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -232,7 +232,7 @@ mtype_list(const struct ip_set *set,
 		if (!test_bit(id, map->members) ||
 		    (SET_WITH_TIMEOUT(set) &&
 #ifdef IP_SET_BITMAP_STORED_TIMEOUT
-		     mtype_is_filled((const struct mtype_elem *)x) &&
+		     mtype_is_filled(x) &&
 #endif
 		     ip_set_timeout_expired(ext_timeout(x, set))))
 			continue;
@@ -249,7 +249,7 @@ mtype_list(const struct ip_set *set,
 		if (mtype_do_list(skb, map, id, set->dsize))
 			goto nla_put_failure;
 		if (ip_set_put_extensions(skb, set, x,
-		    mtype_is_filled((const struct mtype_elem *)x)))
+		    mtype_is_filled(x)))
 			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index c296f9b..10a3694 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1915,7 +1915,7 @@ ip_set_sockfn_get(struct sock *sk, int optval, void __user *user, int *len)
 		ret = -EFAULT;
 		goto done;
 	}
-	op = (unsigned int *)data;
+	op = data;
 
 	if (*op < IP_SET_OP_VERSION) {
 		/* Check the version at the beginning of operations */
-- 
2.7.4
