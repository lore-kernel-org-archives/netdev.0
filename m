From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Thu, 25 Sep 2014 09:05:14 -0700
Message-ID: <1411661114.16953.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQJ_FfZEUbFBz4wwZM9Gfbsagfjk51VVbjWJPG7KgJjHWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:47868 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaIYQFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 12:05:15 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so11023248pdi.2
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 09:05:15 -0700 (PDT)
In-Reply-To: <CAADnVQJ_FfZEUbFBz4wwZM9Gfbsagfjk51VVbjWJPG7KgJjHWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 08:53 -0700, Alexei Starovoitov wrote:
> On Thu, Sep 25, 2014 at 7:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > skb->xmit_more tells us if another skb is coming next.
> >
> > We need to send doorbell when : xmit_more is not set,
> > or txqueue is stopped (preventing next skb to come immediately)
> >
> > Tested with a modified pktgen version, I got a 40% increase of
> > throughput.
> 
> this is awesome!
> 
> I've been hacking pktgen as well based on Jesper's earlier patch,
> but in slightly different way. Sounds like you already have working
> pktgen with xmit_more. Do you mind sharing it? even rough patch
> would be great.

The plan was to add a 'pburst x' parameter.

Because not only we want to avoid sending the doorbell, but we could
also not doing the spinlock for every start_xmit().

We also can enforce a global [p]rate (say 100000 packets per second),
but still allow pktgen to send burts of x packets to use (and test) this
xmit_more

Nothing ready yet ;)
