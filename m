From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: icmp6_send should use dst dev to determine L3 domain
Date: Thu,  3 Nov 2016 16:17:26 -0700
Message-ID: <1478215046-18806-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36573 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbcKCXRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:17:32 -0400
Received: by mail-pf0-f172.google.com with SMTP id 189so39345411pfz.3
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 16:17:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

icmp6_send is called in response to some event. The skb may not have
the device set (skb->dev is NULL), but it is expected to have a dst set.
Update icmp6_send to use the dst on the skb to determine L3 domain.

Fixes: ca254490c8dfd ("net: Add VRF support to IPv6 stack")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/icmp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index bd59c343d35f..7370ad2e693a 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -448,7 +448,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	if (__ipv6_addr_needs_scope_id(addr_type))
 		iif = skb->dev->ifindex;
 	else
-		iif = l3mdev_master_ifindex(skb->dev);
+		iif = l3mdev_master_ifindex(skb_dst(skb)->dev);
 
 	/*
 	 *	Must not send error if the source does not uniquely
-- 
2.1.4
