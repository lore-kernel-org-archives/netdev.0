From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 03/15] net: move *skb_get_poff declarations into correct header
Date: Fri, 24 Apr 2015 17:51:29 +0200
Message-ID: <1429890701-30052-4-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37475 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031199AbbDXPvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:51:50 -0400
Received: by widdi4 with SMTP id di4so25123773wid.0
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:51:49 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since these functions are defined in flow_dissector.c, move header
declarations from skbuff.h into flow_dissector.h

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/skbuff.h       | 4 ----
 include/net/flow_dissector.h | 3 +++
 net/core/filter.c            | 1 +
 net/ethernet/eth.c           | 1 +
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ecf470f..16fa278 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3405,10 +3405,6 @@ bool skb_partial_csum_set(struct sk_buff *skb, u16 start, u16 off);
 
 int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
 
-u32 skb_get_poff(const struct sk_buff *skb);
-u32 __skb_get_poff(const struct sk_buff *skb, void *data,
-		   const struct flow_keys *keys, int hlen);
-
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
  * @skb: skb to check
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 40ca75c..b27cd24 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -46,5 +46,8 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
 }
 
 u32 flow_hash_from_keys(struct flow_keys *keys);
+u32 skb_get_poff(const struct sk_buff *skb);
+u32 __skb_get_poff(const struct sk_buff *skb, void *data,
+		   const struct flow_keys *keys, int hlen);
 
 #endif
diff --git a/net/core/filter.c b/net/core/filter.c
index bf831a8..3ccf5d7 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -36,6 +36,7 @@
 #include <net/netlink.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
+#include <net/flow_dissector.h>
 #include <linux/errno.h>
 #include <linux/timer.h>
 #include <asm/uaccess.h>
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index f3bad41..04d3bea 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -58,6 +58,7 @@
 #include <net/ipv6.h>
 #include <net/ip.h>
 #include <net/dsa.h>
+#include <net/flow_dissector.h>
 #include <linux/uaccess.h>
 
 __setup("ether=", netdev_boot_setup);
-- 
1.9.3
