From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH ] net: raw: do not report ICMP redirects to user space
Date: Fri, 20 Sep 2013 18:21:25 +0800
Message-ID: <523C21A5.4050504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:38630 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754435Ab3ITKW3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 06:22:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Redirect isn't an error condition, it should leave
the error handler without touching the socket.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/raw.c | 4 +++-
 net/ipv6/raw.c | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index bfec521..193db03 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -218,8 +218,10 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED)
 		ipv4_sk_update_pmtu(skb, sk, info);
-	else if (type == ICMP_REDIRECT)
+	else if (type == ICMP_REDIRECT) {
 		ipv4_sk_redirect(skb, sk);
+		return;
+	}
 
 	/* Report error on raw socket, if:
 	   1. User requested ip_recverr.
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 58916bb..a4ed241 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -335,8 +335,10 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 		ip6_sk_update_pmtu(skb, sk, info);
 		harderr = (np->pmtudisc == IPV6_PMTUDISC_DO);
 	}
-	if (type == NDISC_REDIRECT)
+	if (type == NDISC_REDIRECT) {
 		ip6_sk_redirect(skb, sk);
+		return;
+	}
 	if (np->recverr) {
 		u8 *payload = skb->data;
 		if (!inet->hdrincl)
-- 
1.8.3.1
