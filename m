From: Ansis Atteka <aatteka@nicira.com>
Subject: [PATCH net v2 1/2] ip: use ip_hdr() in __ip_make_skb() to retrieve IP header
Date: Wed, 18 Sep 2013 15:29:52 -0700
Message-ID: <1379543393-7446-1-git-send-email-aatteka@nicira.com>
Cc: Ansis Atteka <aatteka@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:45500 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751731Ab3IRWan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 18:30:43 -0400
Received: by mail-qe0-f43.google.com with SMTP id gh4so5211536qeb.30
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 15:30:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->data already points to IP header, but for the sake of
consistency we can also use ip_hdr() to retrieve it.

Signed-off-by: Ansis Atteka <aatteka@nicira.com>
---
 net/ipv4/ip_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 9ee17e3..eae2e26 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1316,7 +1316,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	else
 		ttl = ip_select_ttl(inet, &rt->dst);
 
-	iph = (struct iphdr *)skb->data;
+	iph = ip_hdr(skb);
 	iph->version = 4;
 	iph->ihl = 5;
 	iph->tos = inet->tos;
-- 
1.7.9.5
