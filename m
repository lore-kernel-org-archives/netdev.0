From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/15] sctp: Don't use rt->rt_{src,dst} in sctp_v4_xmit()
Date: Sun, 08 May 2011 15:37:56 -0700 (PDT)
Message-ID: <20110508.153756.179953823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42668
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755900Ab1EHWi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 257FD24C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now we can pick it out of the transport's flow key.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/protocol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 847193b..acb2ee7 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -848,8 +848,8 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 
 	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, src:%pI4, dst:%pI4\n",
 			  __func__, skb, skb->len,
-			  &skb_rtable(skb)->rt_src,
-			  &skb_rtable(skb)->rt_dst);
+			  transport->fl.u.ip4.saddr,
+			  transport->fl.u.ip4.daddr);
 
 	inet->pmtudisc = transport->param_flags & SPP_PMTUD_ENABLE ?
 			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;
-- 
1.7.5.1

