From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to flow_keys struct
Date: Fri, 27 Feb 2015 19:11:46 -0800
Message-ID: <1425093109-1077-4-git-send-email-therbert@google.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:43323 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbbB1DMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:12:54 -0500
Received: by igbhn18 with SMTP id hn18so5341358igb.2
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:12:53 -0800 (PST)
In-Reply-To: <1425093109-1077-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be used for additional input into the hash computation
such as VLAN ID or GRE keyid.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/flow_keys.h   | 1 +
 include/net/sch_generic.h | 2 +-
 net/core/flow_dissector.c | 2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index dc8fd81..d498ee8 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -24,6 +24,7 @@ struct flow_keys {
 	};
 	u16	thoff;
 	__be16	n_proto;
+	__be32	hash_extra;
 	u8	ip_proto;
 };
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c605d30..d41a034 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -252,7 +252,7 @@ struct qdisc_skb_cb {
 	unsigned int		pkt_len;
 	u16			slave_dev_queue_mapping;
 	u16			_pad;
-#define QDISC_CB_PRIV_LEN 20
+#define QDISC_CB_PRIV_LEN 24
 	unsigned char		data[QDISC_CB_PRIV_LEN];
 };
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index f73a248..84bb794 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -286,7 +286,7 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
 		swap(keys->port16[0], keys->port16[1]);
 	}
 
-	extra = keys->ip_proto;
+	extra = keys->ip_proto ^ keys->hash_extra;
 	hash = __flow_hash_3words((__force u32)keys->dst ^ extra,
 				  (__force u32)keys->src,
 				  (__force u32)keys->ports);
-- 
2.2.0.rc0.207.ga3a616c
