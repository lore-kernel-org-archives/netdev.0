From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] dccp: remove obsolete code
Date: Sat, 4 Jan 2014 13:46:11 -0800
Message-ID: <20140104134611.05cc16e2@nehalam.linuxnetplumber.net>
References: <20140104134445.01a49cc6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:62087 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754703AbaADVqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 16:46:45 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so17196878pab.0
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 13:46:45 -0800 (PST)
In-Reply-To: <20140104134445.01a49cc6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is defined but not used.
Remove it now, can be resurrected if ever needed.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/dccp/dccp.h    |    1 -
 net/dccp/options.c |   32 --------------------------------
 2 files changed, 33 deletions(-)

--- a/net/dccp/dccp.h	2014-01-04 13:39:54.444218991 -0800
+++ b/net/dccp/dccp.h	2014-01-04 13:42:22.829764045 -0800
@@ -479,7 +479,6 @@ void dccp_feat_list_purge(struct list_he
 
 int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
 int dccp_insert_options_rsk(struct dccp_request_sock *, struct sk_buff *);
-int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed);
 u32 dccp_timestamp(void);
 void dccp_timestamping_init(void);
 int dccp_insert_option(struct sk_buff *skb, unsigned char option,
--- a/net/dccp/options.c	2014-01-04 13:39:54.444218991 -0800
+++ b/net/dccp/options.c	2014-01-04 13:42:22.833763979 -0800
@@ -343,38 +343,6 @@ static inline int dccp_elapsed_time_len(
 	return elapsed_time == 0 ? 0 : elapsed_time <= 0xFFFF ? 2 : 4;
 }
 
-/* FIXME: This function is currently not used anywhere */
-int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed_time)
-{
-	const int elapsed_time_len = dccp_elapsed_time_len(elapsed_time);
-	const int len = 2 + elapsed_time_len;
-	unsigned char *to;
-
-	if (elapsed_time_len == 0)
-		return 0;
-
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
-		return -1;
-
-	DCCP_SKB_CB(skb)->dccpd_opt_len += len;
-
-	to    = skb_push(skb, len);
-	*to++ = DCCPO_ELAPSED_TIME;
-	*to++ = len;
-
-	if (elapsed_time_len == 2) {
-		const __be16 var16 = htons((u16)elapsed_time);
-		memcpy(to, &var16, 2);
-	} else {
-		const __be32 var32 = htonl(elapsed_time);
-		memcpy(to, &var32, 4);
-	}
-
-	return 0;
-}
-
-EXPORT_SYMBOL_GPL(dccp_insert_option_elapsed_time);
-
 static int dccp_insert_option_timestamp(struct sk_buff *skb)
 {
 	__be32 now = htonl(dccp_timestamp());
