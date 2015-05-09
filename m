From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/15] net: move *skb_get_poff declarations into correct header
Date: Sat,  9 May 2015 15:10:26 +0200
Message-ID: <1431177038-11555-4-git-send-email-jiri@resnulli.us>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36006 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbbEINKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 09:10:54 -0400
Received: by wizk4 with SMTP id k4so58412972wiz.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 06:10:53 -0700 (PDT)
In-Reply-To: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
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
index 6cc1096..8616bfe 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3423,10 +3423,6 @@ struct sk_buff *skb_checksum_trimmed(struct sk_buff *skb,
 				     unsigned int transport_len,
 				     __sum16(*skb_chkf)(struct sk_buff *skb));
 
-u32 skb_get_poff(const struct sk_buff *skb);
-u32 __skb_get_poff(const struct sk_buff *skb, void *data,
-		   const struct flow_keys *keys, int hlen);
-
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
  * @skb: skb to check
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 118ae69..4570cca 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -46,6 +46,9 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
 }
 
 u32 flow_hash_from_keys(struct flow_keys *keys);
+u32 skb_get_poff(const struct sk_buff *skb);
+u32 __skb_get_poff(const struct sk_buff *skb, void *data,
+		   const struct flow_keys *keys, int hlen);
 
 /* struct flow_keys_digest:
  *
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
index 9045e2a..9332a0a 100644
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
