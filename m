From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix various issues for sockets morphing to
 listen state
Date: Tue, 07 Mar 2017 13:59:20 -0800 (PST)
Message-ID: <20170307.135920.663771797825250884.davem@davemloft.net>
References: <CANn89iLNQKyywwLAdJsQDOpGDtEs6S-4BZkZYmwT39ENZyqLTg@mail.gmail.com>
        <1488574561.9415.336.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488578901.9415.353.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dvyukov@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41260 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752908AbdCHDYg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 22:24:36 -0500
In-Reply-To: <1488578901.9415.353.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Mar 2017 14:08:21 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry Vyukov reported a divide by 0 triggered by syzkaller, exploiting
> tcp_disconnect() path that was never really considered and/or used
> before syzkaller ;)
> 
> I was not able to reproduce the bug, but it seems issues here are the
> three possible actions that assumed they would never trigger on a
> listener.
> 
> 1) tcp_write_timer_handler
> 2) tcp_delack_timer_handler
> 3) MTU reduction
> 
> Only IPv6 MTU reduction was properly testing TCP_CLOSE and TCP_LISTEN
>  states from tcp_v6_mtu_reduced()
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable.
