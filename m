From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: use correct net ns in cookie_v4_check()
Date: Thu, 03 Jun 2010 17:45:47 +0200
Message-ID: <1275579947.2456.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35733 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811Ab0FCPpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 11:45:54 -0400
Received: by wyi11 with SMTP id 11so162826wyi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 08:45:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unless I am mistaken, this is a stable candidate.

(Found by code review, please double check)

Thanks

[PATCH] tcp: use correct net ns in cookie_v4_check()

Its better to make a route lookup in appropriate namespace.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/syncookies.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5c24db4..9f6b222 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -347,7 +347,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 					       { .sport = th->dest,
 						 .dport = th->source } } };
 		security_req_classify_flow(req, &fl);
-		if (ip_route_output_key(&init_net, &rt, &fl)) {
+		if (ip_route_output_key(sock_net(sk), &rt, &fl)) {
 			reqsk_free(req);
 			goto out;
 		}


