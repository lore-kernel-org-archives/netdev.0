From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix a bug in SRR option matching.
Date: Tue, 08 Nov 2011 12:06:21 -0500 (EST)
Message-ID: <20111108.120621.691425261290061620.davem@davemloft.net>
References: <4EB8E0B8.40500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984Ab1KHRGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 12:06:31 -0500
In-Reply-To: <4EB8E0B8.40500@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Tue, 08 Nov 2011 15:56:40 +0800

> Since commit 7be799a7 (ipv4: Remove rt->rt_dst reference from
> ip_forward_options()) and commit 0374d9ce (ipv4: Kill spurious
> write to iph->daddr in ip_forward_options()) we use iph->daddr
> for SRR option matching and assume iph->daddr equals to rt->rt_dst,
> Unfortunately skb_rtable(skb) has been updated in ip_options_rcv_srr()
> for the nexthop in SRR option but iph->daddr *not* updated,
> We should use the updated rt->rt_dst for SRR option matching
> and update iph->daddr here.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Please replace this by whatever logic ip_options_rcv_srr() uses to
determine the destination address.

I would strongly encourage you, when fixing bugs like this, to use
as a hint the intentions of the commit which introduced the bug.  And
try as hard as possible to retain the goals of the guilty commit.

In this case, that means not introducing references to rt->rt_dst
back into the code.

Thank you.
