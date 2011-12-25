From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] unix_diag: Fix incoming connections nla length
Date: Sun, 25 Dec 2011 23:58:05 +0400
Message-ID: <4EF7804D.4050300@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27071 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947Ab1LYT6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Dec 2011 14:58:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NLA_PUT macro should accept the actual attribute length, not
the amount of elements in array :(

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/diag.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index 91d5782..39e44c9 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -72,7 +72,8 @@ static int sk_diag_dump_icons(struct sock *sk, struct sk_buff *nlskb)
 
 	if (sk->sk_state == TCP_LISTEN) {
 		spin_lock(&sk->sk_receive_queue.lock);
-		buf = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_ICONS, sk->sk_receive_queue.qlen);
+		buf = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_ICONS,
+				sk->sk_receive_queue.qlen * sizeof(u32));
 		i = 0;
 		skb_queue_walk(&sk->sk_receive_queue, skb) {
 			struct sock *req, *peer;
-- 
1.5.5.6
