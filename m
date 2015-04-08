From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] udp_tunnel: Pass UDP socket down through
 udp_tunnel{,6}_xmit_skb().
Date: Tue, 07 Apr 2015 22:13:28 -0400 (EDT)
Message-ID: <20150407.221328.1961195097281515709.davem@davemloft.net>
References: <1428421534.2928.3.camel@stressinduktion.org>
	<20150407.153044.772260953305341361.davem@davemloft.net>
	<1428449099.869458.250499317.11121567@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, tom@herbertland.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428449099.869458.250499317.11121567@webmail.messagingengine.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 08 Apr 2015 01:24:59 +0200

> There is one small problem which already was present before this patch
> because of my change b6a7719aedd7e5 ("ipv4: hash net ptr into
> fragmentation bucket selection"). It uses sock_net in iptunnel_xmit,
> which causes a NULL ptr panic. This patchset did make it more visible
> because of the explicit NULL passing but the bug was introduced by my
> patch.
> 
> Just wanted to let you know if reports are coming in - I fix it up
> tomorrow. I will also explore the possibility to give each tunnel at
> least a raw socket, what Tom proposed.
> 
> Rick Jones identified this, thanks!

Looking into this I also notice that ipip6_tunnel_xmit() passes
in skb->sk, that needs to be NULL too.

Want to take care of that along with your sock_net() fix?

Thanks!
