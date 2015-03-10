From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next 2/4] ipv4: Correct two conditions checking when buildig nskb
Date: Tue, 10 Mar 2015 17:16:24 +0800
Message-ID: <1425978986-8512-3-git-send-email-fan.du@intel.com>
References: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20529 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbbCJJV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 05:21:27 -0400
In-Reply-To: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When traversing write queue to build 'nskb', the size of 'copy'
could only be equal or smaller than skb->len.

And as we need exactly 'probe_size' bytes data for 'nskb', thus
break condition could only be len == probe_size.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 net/ipv4/tcp_output.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5a73ad5..79977d1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1954,7 +1954,7 @@ static int tcp_mtu_probe(struct sock *sk)
 							    skb_put(nskb, copy),
 							    copy, nskb->csum);
 
-		if (skb->len <= copy) {
+		if (skb->len == copy) {
 			/* We've eaten all the data from this skb.
 			 * Throw it away. */
 			TCP_SKB_CB(nskb)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags;
@@ -1977,7 +1977,7 @@ static int tcp_mtu_probe(struct sock *sk)
 
 		len += copy;
 
-		if (len >= probe_size)
+		if (len == probe_size)
 			break;
 	}
 	tcp_init_tso_segs(sk, nskb, nskb->len);
-- 
1.7.1
