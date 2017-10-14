From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 3/3] tcp: keep tcp_collapse controllable even after
 processing starts
Date: Sat, 14 Oct 2017 08:46:10 -0700
Message-ID: <1507995970.31614.59.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171014072745.23462-1-den@klaipeden.com>
         <20171014072745.23462-4-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:45825 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753759AbdJNPqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 11:46:12 -0400
Received: by mail-pg0-f66.google.com with SMTP id b192so3495349pga.2
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 08:46:11 -0700 (PDT)
In-Reply-To: <20171014072745.23462-4-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-14 at 16:27 +0900, Koichiro Den wrote:
> Combining actual collapsing with reasoning for deciding the starting
> point, we can apply its logic in a consistent manner such that we can
> avoid costly yet not much useful collapsing. When collapsing to be
> triggered, it's not rare that most of the skbs in the receive or ooo
> queue are large ones without much metadata overhead. This also
> simplifies code and makes it easier to apply logic in a fair manner.
> 
> Subtle subsidiary changes included:
> - When the end_seq of the skb we are trying to collapse was larger than
>   the 'end' argument provided, we would end up copying to the 'end'
>   even though we couldn't collapse the original one. Current users of
>   tcp_collapse does not require such reserves so redefines it as the
>   point over which skbs whose seq passes guranteed not to be collapsed.
> - Naturally tcp_collapse_ofo_queue shapes up and we no longer need
>   'tail' argument.


I am not inclined to review such a large change, without you providing
actual numbers.

We have a problem in TCP right now, that receiver announces a too big
window, and that is the main reason we trigger collapsing.

I would rather fix the root cause.
