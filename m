From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] ndisc: use netdev_alloc_skb
Date: Wed, 11 Jun 2014 14:40:39 -0700
Message-ID: <20140611144039.672a9b83@nehalam.linuxnetplumber.net>
References: <20140611113109.4c104592@nehalam.linuxnetplumber.net>
	<1402516702.3645.471.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:48637 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbaFKVkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 17:40:43 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so239681pad.34
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2014 14:40:42 -0700 (PDT)
In-Reply-To: <1402516702.3645.471.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2014 12:58:22 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2014-06-11 at 11:31 -0700, Stephen Hemminger wrote:
> > IPv6 neighbor discovery should use netdev_alloc_skb which adds
> > extra space for headroom. The old code would allocate packet w/o any
> > additional headroom and force drivers to reallocate and copy the
> > packet in some cases.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > 
> > --- a/net/ipv6/ndisc.c	2014-06-03 08:06:35.549942475 -0700
> > +++ b/net/ipv6/ndisc.c	2014-06-11 08:54:31.729764741 -0700
> > @@ -375,7 +375,7 @@ static struct sk_buff *ndisc_alloc_skb(s
> >  	struct sock *sk = dev_net(dev)->ipv6.ndisc_sk;
> >  	struct sk_buff *skb;
> >  
> > -	skb = alloc_skb(hlen + sizeof(struct ipv6hdr) + len + tlen, GFP_ATOMIC);
> > +	skb = netdev_alloc_skb(dev, hlen + sizeof(struct ipv6hdr) + len + tlen);
> >  	if (!skb) {
> 
> This looks strange.
> 
> netdev_alloc_skb() is mostly used for RX.
> 
> Perhaps you need to increase hlen with the needed room, because
> NET_SKB_PAD might be only 32, and its a bit hidden.
> 
> ie use LL_RESERVED_SPACE_EXTRA() instead of LL_RESERVED_SPACE(), to make
> clear what the intentions are.

Never mind, I just saw a packet w/o space show up.
It was because of bad driver hard header len
