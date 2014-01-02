From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] IPv6: add option to use Subnet-Router anycast addresses
 as source addresses
Date: Thu, 02 Jan 2014 19:16:33 +0400
Message-ID: <52C582D1.8040107@cogentembedded.com>
References: <1388656263-6795-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:45634 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaABPQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 10:16:33 -0500
Received: by mail-la0-f54.google.com with SMTP id b8so7482077lan.13
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 07:16:32 -0800 (PST)
In-Reply-To: <1388656263-6795-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02-01-2014 13:51, Francois-Xavier Le Bail wrote:

> This change allows to follow a recommandation of RFC4942.

> - Add "enable_anycast_src" sysctl to control the use of Subnet-Router anycast
>    addresses as source addresses. This sysctl is false by default to preserve
>    existing behavior.
> - Use it in ip6_datagram_send_ctl() and icmpv6_echo_reply().

> Reference:
> RFC4942 - IPv6 Transition/Coexistence Security Considerations
>     (http://tools.ietf.org/html/rfc4942#section-2.1.6)

> 2.1.6. Anycast Traffic Identification and Security
>
>     [...]
>     To avoid exposing knowledge about the internal structure of the
>     network, it is recommended that anycast servers now take advantage of
>     the ability to return responses with the anycast address as the
>     source address if possible.

> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> ---
[...]
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index 6983058..c7d6392 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -668,6 +668,9 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
>   			if (addr_type != IPV6_ADDR_ANY) {
>   				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
>   				if (!(inet_sk(sk)->freebind || inet_sk(sk)->transparent) &&
> +					!(net->ipv6.enable_anycast_src &&
> +					  ipv6_chk_acast_addr(net, NULL,
> +						&src_info->ipi6_addr)) &&

    The continuation line should start right under 'net' on the previous line.

WBR, Sergei
