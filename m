From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] ipv4: Remove unused but set variable
Date: Tue, 18 Oct 2016 09:40:20 +0200
Message-ID: <20161018074020.11162-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:51228 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932460AbcJRHk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 03:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unused but set variable dev in ip_do_fragment to fix the
following GCC warning when building with 'W=1':

  net/ipv4/ip_output.c: In function ‘ip_do_fragment’:
  net/ipv4/ip_output.c:541:21: warning: variable ‘dev’ set but not used [-Wunused-but-set-variable]

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/ipv4/ip_output.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 05d105832bdb..03e7f7310423 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -538,7 +538,6 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 {
 	struct iphdr *iph;
 	int ptr;
-	struct net_device *dev;
 	struct sk_buff *skb2;
 	unsigned int mtu, hlen, left, len, ll_rs;
 	int offset;
@@ -546,8 +545,6 @@ int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 	struct rtable *rt = skb_rtable(skb);
 	int err = 0;
 
-	dev = rt->dst.dev;
-
 	/* for offloaded checksums cleanup checksum before fragmentation */
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    (err = skb_checksum_help(skb)))
-- 
2.9.0
