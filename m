From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix wraparound issue in tcp_lp
Date: Mon, 01 May 2017 18:58:32 -0700
Message-ID: <1493690312.31837.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493677788.31837.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170501165643.698aa0b5@xeon-e3>
         <1493687087.31837.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34515 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdEBB6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 21:58:37 -0400
Received: by mail-pg0-f68.google.com with SMTP id t7so18566672pgt.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 18:58:37 -0700 (PDT)
In-Reply-To: <1493687087.31837.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-01 at 18:04 -0700, Eric Dumazet wrote:

> 
> Simply to not perform (tcp_time_stamp - tp->rx_opt.rcv_tsecr) twice.
> 
> jiffies being volatile, this can not be optimized by the compiler.
> 
> I have a patch series (for linux-4.13) that will switch TCP stack to 1ms
> TS options, regardless of CONFIG_HZ value, and when cooking it I found
> this bug.

I forgot to say that after this upcoming patch series, tcp_time_stamp
will become a more expensive function, no longer a plain (u32)jiffies.
