From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 4/5] dccp: Support for Mandatory options
Date: Sat, 22 Nov 2008 11:30:40 +0100
Message-ID: <1227349841-9440-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1227349841-9440-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1227349841-9440-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1227349841-9440-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1227349841-9440-4-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54502 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754415AbYKVKat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 05:30:49 -0500
In-Reply-To: <1227349841-9440-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for Mandatory options is provided by this patch, which will
be used by subsequent feature-negotiation patches.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/feat.h    |    2 ++
 net/dccp/options.c |   15 +++++++++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -138,4 +138,6 @@ extern int  dccp_feat_init(struct sock *sk);
 
 extern void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
 extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
+
+extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -467,6 +467,21 @@ static int dccp_insert_option_timestamp_echo(struct dccp_sock *dp,
 	return 0;
 }
 
+/**
+ * dccp_insert_option_mandatory  -  Mandatory option (5.8.2)
+ * Note that since we are using skb_push, this function needs to be called
+ * _after_ inserting the option it is supposed to influence (stack order).
+ */
+int dccp_insert_option_mandatory(struct sk_buff *skb)
+{
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len >= DCCP_MAX_OPT_LEN)
+		return -1;
+
+	DCCP_SKB_CB(skb)->dccpd_opt_len++;
+	*skb_push(skb, 1) = DCCPO_MANDATORY;
+	return 0;
+}
+
 static int dccp_insert_feat_opt(struct sk_buff *skb, u8 type, u8 feat,
 				u8 *val, u8 len)
 {
