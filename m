From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 03/14] gtp: Call common functions to get tunnel
 routes and add dst_cache
Date: Tue, 19 Sep 2017 09:05:18 -0700
Message-ID: <CALx6S35r3-7vo39KsEtziYHwiBVcWFdFgqZcOHNUKa3rDyuEmA@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-4-tom@quantonium.net>
 <20170918.211751.1871429944584121281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>,
        Rohit Seth <rohit@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33181 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdISQFT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 12:05:19 -0400
Received: by mail-qt0-f196.google.com with SMTP id b1so59454qtc.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 09:05:19 -0700 (PDT)
In-Reply-To: <20170918.211751.1871429944584121281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 9:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@quantonium.net>
> Date: Mon, 18 Sep 2017 17:38:53 -0700
>
>> Call ip_tunnel_get_route and dst_cache to pdp context which should
>> improve performance by obviating the need to perform a route lookup
>> on every packet.
>>
>> Signed-off-by: Tom Herbert <tom@quantonium.net>
>
> Not caused by your changes, but something to think about:
>
>> -static struct rtable *ip4_route_output_gtp(struct flowi4 *fl4,
>> -                                        const struct sock *sk,
>> -                                        __be32 daddr)
>> -{
>> -     memset(fl4, 0, sizeof(*fl4));
>> -     fl4->flowi4_oif         = sk->sk_bound_dev_if;
>> -     fl4->daddr              = daddr;
>> -     fl4->saddr              = inet_sk(sk)->inet_saddr;
>> -     fl4->flowi4_tos         = RT_CONN_FLAGS(sk);
>> -     fl4->flowi4_proto       = sk->sk_protocol;
>> -
>> -     return ip_route_output_key(sock_net(sk), fl4);
>> -}
>
> This and the new dst caching code ignores any source address selection
> done by ip_route_output_key() or the new tunnel route lookup helpers.
>
> Either source address selection should be respected, or if saddr will
> never be modified by a route lookup for some specific reason here,
> that should be documented.

Yes, I noticed that. In this case the source address is intended to be
taken bound on the socket which would imply we aren't interested in
source address selection.

Tom
