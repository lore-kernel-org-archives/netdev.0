From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc 2/4] net-errqueue: add IP(V6)_PKTINFO support
Date: Tue, 25 Nov 2014 13:04:51 -0500
Message-ID: <CA+FuTSf6qUazay4NF-6g=Onw2hK=YGw9vcXfFA=kWM-OiT4bjw@mail.gmail.com>
References: <1416938286-14147-1-git-send-email-willemb@google.com> <1416938286-14147-3-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Richard Cochran <richardcochran@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:47685 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbaKYSFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:05:22 -0500
Received: by mail-qa0-f54.google.com with SMTP id i13so784360qae.27
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 10:05:21 -0800 (PST)
In-Reply-To: <1416938286-14147-3-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> +static void ipv6_recv_error_pktinfo(struct msghdr *msg, struct sock *sk,
> +                                   struct sk_buff *skb)
> +{
> +       struct ipv6_pinfo *np = inet6_sk(sk);
> +
> +       if (np->rxopt.bits.rxinfo && skb->dev) {
> +               struct in6_pktinfo info;
> +
> +               memset(&info, 0, sizeof(info));
> +               if (skb->protocol == htons(ETH_P_IPV6))
> +                       info.ipi6_addr = ipv6_hdr(skb)->daddr;
> +               else
> +                       ipv6_addr_set_v4mapped(ip_hdr(skb)->daddr,
> +                                              &info.ipi6_addr);
> +
> +               info.ipi6_ifindex = skb->dev->ifindex;
> +               net_info_ratelimited("yes: ifindex=%d\n", info.ipi6_ifindex);

forgot to remove this debug message.. removing it from my local copy right away.

> +               put_cmsg(msg, SOL_IPV6, IPV6_PKTINFO, sizeof(info), &info);
> +       }
> +}
> +
