From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tipc: fix error handling of expanding buffer
 headroom
Date: Tue, 24 Nov 2015 11:27:21 -0500 (EST)
Message-ID: <20151124.112721.722886749351483829.davem@davemloft.net>
References: <1448344677-11462-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, scan-admin@coverity.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42422 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbbKXQ1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 11:27:23 -0500
In-Reply-To: <1448344677-11462-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 24 Nov 2015 13:57:57 +0800

> Coverity says:
> 
> *** CID 1338065:  Error handling issues  (CHECKED_RETURN)
> /net/tipc/udp_media.c: 162 in tipc_udp_send_msg()
> 156     	struct udp_media_addr *dst = (struct udp_media_addr *)&dest->value;
> 157     	struct udp_media_addr *src = (struct udp_media_addr *)&b->addr.value;
> 158     	struct sk_buff *clone;
> 159     	struct rtable *rt;
> 160
> 161     	if (skb_headroom(skb) < UDP_MIN_HEADROOM)
>>>>     CID 1338065:  Error handling issues  (CHECKED_RETURN)
>>>>     Calling "pskb_expand_head" without checking return value (as is done elsewhere 51 out of 56 times).
> 162     		pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
> 163
> 164     	clone = skb_clone(skb, GFP_ATOMIC);
> 165     	skb_set_inner_protocol(clone, htons(ETH_P_TIPC));
> 166     	ub = rcu_dereference_rtnl(b->media_ptr);
> 167     	if (!ub) {
> 
> When expanding buffer headroom over udp tunnel with pskb_expand_head(),
> it's unfortunate that we don't check its return value. As a result, if
> the function returns an error code due to the lack of memory, it may
> cause unpredictable consequence as we unconditionally consider that
> it's always successful.
> 
> Fixes: e53567948f82 ("tipc: conditionally expand buffer headroom over udp tunnel")
> Reported-by: <scan-admin@coverity.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied and queued up for -stable.
