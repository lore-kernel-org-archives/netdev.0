From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Mon, 08 Apr 2013 16:53:57 -0400
Message-ID: <1798267.sYWPbozUai@sifl>
References: <1365445303.3887.33.camel@edumazet-glaptop> <3294227.D2rod7xgQB@sifl> <20130408.164439.2282891058177074789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, mvadkert@redhat.com
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763340Ab3DHUyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 16:54:00 -0400
In-Reply-To: <20130408.164439.2282891058177074789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 08, 2013 04:44:39 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Mon, 08 Apr 2013 16:37:22 -0400
> 
> > On Monday, April 08, 2013 11:30:25 AM Eric Dumazet wrote:
> >> On Mon, 2013-04-08 at 11:21 -0700, Eric Dumazet wrote:
> >> > On Mon, 2013-04-08 at 14:12 -0400, Paul Moore wrote:
> >> > > It seems a bit fragile to me, perhaps even hacky, but in some ways I
> >> > > guess it isn't anymore fragile than relying on skb->sk - as this
> >> > > problem demonstrates. My other concern is that adding this hook
> >> > > *correctly* is likely to touch a lot of files and may be a bit much
> >> > > so late in the 3.9 cycle, Dave, what say you?>
> >> > 
> >> > I don't get it, 90ba9b1986b5ac4b2d18 was in 3.6, why do you care of
> >> > 3.9 ?
> >> > 
> >> > I am preparing a fix right now. Not a revert, thank you.
> >> 
> >> Is the following patch not good enough ?
> > 
> > I think it is somewhat telling that the hook you're proposing doesn't ever
> > make any calls into any of the individual LSMs, it only calls back into
> > the networking stack.  In my mind, this makes it an abuse of the LSM
> > mechanism.
> 
> Without LSMs the socket reference is spurious and pointless overhead,
> therefore the only acceptable fix one which only takes the socket
> reference when there are LSMs with a need.

Well that's frustrating, but if that is the game so be it.

Eric, your patch didn't cross-post to the LSM list, do you want to post it 
there for review/merging?  I would recommend also adding a pointer to this 
thread for reference.

-- 
paul moore
security and virtualization @ redhat
