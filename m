From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 19:35:53 +0100
Message-ID: <20130123183553.GA13433@order.stressinduktion.org>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com> <CAJ4BwwFYKYOJoP34cGqWyE_AzxMwDNqFG-XDjLB6ZdO4nQmY4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Yannick Koehler <yannick@koehler.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46961 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab3AWSfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 13:35:54 -0500
Content-Disposition: inline
In-Reply-To: <CAJ4BwwFYKYOJoP34cGqWyE_AzxMwDNqFG-XDjLB6ZdO4nQmY4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 11:41:16AM -0500, Yannick Koehler wrote:
> I did some more research, I found out that netlink and
> sock_queue_err_skb does the same trick that I claim to be missing
> under the net/unix/af_unix.c.  After adding the code, I got a problem
> since af_unix.c "_recvmsg()" functions assume that the skb->sk is
> holding the peer socket not the current one related to the receive
> skb.  It extract the sun_path name from it.  Since with UDP each
> packet may have a different peer, the only solution I found was to use
> the skb control block to hold the peer name.  The problem is that this
> cb member is 48 bytes in length and sun_path is 108 bytes in size.  So
> I had to increase it from 48 to 160 bytes.
> 
> This obviously increase the cost of an SKB struct, so I do not really
> like this solution. But at least it seems to prove my point and now,
> with this I can have my clients working except the one mis-behaving.
> I am attaching a patch.

Yes, you cannot do that. I would try to place a refcounted pointer to the
original sk in unix_skb_params. Perhaps a refcounted unix_address will dot the
trick, too.
