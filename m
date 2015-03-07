From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 4/6] mpls: Correct the ttl decrement.
Date: Sat, 07 Mar 2015 16:23:23 -0600
Message-ID: <87a8zo4fc4.fsf@x220.int.ebiederm.org>
References: <874mpw5u3x.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:49794 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbbCGW1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 17:27:00 -0500
In-Reply-To: <874mpw5u3x.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sat, 07 Mar 2015 16:18:58 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


According to RFC3032 section 2.4.2  packets with an outgoing
ttl of 0 MUST NOT be forwarded.  According to section 2.4.1
an outgoing TTL of 0 comes from an incomming TTL <= 1.

Therefore any packets that is received with a ttl <= 1 should
not have it's ttl decremented and forwarded.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/mpls/af_mpls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 5c99e3fc1b72..e120074157de 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -162,7 +162,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	skb_forward_csum(skb);
 
 	/* Verify ttl is valid */
-	if (dec.ttl <= 2)
+	if (dec.ttl <= 1)
 		goto drop;
 	dec.ttl -= 1;
 
-- 
2.2.1
