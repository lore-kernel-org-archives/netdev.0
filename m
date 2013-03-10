From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] fix buf of assigning skb->tail to network_header
Date: Sun, 10 Mar 2013 17:48:29 +0800
Message-ID: <1362908909-45697-1-git-send-email-honkiko@gmail.com>
Cc: zhiguo.hong@emc.com, Hong Zhiguo <honkiko@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:33238 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670Ab3CJJsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 05:48:55 -0400
Received: by mail-da0-f52.google.com with SMTP id f10so504001dak.39
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 01:48:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in the case of NET_SKBUFF_DATA_USES_OFFSET,  direct pointer
assignment to skb->network_header is a dangerous bug.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/ipv4/ipmr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5f95b3a..553409b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -980,7 +980,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 
 	/* Copy the IP header */
 
-	skb->network_header = skb->tail;
+	skb_set_network_header(skb, skb->tail - skb->data);
 	skb_put(skb, ihl);
 	skb_copy_to_linear_data(skb, pkt->data, ihl);
 	ip_hdr(skb)->protocol = 0;	/* Flag to the kernel this is a route add */
-- 
1.7.10.4
