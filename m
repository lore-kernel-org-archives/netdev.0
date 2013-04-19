From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2] tcp: call tcp_replace_ts_recent() from tcp_ack()
Date: Fri, 19 Apr 2013 13:31:58 -0400
Message-ID: <CADVnQynm+Je=FZ-X0fVT9zSpxdUjA+ANWmdAT0ziSNuJG=o1dg@mail.gmail.com>
References: <1366384390.16391.17.camel@edumazet-glaptop>
	<1366391988.16391.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:49911 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211Ab3DSRcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 13:32:00 -0400
Received: by mail-ea0-f176.google.com with SMTP id h14so1263660eak.21
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 10:31:59 -0700 (PDT)
In-Reply-To: <1366391988.16391.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 1:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit bd090dfc634d (tcp: tcp_replace_ts_recent() should not be called
> from tcp_validate_incoming()) introduced a TS ecr bug in slow path
> processing.
>
> 1 A > B P. 1:10001(10000) ack 1 <nop,nop,TS val 1001 ecr 200>
> 2 B < A . 1:1(0) ack 1 win 257 <sack 9001:10001,TS val 300 ecr 1001>
> 3 A > B . 1:1001(1000) ack 1 win 227 <nop,nop,TS val 1002 ecr 200>
> 4 A > B . 1001:2001(1000) ack 1 win 227 <nop,nop,TS val 1002 ecr 200>
>
> (ecr 200 should be ecr 300 in packets 3 & 4)
>
> Problem is tcp_ack() can trigger send of new packets (retransmits),
> reflecting the prior TSval, instead of the TSval contained in the
> currently processed incoming packet.
>
> Fix this by calling tcp_replace_ts_recent() from tcp_ack() after the
> checks, but before the actions.
>
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---
> v2: use FLAG_UPDATE_TS_RECENT in tcp_rcv_state_process() as well

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
