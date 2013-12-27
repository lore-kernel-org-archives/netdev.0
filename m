From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] arc_emac: fix potential use after free
Date: Fri, 27 Dec 2013 13:05:06 -0500 (EST)
Message-ID: <20131227.130506.1806271226641881502.davem@davemloft.net>
References: <1387504737.19078.416.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387505440.19078.419.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey.Brodkin@synopsys.com,
	richardcochran@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923Ab3L0SFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 13:05:07 -0500
In-Reply-To: <1387505440.19078.419.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Dec 2013 18:10:40 -0800

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> skb_tx_timestamp(skb) should be called _before_ TX completion
> has a chance to trigger, otherwise it is too late and we access
> freed memory.
> 
> Fixes: e4f2379db6c6 ("ethernet/arc/arc_emac - Add new driver")
> From: Eric Dumazet <edumazet@google.com>
> Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
> Cc: Richard Cochran <richardcochran@gmail.com>

Applied, thanks.

I've seen this bug enough times that I've expanded the comment
a bit more.

====================
[PATCH] net: Add some clarification to skb_tx_timestamp() comment.

We've seen so many instances of people invoking skb_tx_timestamp()
after the device already has been given the packet, that it's worth
being a little bit more verbose and explicit in this comment.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6aae838..6f69b3f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2531,6 +2531,10 @@ static inline void sw_tx_timestamp(struct sk_buff *skb)
  * Ethernet MAC Drivers should call this function in their hard_xmit()
  * function immediately before giving the sk_buff to the MAC hardware.
  *
+ * Specifically, one should make absolutely sure that this function is
+ * called before TX completion of this packet can trigger.  Otherwise
+ * the packet could potentially already be freed.
+ *
  * @skb: A socket buffer.
  */
 static inline void skb_tx_timestamp(struct sk_buff *skb)
-- 
1.7.11.7
