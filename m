From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: [PATCH] skb leakage in inet6_csk_xmit
Date: Wed, 10 May 2006 13:02:16 +0400
Message-ID: <20060510090216.GA1968@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:2503 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S964868AbWEJJCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 05:02:18 -0400
To: netdev@vger.kernel.org, davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

inet6_csk_xit does not free skb when routing fails.

Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index f8f3a37..eb2865d 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -173,6 +173,7 @@ int inet6_csk_xmit(struct sk_buff *skb, 
 
 		if (err) {
 			sk->sk_err_soft = -err;
+			kfree_skb(skb);
 			return err;
 		}
 
@@ -181,6 +182,7 @@ int inet6_csk_xmit(struct sk_buff *skb, 
 
 		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
 			sk->sk_route_caps = 0;
+			kfree_skb(skb);
 			return err;
 		}
 
