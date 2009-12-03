From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v8 0/7] TCPCT part 1: cookie option
 exchange
Date: Wed, 02 Dec 2009 22:13:49 -0800 (PST)
Message-ID: <20091202.221349.38327679.davem@davemloft.net>
References: <4B1738C7.7090101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37802
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751289AbZLCGNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:13:43 -0500
In-Reply-To: <4B1738C7.7090101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Wed, 02 Dec 2009 23:04:23 -0500

> Initiator                            Responder
> =========                            =========
> <SYN>                          ->
> Cookie
>                                 <-   <SYN,ACK(SYN)>
>                                      Cookie
>                                      optional data

All applied, thanks.

I had to apply the following fix on top to cure a warning on 64-bit.

tcp: Fix warning on 64-bit.

net/ipv4/tcp_output.c: In function ‘tcp_make_synack’:
net/ipv4/tcp_output.c:2488: warning: cast from pointer to integer of different size

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2ac8bef..c08e06d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2485,7 +2485,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 			/* recommended */
 			*tail-- ^= ((th->dest << 16) | th->source);
-			*tail-- ^= (u32)cvp; /* per sockopt */
+			*tail-- ^= (u32)(unsigned long)cvp; /* per sockopt */
 
 			sha_transform((__u32 *)&xvp->cookie_bakery[0],
 				      (char *)mess,
-- 
1.6.5

