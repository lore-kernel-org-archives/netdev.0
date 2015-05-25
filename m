From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 -next] ipv6: don't increase size when refragmenting
 forwarded ipv6 skbs
Date: Mon, 25 May 2015 17:22:46 -0400 (EDT)
Message-ID: <20150525.172246.451341177696280298.davem@davemloft.net>
References: <1432248256-28846-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbbEYVWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 17:22:48 -0400
In-Reply-To: <1432248256-28846-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 22 May 2015 00:44:16 +0200

> since commit 6aafeef03b9d ("netfilter: push reasm skb through instead of
> original frag skbs") we will end up sometimes re-fragmenting skbs
> that we've reassembled.
> 
> ipv6 defrag preserves the original skbs using the skb frag list, i.e. as long
> as the skb frag list is preserved there is no problem since we keep
> original geometry of fragments intact.
> 
> However, in the rare case where the frag list is munged or skb
> is linearized, we might send larger fragments than what we originally
> received.
> 
> A router in the path might then send packet-too-big errors even if
> sender never sent fragments exceeding the reported mtu:
> 
> mtu 1500 - 1500:1400 - 1400:1280 - 1280
>      A         R1         R2        B
> 
> 1 - A sends to B, fragment size 1400
> 2 - R2 sends pkttoobig error for 1280
> 3 - A sends to B, fragment size 1280
> 4 - R2 sends pkttoobig error for 1280 again because it sees fragments of size 1400.
> 
> make sure ip6_fragment always caps MTU at largest packet size seen
> when defragmented skb is forwarded.
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied to net-next, thanks.
