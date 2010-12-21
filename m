From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Tue, 21 Dec 2010 23:37:05 +0100
Message-ID: <20101221223704.GA1979@del.dom.local>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
 <20101220232020.GB2052@del.dom.local>
 <1292887689.2627.150.camel@edumazet-laptop>
 <20101220235209.GA1865@del.dom.local>
 <1292939574.6535.27.camel@mojatatu>
 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:40030 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753677Ab0LUWhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 17:37:11 -0500
Received: by bwz16 with SMTP id 16so5143393bwz.4
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 14:37:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 10:17:35PM +0800, Changli Gao wrote:
> On Tue, Dec 21, 2010 at 9:52 PM, jamal <hadi@cyberus.ca> wrote:
> >
> > Use to be we couldnt get the ifb+mirred combo to work
> > with TSO even without this change - i will have to dig old emails
> > to remember details. So we are making progress;-> I did write a set
> > of rules in: Documentation/networking/tc-actions-env-rules.txt
> > Changli optimized rule #1. When i looked at his patch it seems
> > to not harm that case. Sometimes dumb is a good principle ;->

Actually, when dumb isn't a good principle? ;->

Speaking about wrong things like optimizing this 1st commandment: it
seems, if we're stealing not shared skb it's not unreasonable to tell
others not to touch it anymore, and skip kfree_skb() in handle_ing(),
unless I miss something?


> In order to make my trick work. We need to assure dev_queue_xmit() and
> dev_hard_start_xmit() accept shared skbs. As Eric pointed, pktgen also
> need dev->netdev_ops->ndo_start_xmit() accept shared skbs. We need to
> fix every ndo_start_xmit() one by one, then dev_hard_start_xmit(), and
> when dev_queue_xmit() is also fixed, my trick can be added back.
> :)

I'm not sure pktgen is right - even if it's safe in its case, it seems
to break some older rules, and drivers should really own the things.
So it needs reviewing first.

Cheers,
Jarek P.
