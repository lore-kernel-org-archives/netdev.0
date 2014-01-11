From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sat, 11 Jan 2014 13:07:39 +0100
Message-ID: <1389442059-3047-1-git-send-email-fx.lebail@yahoo.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:17373 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbaAKM0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 07:26:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use ipv6_anycast_destination() in tcp_v6_send_reset() and
  tcp_v6_conn_request().

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
Tested with link-local and global anycast addresses.
Tested with SOCK_STREAM socket, bind and TCP traffic OK.

 net/ipv6/tcp_ipv6.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ffd5fa8..85297b8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -832,7 +832,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	if (th->rst)
 		return;
 
-	if (!ipv6_unicast_destination(skb))
+	if (!ipv6_unicast_destination(skb) &&
+	    !ipv6_anycast_destination(skb))
 		return;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -963,7 +964,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_conn_request(sk, skb);
 
-	if (!ipv6_unicast_destination(skb))
+	if (!ipv6_unicast_destination(skb) &&
+	    !ipv6_anycast_destination(skb))
 		goto drop;
 
 	if ((sysctl_tcp_syncookies == 2 ||
