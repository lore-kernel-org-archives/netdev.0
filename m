From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] openvswitch: Orphan skbs before IPv6 defrag
Date: Thu, 21 Apr 2016 13:42:52 -0400 (EDT)
Message-ID: <20160421.134252.2090014694706317498.davem@davemloft.net>
References: <1461016307-14098-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de,
	netfilter-devel@vger.kernel.org, diproiettod@vmware.com,
	pablo@netfilter.org
To: joe@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbcDURm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 13:42:58 -0400
In-Reply-To: <1461016307-14098-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>
Date: Mon, 18 Apr 2016 14:51:47 -0700

> This is the IPv6 counterpart to commit 8282f27449bf ("inet: frag: Always
> orphan skbs inside ip_defrag()").
> 
> Prior to commit 029f7f3b8701 ("netfilter: ipv6: nf_defrag: avoid/free
> clone operations"), ipv6 fragments sent to nf_ct_frag6_gather() would be
> cloned (implicitly orphaning) prior to queueing for reassembly. As such,
> when the IPv6 message is eventually reassembled, the skb->sk for all
> fragments would be NULL. After that commit was introduced, rather than
> cloning, the original skbs were queued directly without orphaning. The
> end result is that all frags except for the first and last may have a
> socket attached.
> 
> This commit explicitly orphans such skbs during nf_ct_frag6_gather() to
> prevent BUG_ON(skb->sk) during a later call to ip6_fragment().
 ...
> Fixes: 029f7f3b8701 ("netfilter: ipv6: nf_defrag: avoid/free clone
> operations")
> Reported-by: Daniele Di Proietto <diproiettod@vmware.com>
> Signed-off-by: Joe Stringer <joe@ovn.org>

Applied and queued up for -stable, thanks.
