From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix a bug in strict route gateway comparation.
Date: Tue, 08 Nov 2011 12:07:10 -0500 (EST)
Message-ID: <20111108.120710.136890691041522812.davem@davemloft.net>
References: <4EB8EBF8.1080508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984Ab1KHRHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 12:07:18 -0500
In-Reply-To: <4EB8EBF8.1080508@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Tue, 08 Nov 2011 16:44:40 +0800

> Since commit def57687 (ipv4: Elide use of rt->rt_dst in ip_forward())
> we use iph->daddr for strict route gateway comparation, Unfortunately
> skb_rtable(skb) has been updated in ip_options_rcv_srr() for the
> nexthop in SRR option but iph->daddr *not* updated, So rt->rt_dst is
> not equals to iph->daddr, We should use the updated rt->rt_dst instead.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Same comments as the other patch, add whatever logic is necessary to
compute the destination address such that we don't need to add back
an rt->rt_dst reference here.
