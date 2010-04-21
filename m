From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: Fix tcp_v6_send_response checksum
Date: Wed, 21 Apr 2010 00:49:22 -0700 (PDT)
Message-ID: <20100421.004922.193694715.davem@davemloft.net>
References: <20100421070737.GA30517@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cratiu@ixiacom.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33565
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751868Ab0DUHti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 03:49:38 -0400
In-Reply-To: <20100421070737.GA30517@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 21 Apr 2010 15:07:37 +0800

> ipv6: Fix tcp_v6_send_response checksum

I put this into net-2.6 and modified the commit message since, as we
found, this incorrect transport header reset was added there to fix
IPSEC.

I'm convinced that Cosmin didn't test the patch he actually sent out
:-)

Thanks!

--------------------
ipv6: Fix tcp_v6_send_response transport header setting.

My recent patch to remove the open-coded checksum sequence in
tcp_v6_send_response broke it as we did not set the transport
header pointer on the new packet.

Actually, there is code there trying to set the transport
header properly, but it sets it for the wrong skb ('skb'
instead of 'buff').

This bug was introduced by commit
a8fdf2b331b38d61fb5f11f3aec4a4f9fb2dedcb ("ipv6: Fix
tcp_v6_send_response(): it didn't set skb transport header")

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/tcp_ipv6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c92ebe8..075f540 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1015,7 +1015,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
 
 	t1 = (struct tcphdr *) skb_push(buff, tot_len);
-	skb_reset_transport_header(skb);
+	skb_reset_transport_header(buff);
 
 	/* Swap the send and the receive. */
 	memset(t1, 0, sizeof(*t1));
-- 
1.7.0.4

