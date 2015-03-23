From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: clear skb->priority when forwarding to
 another netns
Date: Mon, 23 Mar 2015 16:43:53 -0400 (EDT)
Message-ID: <20150323.164353.1673812828862266536.davem@davemloft.net>
References: <1426886949-12447-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbbCWUny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:43:54 -0400
In-Reply-To: <1426886949-12447-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 20 Mar 2015 14:29:09 -0700

> skb->priority can be set for two purposes:
> 
> 1) With respect to IP TOS field, which is computed by a mask.
> Ususally used for priority qdisc's (pfifo, prio etc.), on TX
> side (we only have ingress qdisc on RX side).
> 
> 2) Used as a classid or flowid, works in the same way with tc
> classid. What's more, this can even override the classid
> of tc filters.
> 
> For case 1), it has been respected within its netns, I don't
> see any point of keeping it for another netns, especially
> when packets will be forwarded to Rx path (no matter from TX
> path or RX path).
> 
> For case 2) we care, our applications run inside a netns,
> and we classify the packets by our own filters outside,
> If some application sets this priority, it could bypass
> our filters, therefore clear it when moving out of a netns,
> it makes no sense to bypass tc filters out of its netns.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, t hanks.
