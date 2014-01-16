From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH V2 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag to IPV6_FL_A_GET
Date: Thu, 16 Jan 2014 13:35:15 +0100
Message-ID: <20140116123515.GD7436@order.stressinduktion.org>
References: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20140115224726.GH19945@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42380 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaAPMfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 07:35:17 -0500
Content-Disposition: inline
In-Reply-To: <20140115224726.GH19945@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 11:47:26PM +0100, Hannes Frederic Sowa wrote:
> > @@ -1138,6 +1142,8 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
> >  		newnp->mcast_oif   = inet6_iif(skb);
> >  		newnp->mcast_hops  = ipv6_hdr(skb)->hop_limit;
> >  		newnp->rcv_flowinfo = ip6_flowinfo(ipv6_hdr(skb));
> > +		if (np->repflow)
> > +			newnp->flow_label = ip6_flowlabel(ipv6_hdr(skb));
> 
> Just asking:
> 
> Was there a specific reason you did not use np->flow_label here and just
> mirroring the flowlabel from the first packet of the connection for the
> whole connection?
> 
> I don't know if it makes a difference, but maybe it was done on purpose?

I thought about it and am actually in favor of reusing the flowid from the syn
packet so userspace does report correct outgoing flowlabel even in case of
strange tcp peer changing it mid-stream.

Thanks,

  Hannes
