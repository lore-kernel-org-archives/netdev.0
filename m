From: Koichiro Den <den@klaipeden.com>
Subject: Re: [net-next 3/3] tcp: keep tcp_collapse controllable even after
 processing starts
Date: Sun, 15 Oct 2017 11:45:49 +0900
Message-ID: <1508035549.29679.4.camel@klaipeden.com>
References: <20171014072745.23462-1-den@klaipeden.com>
         <20171014072745.23462-4-den@klaipeden.com>
         <1507995970.31614.59.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21366 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751138AbdJOCpx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 22:45:53 -0400
In-Reply-To: <1507995970.31614.59.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-14 at 08:46 -0700, Eric Dumazet wrote:
> On Sat, 2017-10-14 at 16:27 +0900, Koichiro Den wrote:
> > Combining actual collapsing with reasoning for deciding the starting
> > point, we can apply its logic in a consistent manner such that we can
> > avoid costly yet not much useful collapsing. When collapsing to be
> > triggered, it's not rare that most of the skbs in the receive or ooo
> > queue are large ones without much metadata overhead. This also
> > simplifies code and makes it easier to apply logic in a fair manner.
> > 
> > Subtle subsidiary changes included:
> > - When the end_seq of the skb we are trying to collapse was larger than
> >   the 'end' argument provided, we would end up copying to the 'end'
> >   even though we couldn't collapse the original one. Current users of
> >   tcp_collapse does not require such reserves so redefines it as the
> >   point over which skbs whose seq passes guranteed not to be collapsed.
> > - Naturally tcp_collapse_ofo_queue shapes up and we no longer need
> >   'tail' argument.
> 
> 
> I am not inclined to review such a large change, without you providing
> actual numbers.
> 
> We have a problem in TCP right now, that receiver announces a too big
> window, and that is the main reason we trigger collapsing.
> 
> I would rather fix the root cause.
> 
> 
Ok I got it, thank you.
