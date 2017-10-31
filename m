From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] ipv6: Implement limits on Hop-by-Hop and
 Destination options
Date: Mon, 30 Oct 2017 19:52:36 -0700
Message-ID: <1509418356.11887.65.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171030211600.6491-1-tom@quantonium.net>
         <20171031.111026.1763034451245817288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tom@quantonium.net, netdev@vger.kernel.org, rohit@quantonium.net,
        weiwan@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:56442 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdJaCwi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 22:52:38 -0400
Received: by mail-pg0-f54.google.com with SMTP id m18so13391146pgd.13
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 19:52:38 -0700 (PDT)
In-Reply-To: <20171031.111026.1763034451245817288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 11:10 +0900, David Miller wrote:
> From: Tom Herbert <tom@quantonium.net>
> Date: Mon, 30 Oct 2017 14:16:00 -0700
> 
> > I wrote a quick test program that floods a whole bunch of these
> > packets to a host and sure enough there is substantial time spent
> > in ip6_parse_tlv.
>  ...
> >   25.38%  [kernel]                    [k] __fib6_clean_all
> >   21.63%  [kernel]                    [k] ip6_parse_tlv
> 
> Yet the routing code still dominates the cost.

I am guessing the ip6_rt_max_size defaulting to 4096 needs to be
revisited, after all per-cpu added stuff.
