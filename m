From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/9] netfilter: move nf_send_resetX() code to
 nf_reject_ipvX modules
Date: Tue, 07 Oct 2014 07:45:47 -0700
Message-ID: <1412693147.11091.125.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
	 <1412356824-6362-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:65393 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146AbaJGOpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 10:45:49 -0400
In-Reply-To: <1412356824-6362-3-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-03 at 19:20 +0200, Pablo Neira Ayuso wrote:
> Move nf_send_reset() and nf_send_reset6() to nf_reject_ipv4 and
> nf_reject_ipv6 respectively. This code is shared by x_tables and
> nf_tables.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  include/net/netfilter/ipv4/nf_reject.h |  118 +----------------------
>  net/ipv4/netfilter/Kconfig             |    6 ++
>  net/ipv4/netfilter/Makefile            |    3 +
>  net/ipv4/netfilter/nf_reject_ipv4.c    |  127 +++++++++++++++++++++++++
>  net/ipv6/netfilter/Kconfig             |    6 ++
>  net/ipv6/netfilter/Makefile            |    3 +
>  net/ipv6/netfilter/nf_reject_ipv6.c    |  163 ++++++++++++++++++++++++++++++++
>  7 files changed, 309 insertions(+), 117 deletions(-)
>  create mode 100644 net/ipv4/netfilter/nf_reject_ipv4.c
>  create mode 100644 net/ipv6/netfilter/nf_reject_ipv6.c

I am confused

We now have two copies of nf_send_reset6()

$ git grep -n nf_send_reset6
include/net/netfilter/ipv6/nf_reject.h:21:static void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
net/bridge/netfilter/nft_reject_bridge.c:49:                    nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
net/ipv6/netfilter/ip6t_REJECT.c:66:            nf_send_reset6(net, skb, par->hooknum);
net/ipv6/netfilter/nf_reject_ipv6.c:14:void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
net/ipv6/netfilter/nf_reject_ipv6.c:163:EXPORT_SYMBOL_GPL(nf_send_reset6);
net/ipv6/netfilter/nft_reject_ipv6.c:35:                nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
net/netfilter/nft_reject_inet.c:49:                     nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
