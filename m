From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6]: tcpv6: fix error with CONFIG_TCP_MD5SIG disabled
Date: Fri, 10 Oct 2008 11:21:15 +0800
Message-ID: <20081010031703.M9440@cooldavid.org>
References: <20081008.195524.235036900.davem@davemloft.net>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:36851 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbYJJDVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 23:21:50 -0400
In-Reply-To: <20081008.195524.235036900.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David:

    This patch fix error with CONFIG_TCP_MD5SIG disabled.

    The patch is also available at:
    http://cooldavid.org/download/tcpv6.net-next-2.6.20081010.patch

    Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 13c6514..e5310c9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1036,9 +1036,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct
sk_buff *skb)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *key;
-#endif
+	struct tcp_md5sig_key *key = NULL;
 
 	if (th->rst)
 		return;
@@ -1049,8 +1047,6 @@ static void tcp_v6_send_reset(struct sock *sk, struct
sk_buff *skb)
 #ifdef CONFIG_TCP_MD5SIG
 	if (sk)
 		key = tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr);
-	else
-		key = NULL;
 #endif
 
 	if (th->ack)

