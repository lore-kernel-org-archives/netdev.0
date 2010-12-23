From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Thu, 23 Dec 2010 08:35:33 -0500
Message-ID: <1293111333.11306.170.camel@mojatatu>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:36198 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab0LWNfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 08:35:37 -0500
Received: by gwj20 with SMTP id 20so3537038gwj.19
        for <netdev@vger.kernel.org>; Thu, 23 Dec 2010 05:35:36 -0800 (PST)
In-Reply-To: <20101221223704.GA1979@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-21 at 23:37 +0100, Jarek Poplawski wrote:

> Actually, when dumb isn't a good principle? ;->
> 
> Speaking about wrong things like optimizing this 1st commandment: it
> seems, if we're stealing not shared skb it's not unreasonable to tell
> others not to touch it anymore, and skip kfree_skb() in handle_ing(),
> unless I miss something?

I dont know how much cycles it will save you vs the code you add
but it is not unreasonable. Of course it would mean we are moving
beyond KISSes[1] now Jarek;->

> > In order to make my trick work. We need to assure dev_queue_xmit() and
> > dev_hard_start_xmit() accept shared skbs. As Eric pointed, pktgen also
> > need dev->netdev_ops->ndo_start_xmit() accept shared skbs. We need to
> > fix every ndo_start_xmit() one by one, then dev_hard_start_xmit(), and
> > when dev_queue_xmit() is also fixed, my trick can be added back.
> > :)
> 
> I'm not sure pktgen is right - even if it's safe in its case, it seems
> to break some older rules, and drivers should really own the things.
> So it needs reviewing first.

The idea we always try to keep is that the caller is responsible for the
fate of the skb it sent. The callee will do things like make a copy or
clone if it needed to make changes or keep the skb. Same should be
expected of a driver.


cheers,
jamal

[1] Jarek - so you dont misunderstand this as an overture - it means
Keep It Simple Silly (or the principle of dumb we talked about) ;->

