From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] about "net: orphan frags on receive" insanity
Date: Wed, 26 Jun 2013 22:22:02 +0300
Message-ID: <20130626192202.GB10713@redhat.com>
References: <1372235039.3301.126.camel@edumazet-glaptop>
 <20130626095642.GA20982@redhat.com>
 <1372241543.3301.157.camel@edumazet-glaptop>
 <20130626185614.GA10713@redhat.com>
 <1372273764.3301.200.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23725 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633Ab3FZTVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:17 -0400
Content-Disposition: inline
In-Reply-To: <1372273764.3301.200.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 12:09:24PM -0700, Eric Dumazet wrote:
> On Wed, 2013-06-26 at 21:56 +0300, Michael S. Tsirkin wrote:
> 
> > Well we don't want to duplicate the whole RX path
> > to special-case that, right?
> 
> 
> Whats wrong using a helper ?
> 
> I_Should_cleanup_things(skb)
> {
> 	... // cleanup for these special users trying to reenter stack
> 
> 	netif_rx(skb);
> }
> 

The point is we don't know the final destination of the packet
until it's going through the stack.

We don't want to trigger a copy for all data we get from tun:
we only want to do this if the data has a chance to get
queued somewhere indefinitely.


-- 
MST
