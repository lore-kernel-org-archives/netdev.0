From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nf] ipv6: avoid write to a possibly cloned skb
Date: Mon, 13 Mar 2017 12:54:01 -0700 (PDT)
Message-ID: <20170313.125401.1159069954838003447.davem@davemloft.net>
References: <20170313152428.12514-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750820AbdCMTyD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 15:54:03 -0400
In-Reply-To: <20170313152428.12514-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 13 Mar 2017 16:24:28 +0100

> ip6_fragment, in case skb has a fraglist, checks if the
> skb is cloned.  If it is, it will move to the 'slow path' and allocates
> new skbs for each fragment.
> 
> However, right before entering the slowpath loop, it updates the
> nexthdr value of the last ipv6 extension header to NEXTHDR_FRAGMENT,
> to account for the fragment header that will be inserted in the new
> ipv6-fragment skbs.
> 
> In case original skb is cloned this munges nexthdr value of another
> skb.  Avoid this by doing the nexthdr update for each of the new fragment
> skbs separately.
> 
> This was observed with tcpdump on a bridge device where netfilter ipv6
> reassembly is active:  tcpdump shows malformed fragment headers as
> the l4 header (icmpv6, tcp, etc). is decoded as a fragment header.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Reported-by: Andreas Karis <akaris@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Great catch Florian, applied, thanks.
