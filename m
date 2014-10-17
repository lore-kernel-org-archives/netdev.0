From: roy.qing.li@gmail.com
Subject: [PATCH] ipv4: fix a potential use after free in fou.c
Date: Fri, 17 Oct 2014 16:53:47 +0800
Message-ID: <1413536027-15700-1-git-send-email-roy.qing.li@gmail.com>
Cc: therbert@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:47825 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382AbaJQIxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 04:53:53 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so423035pdb.35
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 01:53:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

pskb_may_pull() maybe change skb->data and make uh pointer oboslete,
so reload uh and guehdr

Fixes: 37dd0247 ("gue: Receive side for Generic UDP Encapsulation")
Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/fou.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index efa70ad..32e7892 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -87,6 +87,9 @@ static int gue_udp_recv(struct sock *sk, struct sk_buff *skb)
 	if (!pskb_may_pull(skb, len))
 		goto drop;
 
+	uh = udp_hdr(skb);
+	guehdr = (struct guehdr *)&uh[1];
+
 	if (guehdr->version != 0)
 		goto drop;
 
-- 
1.7.10.4
