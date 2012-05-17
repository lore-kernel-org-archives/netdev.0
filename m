From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Thu, 17 May 2012 18:40:16 +0200
Message-ID: <20120517164016.GL14498@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu> <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu> <1337272404.3403.18.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2331 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932489Ab2EQQkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 12:40:21 -0400
Content-Disposition: inline
In-Reply-To: <1337272404.3403.18.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 06:33:24PM +0200, Eric Dumazet wrote:
> On Thu, 2012-05-17 at 17:56 +0200, Willy Tarreau wrote:
> > On Thu, May 17, 2012 at 05:43:00PM +0200, Eric Dumazet wrote:
> 
> > It's the NIC included in the system-on-chip (Marvell 88F6281), and the NIC
> > driver is mv643xx. It's the same hardware you find in sheevaplugs, guruplugs,
> > dreamplugs and almost all ARM-based cheap NAS boxes.
> > 
> > > With commit 1d0c0b328a6 in net-next
> > > (net: makes skb_splice_bits() aware of skb->head_frag)
> > > You'll be able to get even more speed, if NIC uses frag to hold frame.
> > 
> > I'm going to check this now, sounds interesting :-)
> 
> splice(socket -> pipe) does a copy of frame from skb->head to a page
> fragment.
> 
> With latest patches (net-next), we can provide a frag for skb->head and
> avoid this copy in splice(). You would have a true zero copy
> socket->socket mode.

That's what I've read in your commit messages. Indeed, we've been waiting
for this to happen for a long time. It should bring a real benefit on small
devices like the one I'm playing with which have very low memory bandwidth,
because it's a shame to copy the data and thrash the cache when we don't
need to see them.

I'm currently trying to get mainline to boot then I'll switch to net-next.

> tg3 drivers uses this new thing, mv643xx_eth.c could be changed as well.

I'll try to port your patch (8d4057 tg3: provide frags as skb head) to
mv643xx_eth as an exercise. If I succeed and notice an improvement, I'll
send a patch :-)

Cheers,
Willy
