From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] netlink: allow large data transfers from
 user-space
Date: Fri, 07 Jun 2013 16:26:56 -0700 (PDT)
Message-ID: <20130607.162656.1478762217066934846.davem@davemloft.net>
References: <1370288788-30579-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, eric.dumazet@gmail.com
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580Ab3FGX07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 19:26:59 -0400
In-Reply-To: <1370288788-30579-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Mon,  3 Jun 2013 21:46:28 +0200

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> I can hit ENOBUFS in the sendmsg() path with a large batch that is
> composed of many netlink messages. Here that limit is 8 MBytes of
> skbuff data area as kmalloc does not manage to get more than that.
> 
> While discussing atomic rule-set for nftables with Patrick McHardy,
> we decided to put all rule-set updates that need to be applied
> atomically in one single batch to simplify the existing approach.
> However, as explained above, the existing netlink code limits us
> to a maximum of ~20000 rules that fit in one single batch without
> hitting ENOBUFS. iptables does not have such limitation as it is
> using vmalloc.
> 
> This patch adds netlink_alloc_large_skb() which is only used in
> the netlink_sendmsg() path. It uses alloc_skb if the memory
> requested is <= one memory page, that should be the common case
> for most subsystems, else vmalloc for higher memory allocations.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Ok since this is confined to netlink let's give this a shot.
