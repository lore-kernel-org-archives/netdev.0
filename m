From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: RFC6298 supersedes RFC2988bis
Date: Sun, 15 Apr 2012 22:01:01 +0200
Message-ID: <1334520061.28012.36.camel@edumazet-glaptop>
References: <1334296120.5300.8404.camel@edumazet-glaptop>
	 <CAPshTCiew0w4kF2yE=Bn_E702vxdFwZipnnEpsAuhSm6OO187Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43562 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968Ab2DOUBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 16:01:06 -0400
Received: by bkcik5 with SMTP id ik5so3177085bkc.19
        for <netdev@vger.kernel.org>; Sun, 15 Apr 2012 13:01:05 -0700 (PDT)
In-Reply-To: <CAPshTCiew0w4kF2yE=Bn_E702vxdFwZipnnEpsAuhSm6OO187Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-04-15 at 11:33 -0700, Jerry Chu wrote:
> [send again - it looks like my previous comment was lost...]
> 
> On Thu, Apr 12, 2012 at 10:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Updates some comments to track RFC6298
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: H.K. Jerry Chu <hkchu@google.com>
> > Cc: Tom Herbert <therbert@google.com>
> > ---
> > BTW, one side effect of the TCP_TIMEOUT_INIT change (3 -> 1) is
> > () latency is 200% worse:
> 
> Or even worse - 300% (3/1)?

well, 3 instead of 1 is a 200% increase ;)

> 
> >
> > It fires every 200ms and scans 40% of hash table each time, listener
> > socket held.
> 
> If this becomes a real issue we could decrease TCP_SYNQ_INTERVAL,
> essentially making the keepalive timer fire more often, but each time with
> less work to do?

Hmm... 200ms is already aggressive for power saving

> 
> Also why is
> budget = 2 * (lopt->nr_table_entries / (timeout / interval));
> rather than
> budget = (lopt->nr_table_entries / (timeout / interval)) + 1;
> ?

Thats because if we do that, retransmits could be delayed by 100%,
instead of 50% with this solution.

(right now it takes 2.5 rounds to scan whole table, so a one sec 'timer'
can be fired after 1.6 second)
