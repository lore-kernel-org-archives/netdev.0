From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH next-next v4 0/2] MPLS: Add limited GSO support
Date: Fri, 24 May 2013 15:12:33 +0800
Message-ID: <CAEH94Litbbgya=YPyDUDkQZnV2Rod=EwwUZDfgq2f4J77a8wew@mail.gmail.com>
References: <1369378295-17779-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:45658 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168Ab3EXHMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:12:34 -0400
Received: by mail-qc0-f177.google.com with SMTP id e1so2231386qcy.36
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 00:12:33 -0700 (PDT)
In-Reply-To: <1369378295-17779-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI,

   By the way, will this label is allocated statically or via
auto-negotiation between two switches such as LDP?

On Fri, May 24, 2013 at 2:51 PM, Simon Horman <horms@verge.net.au> wrote:
> In the case where a non-MPLS packet is received and an MPLS stack is
> added it may well be the case that the original skb is GSO but the
> NIC used for transmit does not support GSO of MPLS packets.
>
> The aim of this short series is to provide GSO in software for MPLS packets
> whose skbs are GSO.
>
> Change since v4:
>
> Update first patch of the series to use 16 bits for all *_headers
> rather than just inner_*_headers
>
> Simon Horman (2):
>   net: Use 16bits for *_headers fields of struct skbuff
>   MPLS: Add limited GSO support
>
>  include/linux/netdev_features.h |   4 +-
>  include/linux/netdevice.h       |   2 +
>  include/linux/skbuff.h          | 123 ++++------------------------------------
>  net/Kconfig                     |   1 +
>  net/Makefile                    |   1 +
>  net/core/dev.c                  |   4 ++
>  net/core/ethtool.c              |   1 +
>  net/ipv4/af_inet.c              |   1 +
>  net/ipv4/tcp.c                  |   1 +
>  net/ipv4/udp.c                  |   2 +-
>  net/ipv6/ip6_offload.c          |   1 +
>  net/ipv6/udp_offload.c          |   3 +-
>  net/mpls/Kconfig                |   9 +++
>  net/mpls/Makefile               |   4 ++
>  net/mpls/mpls_gso.c             | 108 +++++++++++++++++++++++++++++++++++
>  15 files changed, 149 insertions(+), 116 deletions(-)
>  create mode 100644 net/mpls/Kconfig
>  create mode 100644 net/mpls/Makefile
>  create mode 100644 net/mpls/mpls_gso.c
>
> --
> 1.8.2.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Regards,

Zhi Yong Wu
