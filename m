From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] tcp: Don't collapse if resulting skb could overflow
 skb->csum_start
Date: Thu, 28 Feb 2013 19:23:51 +0000
Message-ID: <20130228192351.GE7558@casper.infradead.org>
References: <20130228102603.GA7558@casper.infradead.org>
 <1362068326.15793.33.camel@edumazet-glaptop>
 <20130228164502.GD7558@casper.infradead.org>
 <1362072952.15793.41.camel@edumazet-glaptop>
 <1362073254.15793.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, foraker1@llnl.gov
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51752 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab3B1TX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 14:23:59 -0500
Content-Disposition: inline
In-Reply-To: <1362073254.15793.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/13 at 09:40am, Eric Dumazet wrote:
> On Thu, 2013-02-28 at 09:35 -0800, Eric Dumazet wrote:
> > This had a followup with 22b4a4f22da4
> > (tcp: fix retransmit of partially acked frames)
> > 
> > I also wonder if there is not another similar potential problem in
> > __tcp_retransmit_skb) after call to 
> > 
> > tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq)
> > 
> > csum_start can overflow again because of MAX_TCP_HEADER headroom
> > reserve.
> > 
> > So maybe we should limit TCP MTU to (64K - MAX_TCP_HEADER)
> > 
> 
> Or adapt the test at line 2390 in net/ipv4/tcp_output.c
> 
> to force in the case there could be an overflow a :
> 
> struct sk_buff *nskb = __pskb_copy()
> 
> So that we have a new skb with minimal headroom.

I would favour the __pskb_copy() variant as that would be more
generic. I'll redo the patch.
