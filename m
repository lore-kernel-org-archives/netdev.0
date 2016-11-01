From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: enhance tcp collapsing
Date: Tue, 1 Nov 2016 12:35:08 -0400
Message-ID: <CADVnQymN18JsVSX-0wT3qSuP9+pB8_8js26SQ_XgRF1jM6raDw@mail.gmail.com>
References: <VI1PR0502MB29577BA8C670D1379CC4F1B7D4A10@VI1PR0502MB2957.eurprd05.prod.outlook.com>
 <1478007189.7065.331.camel@edumazet-glaptop3.roam.corp.google.com> <1478014346.7065.342.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:35086 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750918AbcKAQfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:35:40 -0400
Received: by mail-oi0-f45.google.com with SMTP id i127so303132820oia.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 09:35:40 -0700 (PDT)
In-Reply-To: <1478014346.7065.342.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016 at 11:32 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> As Ilya Lesokhin suggested, we can collapse two skbs at retransmit
> time even if the skb at the right has fragments.
>
> We simply have to use more generic skb_copy_bits() instead of
> skb_copy_from_linear_data() in tcp_collapse_retrans()
>
> Tested:
>
> Used following packetdrill test
>
> // Establish a connection.
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
>    +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>    +0 bind(3, ..., ...) = 0
>    +0 listen(3, 1) = 0
>
>    +0 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 8>
>    +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 8>
> +.100 < . 1:1(0) ack 1 win 257
>    +0 accept(3, ..., ...) = 4
>
>    +0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0
>    +0 write(4, ..., 200) = 200
>    +0 > P. 1:201(200) ack 1
> +.001 write(4, ..., 200) = 200
>    +0 > P. 201:401(200) ack 1
> +.001 write(4, ..., 200) = 200
>    +0 > P. 401:601(200) ack 1
> +.001 write(4, ..., 200) = 200
>    +0 > P. 601:801(200) ack 1
> +.001 write(4, ..., 200) = 200
>    +0 > P. 801:1001(200) ack 1
> +.001 write(4, ..., 100) = 100
>    +0 > P. 1001:1101(100) ack 1
> +.001 write(4, ..., 100) = 100
>    +0 > P. 1101:1201(100) ack 1
> +.001 write(4, ..., 100) = 100
>    +0 > P. 1201:1301(100) ack 1
> +.001 write(4, ..., 100) = 100
>    +0 > P. 1301:1401(100) ack 1
>
> +.100 < . 1:1(0) ack 1 win 257 <nop,nop,sack 1001:1401>
> // Check that TCP collapse works :
>    +0 > P. 1:1001(1000) ack 1
>
>
> Reported-by: Ilya Lesokhin <ilyal@mellanox.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
