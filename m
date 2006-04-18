From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Tue, 18 Apr 2006 14:54:16 -0700 (PDT)
Message-ID: <20060418.145416.114278524.davem@davemloft.net>
References: <20060417171253.4e988afc@localhost.localdomain>
	<E1FVk6q-0000Tf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2743
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750721AbWDRVyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 17:54:21 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1FVk6q-0000Tf-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 18 Apr 2006 16:54:48 +1000

> Looking at this again, the root of this problem is the IGMPv3
> patch which started using the skb->nh.iph->protocol as a key.
> 
> So what we really should do is make the protocol an explicit parameter
> to the ip_route_input function.  This will make it clear to all the
> users which include some pretty weird cases that the protocol is needed.
> 
> In fact I'm unsure as to whether all the other users of ip_route_input
> is safe as it is regarding the protocol.

There are other areas of the packet which are interpreted in various
ways.  For example, the martian source handling will dump the MAC
directly from skb->mac.raw into the kernel logs.

The output path is so much cleaner, because things like the protocol
are filled out in the struct flowi so there is no need to be parsing
the SKB in any way.
