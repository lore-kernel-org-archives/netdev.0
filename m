From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Fri, 24 Dec 2010 00:04:39 +0100
Message-ID: <20101223230439.GB1913@del.dom.local>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
 <20101220232020.GB2052@del.dom.local>
 <1292887689.2627.150.camel@edumazet-laptop>
 <20101220235209.GA1865@del.dom.local>
 <1292939574.6535.27.camel@mojatatu>
 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
 <20101221223704.GA1979@del.dom.local>
 <1293111333.11306.170.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54863 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab0LWXEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 18:04:46 -0500
Received: by bwz15 with SMTP id 15so7820738bwz.19
        for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 15:04:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1293111333.11306.170.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 23, 2010 at 08:35:33AM -0500, jamal wrote:
> On Tue, 2010-12-21 at 23:37 +0100, Jarek Poplawski wrote:
> 
> > Actually, when dumb isn't a good principle? ;->
> > 
> > Speaking about wrong things like optimizing this 1st commandment: it
> > seems, if we're stealing not shared skb it's not unreasonable to tell
> > others not to touch it anymore, and skip kfree_skb() in handle_ing(),
> > unless I miss something?
> 
> I dont know how much cycles it will save you vs the code you add
> but it is not unreasonable. Of course it would mean we are moving
> beyond KISSes[1] now Jarek;->

Hmm... seeing all those multiqued multiques I thought everybody was
beyond, but no problem, let's go back to KISSes[2] ;-)

> > > In order to make my trick work. We need to assure dev_queue_xmit() and
> > > dev_hard_start_xmit() accept shared skbs. As Eric pointed, pktgen also
> > > need dev->netdev_ops->ndo_start_xmit() accept shared skbs. We need to
> > > fix every ndo_start_xmit() one by one, then dev_hard_start_xmit(), and
> > > when dev_queue_xmit() is also fixed, my trick can be added back.
> > > :)
> > 
> > I'm not sure pktgen is right - even if it's safe in its case, it seems
> > to break some older rules, and drivers should really own the things.
> > So it needs reviewing first.
> 
> The idea we always try to keep is that the caller is responsible for the
> fate of the skb it sent. The callee will do things like make a copy or
> clone if it needed to make changes or keep the skb. Same should be
> expected of a driver.

Well, I'm not sure we talk about the same thing. I mean e.g. the
comment above dev_queue_xmit(); the caller passes all control to the
callee here.

Cheers,
Jarek P.

> [1] Jarek - so you dont misunderstand this as an overture - it means
> Keep It Simple Silly (or the principle of dumb we talked about) ;->

OK, I can remember the seventies too ;-)
