From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] netlink: fix compat recvmsg
Date: Mon, 16 Aug 2010 14:54:39 +0200
Message-ID: <1281963279.3683.16.camel@jlt3.sipsolutions.net>
References: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
	 <1281710887.4470.78.camel@edumazet-laptop>
	 <1281712433.2116.15.camel@jlt3.sipsolutions.net>
	 <20100814.223722.116371746.davem@davemloft.net>
	 <1281936351.3683.1.camel@jlt3.sipsolutions.net>
	 <1281939002.2942.70.camel@edumazet-laptop>
	 <1281939753.3683.5.camel@jlt3.sipsolutions.net>
	 <1281940172.2942.81.camel@edumazet-laptop>
	 <1281943244.3683.8.camel@jlt3.sipsolutions.net>
	 <1281963025.2524.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Kalle Valo <kalle.valo@iki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:57058 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0HPMyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 08:54:41 -0400
In-Reply-To: <1281963025.2524.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-16 at 14:50 +0200, Eric Dumazet wrote:

> > Additionally, while preparing this patch I found
> > that since none of the remaining netlink code is
> > really aware of the frag_list, we need to use the
> > original skb's information for packet information
> > and credentials. This fixes, for example, the
> > group information received by compat tasks.

> As a side effect, it might fix the 
> 
> 	if (nlk->flags & NETLINK_RECV_PKTINFO)
> 		netlink_cmsg_recv_pktinfo(msg, skb);
> 
> That tried to use pktinfo from the slave skb. After this
> patch, skb points to master skb.

Yeah, that's what I was looking at regarding the "packet information" I
wrote about. The group information was wrong (0 rather than 1), I could
see that in strace (though I had to compile a strace64 binary first...)

> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Thanks !

Thanks for looking, and finding the bug to start with :-)

johannes

