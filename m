From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a
	socket attached to the skb
Date: Thu, 2 Oct 2008 14:09:35 -0300
Message-ID: <20081002170935.GE17843@ghostprotocols.net>
References: <20081001142431.4893.69772.stgit@este> <20081001.075040.135314845.davem@davemloft.net> <1222875500.7492.6.camel@este> <20081001.085104.193726318.davem@davemloft.net> <1222962200.14079.19.camel@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49536 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953AbYJBRLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 13:11:54 -0400
Content-Disposition: inline
In-Reply-To: <1222962200.14079.19.camel@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Oct 02, 2008 at 05:43:20PM +0200, KOVACS Krisztian escreveu:
> Hi,
> 
> On Wed, 2008-10-01 at 08:51 -0700, David Miller wrote:
> > From: KOVACS Krisztian <hidden@sch.bme.hu>
> > Date: Wed, 01 Oct 2008 17:38:20 +0200
> > 
> > > The problem is that if you include the if() test then you have to
> > > include the lookup call as well and that's different for TCP/UDP.
> > 
> > No, I only mean to make a helper for this construct:
> > 
> > 	if (unlikely(skb->sk)) {
> > 		...
> > 	}
> > 
> > so, something like:
> > 
> > static inline struct sock *sock_skb_steal(struct sk_buff *skb)
> > {
> > 	if (unlikely(skb->sk)) {
> > 		struct sock *sk = skb->sk;
> > 
> > 		skb->destructor = NULL;
> > 		skb->sk = NULL;
> > 		return sk;
> > 	}
> > 	return NULL;
> > }
> > 
> > and then also get rid of the ifdefs at the place where
> > these calls are made (TCP and UDP).
> 
> Something like this?
> 
> - 8< -

Why don't you add it to __inet6_lookup, __inet6_lookup and the udp_lib
lookup routines? And please rename it to skb_steal_sock, as it acts on a
skb, not on a sock.

- Arnaldo
