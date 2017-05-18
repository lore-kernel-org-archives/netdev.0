From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 15/15] tcp: switch TCP TS option (RFC 7323) to
 1ms clock
Date: Thu, 18 May 2017 05:33:45 -0700
Message-ID: <1495110825.6465.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170516210014.31176-1-edumazet@google.com>
         <20170516210014.31176-16-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34629 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdERMds (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 08:33:48 -0400
Received: by mail-pg0-f66.google.com with SMTP id u187so5848680pgb.1
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 05:33:47 -0700 (PDT)
In-Reply-To: <20170516210014.31176-16-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-16 at 14:00 -0700, Eric Dumazet wrote:
> TCP Timestamps option is defined in RFC 7323
> 
> Traditionally on linux, it has been tied to the internal
> 'jiffies' variable, because it had been a cheap and good enough
> generator.

...

> @@ -3003,7 +3004,7 @@ void tcp_rearm_rto(struct sock *sk)
>  			struct sk_buff *skb = tcp_write_queue_head(sk);
>  			const u32 rto_time_stamp =
>  				tcp_skb_timestamp(skb) + rto;
> -			s32 delta = (s32)(rto_time_stamp - tcp_time_stamp);
> +			s32 delta = (s32)(rto_time_stamp - tcp_jiffies32);
>  			/* delta may not be positive if the socket is locked
>  			 * when the retrans timer fires and is rescheduled.
>  			 */

RTO is broken, I will send a fix after tests.
