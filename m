From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: properly scale window in tcp_v[46]_reqsk_send_ack()
Date: Mon, 22 Aug 2016 14:59:10 -0400
Message-ID: <CADVnQy=kdKrKWXKdWNnhQq3tiKQ0njnh9MaF3NXsn+OA7Q6yxQ@mail.gmail.com>
References: <1471890670.14381.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:36469 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752995AbcHVS7m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 14:59:42 -0400
Received: by mail-oi0-f46.google.com with SMTP id f189so164724903oig.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 11:59:41 -0700 (PDT)
In-Reply-To: <1471890670.14381.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 2:31 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When sending an ack in SYN_RECV state, we must scale the offered
> window if wscale option was negotiated and accepted.
>
> Tested:
>  Following packetdrill test demonstrates the issue :
>
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>
> +0 bind(3, ..., ...) = 0
> +0 listen(3, 1) = 0
>
> // Establish a connection.
> +0 < S 0:0(0) win 20000 <mss 1000,sackOK,wscale 7, nop, TS val 100 ecr 0>
> +0 > S. 0:0(0) ack 1 win 28960 <mss 1460,sackOK, TS val 100 ecr 100, nop, wscale 7>
>
> +0 < . 1:11(10) ack 1 win 156 <nop,nop,TS val 99 ecr 100>
> // check that window is properly scaled !
> +0 > . 1:1(0) ack 1 win 226 <nop,nop,TS val 200 ecr 100>
>
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Nice.

neal
