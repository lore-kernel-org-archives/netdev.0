From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 7 Jan 2014 13:40:57 -0800
Message-ID: <CA+mtBx_fo3UHZ3n4vFDGvc832bV4ZRPZ8TjAWzruMDybDrRWsQ@mail.gmail.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
	<20140107.161958.2246599406178837029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:45870 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620AbaAGVk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:40:58 -0500
Received: by mail-ig0-f180.google.com with SMTP id m12so2839537iga.1
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 13:40:57 -0800 (PST)
In-Reply-To: <20140107.161958.2246599406178837029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 1:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Tue,  7 Jan 2014 17:29:52 +0200
>
>> +#define MAX_UDP_PORT (1 << 16)
>> +extern const struct net_offload __rcu *udp_offloads[MAX_UDP_PORT];
>
> Bloating the kernel up by half a megabyte just for this feature is
> beyond unacceptable.

For now we should have at most handful of encapsulation ports (maybe
5?) so a linear lookup in a simple array should suffice. If we get
into more complex scenarios, like using connected UDP sockets to get
encapsulation through NAT boxes, then we would need something more
complex (maybe socket lookup).

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
