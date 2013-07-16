From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] ipv4: set transport header earlier
Date: Tue, 16 Jul 2013 17:24:48 +0400
Message-ID: <51E549A0.206@cogentembedded.com>
References: <1373943799.10804.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	netfilter-devel@vger.kernel.org, Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:38371 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343Ab3GPNYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 09:24:49 -0400
Received: by mail-la0-f42.google.com with SMTP id eb20so517608lab.29
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 06:24:47 -0700 (PDT)
In-Reply-To: <1373943799.10804.96.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 16-07-2013 7:03, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>

> commit 45f00f99d6e ("ipv4: tcp: clean up tcp_v4_early_demux()") added a
> performance regression for non GRO traffic, basically disabling
> IP early demux.

> IPv6 stack resets transport header in ip6_rcv() before calling
> IP early demux in ip6_rcv_finish(), while IPv4 does this only in
> ip_local_deliver_finish(), _after_ IP early demux.

> GRO traffic happened to enable IP early demux because transport header
> is also set in inet_gro_receive()

> Instead of reverting the faulty commit, we can make IPv4/IPv6 behave the
> same : transport_header should be set in ip_rcv() instead of
> ip_local_deliver_finish()

> ip_local_deliver_finish() can also use skb_network_header_len() which is
> faster than ip_hdrlen()

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
>   net/ipv4/ip_input.c |    7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)

> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index 3da817b..15e3e68 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
[...]
> @@ -437,6 +434,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
>   		goto drop;
>   	}
>
> +	skb->transport_header = skb->network_header + iph->ihl*4;

    Spaces around * wouldn't hurt, to be consistent with the rest of the 
statement and the Linux style in common.

WBR, Sergei
