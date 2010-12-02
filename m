From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: arp: use assignment
Date: Thu,  2 Dec 2010 14:07:31 +0800
Message-ID: <1291270051-27109-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:54764 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614Ab0LBGHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 01:07:55 -0500
Received: by gxk1 with SMTP id 1so957425gxk.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 22:07:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only when dont_send is 0, arp_filter() is consulted, so we can simply
assign the return value of arp_filter() to dont_send instead.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/arp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7833f17..10af759 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -883,7 +883,7 @@ static int arp_process(struct sk_buff *skb)
 
 			dont_send = arp_ignore(in_dev, sip, tip);
 			if (!dont_send && IN_DEV_ARPFILTER(in_dev))
-				dont_send |= arp_filter(sip, tip, dev);
+				dont_send = arp_filter(sip, tip, dev);
 			if (!dont_send) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n) {
