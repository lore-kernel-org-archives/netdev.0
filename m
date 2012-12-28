From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: [Patch RFC] ndisc: Fix skb allocation size for link layer options.
Date: Fri, 28 Dec 2012 14:46:50 +0100
Message-ID: <1356702410-32293-1-git-send-email-stephan.gatzka@gmail.com>
Cc: yoshfuji@linux-ipv6.org, Stephan Gatzka <stephan.gatzka@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:63739 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753562Ab2L1Nr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2012 08:47:26 -0500
Received: by mail-bk0-f47.google.com with SMTP id j4so4679895bkw.34
        for <netdev@vger.kernel.org>; Fri, 28 Dec 2012 05:47:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephan Gatzka <stephan.gatzka@gmail.com>
---
 net/ipv6/ndisc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 6574175..b12b94c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -392,7 +392,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 
 	len = sizeof(struct icmp6hdr) + (target ? sizeof(*target) : 0);
 	if (llinfo)
-		len += ndisc_opt_addr_space(dev);
+		len += sizeof(struct nd_opt_hdr) + ndisc_opt_addr_space(dev);
 
 	skb = sock_alloc_send_skb(sk,
 				  (MAX_HEADER + sizeof(struct ipv6hdr) +
@@ -1424,7 +1424,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 			memcpy(ha_buf, neigh->ha, dev->addr_len);
 			read_unlock_bh(&neigh->lock);
 			ha = ha_buf;
-			len += ndisc_opt_addr_space(dev);
+			len += sizeof(struct nd_opt_hdr) +
+				ndisc_opt_addr_space(dev);
 		} else
 			read_unlock_bh(&neigh->lock);
 
-- 
1.7.9.5
