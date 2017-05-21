From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix tcp_probe_timer() for TCP_USER_TIMEOUT
Date: Sun, 21 May 2017 11:00:53 -0700
Message-ID: <1495389653.6465.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1495388340.6465.50.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170521.135111.1511992009561369461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36518 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEUSAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 14:00:55 -0400
Received: by mail-pf0-f195.google.com with SMTP id n23so14929415pfb.3
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 11:00:55 -0700 (PDT)
In-Reply-To: <20170521.135111.1511992009561369461.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-05-21 at 13:51 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 21 May 2017 10:39:00 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > TCP_USER_TIMEOUT is still converted to jiffies value in
> > icsk_user_timeout
> > 
> > So we need to make a conversion for the cases HZ != 1000 
> > 
> > Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied, thank Eric.
> 
> I kinda expected a few pieces of fallout from the 1ms changes :)

Absolutely ;)

One last piece is in TCP_SYNCNT support.

I saw that retransmits_timed_out() could have a rounding error :

tcp_time_stamp(tcp_sk(sk)) - start_ts) ends up to 999 ms,
while the timeout is/was 1000 ms (And timer _was_ progammed with 1000
jiffies for HZ=1000 kernel)

So if user setup TCP_SYNCNT = 1 socket option, we sometime sends one
extra SYN packet.

I will send a fix later.
