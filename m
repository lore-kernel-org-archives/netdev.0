From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] inet: further fixes of possible seqlock deadlocks
Date: Thu, 28 Nov 2013 23:19:26 +0100
Message-ID: <20131128221926.GG24171@order.stressinduktion.org>
References: <13025162.118881385612276530.JavaMail.weblogic@epv6ml01> <1385659390.5352.20.camel@edumazet-glaptop2.roam.corp.google.com> <1385661082.5352.34.camel@edumazet-glaptop2.roam.corp.google.com> <20131128192231.GE24171@order.stressinduktion.org> <1385672502.5352.38.camel@edumazet-glaptop2.roam.corp.google.com> <20131128212700.GF24171@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>, jongman.heo@samsung.com,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45222 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab3K1WT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 17:19:27 -0500
Content-Disposition: inline
In-Reply-To: <20131128212700.GF24171@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 28, 2013 at 10:27:00PM +0100, Hannes Frederic Sowa wrote:
> > > @@ -1524,8 +1524,8 @@ int ip6_push_pending_frames(struct sock *sk)
> > >  	if (proto == IPPROTO_ICMPV6) {
> > >  		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
> > >  
> > > -		ICMP6MSGOUT_INC_STATS_BH(net, idev, icmp6_hdr(skb)->icmp6_type);
> > > -		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
> > > +		ICMP6MSGOUT_INC_STATS(net, idev, icmp6_hdr(skb)->icmp6_type);
> > > +		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
> > 
> > I am not sure we use a seqlock for ICMP stats.
> > 
> > seqlocks were used for 64bit IP stats
> 
> True, atomic longs get used here in both cases.

I don't really understand why we distinguish between _BH and plain ICMP stat
calls then.

The non-_BH versions deactivate interrupts when updating the per-cpu counter.
