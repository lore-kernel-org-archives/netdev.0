From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: frag: Always orphan skbs inside ip_defrag()
Date: Thu, 28 Jan 2016 16:02:06 -0800 (PST)
Message-ID: <20160128.160206.1148428775767129968.davem@davemloft.net>
References: <1453506552-10373-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, hannes@stressinduktion.org,
	pshelar@ovn.org
To: joe@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbcA2ACI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 19:02:08 -0500
In-Reply-To: <1453506552-10373-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>
Date: Fri, 22 Jan 2016 15:49:12 -0800

> Later parts of the stack (including fragmentation) expect that there is
> never a socket attached to frag in a frag_list, however this invariant
> was not enforced on all defrag paths. This could lead to the
> BUG_ON(skb->sk) during ip_do_fragment(), as per the call stack at the
> end of this commit message.
> 
> While the call could be added to openvswitch to fix this particular
> error, the head and tail of the frags list are already orphaned
> indirectly inside ip_defrag(), so it seems like the remaining fragments
> should all be orphaned in all circumstances.
 ...
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Joe Stringer <joe@ovn.org>

Applied and queued up for -stable, thanks Joe.
