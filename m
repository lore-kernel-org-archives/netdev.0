From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need also be handled by UFO
Date: Wed, 2 Oct 2013 14:12:07 +0200
Message-ID: <20131002121207.GO10771@order.stressinduktion.org>
References: <20130921042700.GB8070@order.stressinduktion.org> <20130930114343.GA6356@minipsycho.brq.redhat.com> <20130930172312.GE10771@order.stressinduktion.org> <20131001105837.GA1424@minipsycho.brq.redhat.com> <20131001120907.GH10771@order.stressinduktion.org> <20131001123214.GI10771@order.stressinduktion.org> <20131001214721.GJ10771@order.stressinduktion.org> <20131001232534.GM10771@order.stressinduktion.org> <20131002085842.GA1528@minipsycho.brq.redhat.com> <1380710488.19002.67.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, herbert@gondor.apana.org.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35938 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913Ab3JBMMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 08:12:09 -0400
Content-Disposition: inline
In-Reply-To: <1380710488.19002.67.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric!

On Wed, Oct 02, 2013 at 03:41:28AM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-02 at 10:58 +0200, Jiri Pirko wrote:
> > Wed, Oct 02, 2013 at 01:25:34AM CEST, hannes@stressinduktion.org wrote:
> > >-	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
> > >+	if (((length > mtu) || (skb && skb_has_frags(skb))) &&
> 
> > 
> > This seems correct to me. sk_is_gso would work as well is you apply my
> > patch "[patch net] ip6_output: do skb ufo init for peeked non ufo skb as
> > well" which does the setting of gso_size.
> 
> Well, skb having frags or not should not be a concern :
> Thats an allocation choice (lets say to avoid high order allocations). 
> 
> Setting gso_size is probably better.

e89e9cf539a28df7d0eb1d0a545368e9920b34ac ("[IPv4/IPv6]: UFO Scatter-gather
approach") states:

"
skb->data will contain MAC/IP/UDP header and skb_shinfo(skb)->frags[]
contains the data payload. The skb->ip_summed will be set to CHECKSUM_HW
indicating that hardware has to do checksum calculation. Hardware should
compute the UDP checksum of complete datagram and also ip header checksum of
each fragmented IP packet.
"

This is the reason why I tried not to update the gso_size. If it is ok, I am
fine with that.

Greetings,

  Hannes
