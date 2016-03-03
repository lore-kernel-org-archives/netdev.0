From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: re-enable fragment header matching in
 ipv6_find_hdr
Date: Thu, 03 Mar 2016 16:35:50 -0500 (EST)
Message-ID: <20160303.163550.2242180028119993566.davem@davemloft.net>
References: <1456845316-26269-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757734AbcCCVfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:35:52 -0500
In-Reply-To: <1456845316-26269-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  1 Mar 2016 16:15:16 +0100

> When ipv6_find_hdr is used to find a fragment header
> (caller specifies target NEXTHDR_FRAGMENT) we erronously return
> -ENOENT for all fragments with nonzero offset.
> 
> Before commit 9195bb8e381d, when target was specified, we did not
> enter the exthdr walk loop as nexthdr == target so this used to work.
> 
> Now we do (so we can skip empty route headers). When we then stumble upon
> a frag with nonzero frag_off we must return -ENOENT ("header not found")
> only if the caller did not specifically request NEXTHDR_FRAGMENT.
> 
> This allows nfables exthdr expression to match ipv6 fragments, e.g. via
> 
> nft add rule ip6 filter input frag frag-off gt 0
> 
> Fixes: 9195bb8e381d ("ipv6: improve ipv6_find_hdr() to skip empty routing headers")
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks Florian.
