From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 18:47:54 +0200
Message-ID: <1337273274.3403.22.camel@edumazet-glaptop>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu>
	 <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu>
	 <1337272404.3403.18.camel@edumazet-glaptop> <20120517164016.GL14498@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40863 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758969Ab2EQQr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 12:47:59 -0400
Received: by eaak11 with SMTP id k11so579621eaa.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 09:47:58 -0700 (PDT)
In-Reply-To: <20120517164016.GL14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 18:40 +0200, Willy Tarreau wrote:
> On Thu, May 17, 2012 at 06:33:24PM +0200, Eric Dumazet wrote:
> > On Thu, 2012-05-17 at 17:56 +0200, Willy Tarreau wrote:
> > > On Thu, May 17, 2012 at 05:43:00PM +0200, Eric Dumazet wrote:
> > 
> > > It's the NIC included in the system-on-chip (Marvell 88F6281), and the NIC
> > > driver is mv643xx. It's the same hardware you find in sheevaplugs, guruplugs,
> > > dreamplugs and almost all ARM-based cheap NAS boxes.
> > > 
> > > > With commit 1d0c0b328a6 in net-next
> > > > (net: makes skb_splice_bits() aware of skb->head_frag)
> > > > You'll be able to get even more speed, if NIC uses frag to hold frame.
> > > 
> > > I'm going to check this now, sounds interesting :-)
> > 
> > splice(socket -> pipe) does a copy of frame from skb->head to a page
> > fragment.
> > 
> > With latest patches (net-next), we can provide a frag for skb->head and
> > avoid this copy in splice(). You would have a true zero copy
> > socket->socket mode.
> 
> That's what I've read in your commit messages. Indeed, we've been waiting
> for this to happen for a long time. It should bring a real benefit on small
> devices like the one I'm playing with which have very low memory bandwidth,
> because it's a shame to copy the data and thrash the cache when we don't
> need to see them.
> 
> I'm currently trying to get mainline to boot then I'll switch to net-next.
> 
> > tg3 drivers uses this new thing, mv643xx_eth.c could be changed as well.
> 
> I'll try to port your patch (8d4057 tg3: provide frags as skb head) to
> mv643xx_eth as an exercise. If I succeed and notice an improvement, I'll
> send a patch :-)

In fact I could post a generic patch, to make netdev_alloc_skb() do this
automatically for all network drivers.

Its probably less than 30 lines of code.
