From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH 1/1] Use defaults when no route options are available
Date: Tue,  3 Nov 2009 21:21:25 +0200
Message-ID: <1257276085-13681-1-git-send-email-gilad@codefidence.com>
References: <4AF07024.80103@gmail.com>
Cc: netdev@vger.kernel.org, ori@comsleep.com,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:42244 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbZKCTV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 14:21:28 -0500
In-Reply-To: <4AF07024.80103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to parse the option of a SYN packet that we have
no route entry for should just use global wide defaults
for route entry options.

Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
---
 include/net/dst.h    |    2 +-
 net/ipv4/tcp_input.c |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index b562be3..0654c27 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -114,7 +114,7 @@ dst_metric(const struct dst_entry *dst, int metric)
 static inline u32
 dst_feature(const struct dst_entry *dst, u32 feature)
 {
-	return dst_metric(dst, RTAX_FEATURES) & feature;
+	return (dst ? dst_metric(dst, RTAX_FEATURES) & feature : 0);
 }
 
 static inline u32 dst_mtu(const struct dst_entry *dst)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4262da5..57e99e1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3704,8 +3704,6 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 	struct tcphdr *th = tcp_hdr(skb);
 	int length = (th->doff * 4) - sizeof(struct tcphdr);
 
-	BUG_ON(!estab && !dst);
-
 	ptr = (unsigned char *)(th + 1);
 	opt_rx->saw_tstamp = 0;
 
-- 
1.5.6.3

