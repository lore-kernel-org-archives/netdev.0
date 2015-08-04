From: Pravin Shelar <pshelar@nicira.com>
Subject: Re:
Date: Mon, 3 Aug 2015 17:17:27 -0700
Message-ID: <CALnjE+rVe4rcY2533r_puQic8Ng-7sf104XEddmcbpHup8YRBg@mail.gmail.com>
References: <1438642689-9575-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34228 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589AbbHDAR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 20:17:28 -0400
Received: by ioea135 with SMTP id a135so1592956ioe.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 17:17:27 -0700 (PDT)
In-Reply-To: <1438642689-9575-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Somehow subject line got dropped, I am resending these patches.

On Mon, Aug 3, 2015 at 3:58 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patches make use of new flow based tunneling
> API from kernel. This allows us to directly use netdev
> based GRE tunnel implementation. While doing so I have
> removed GRE demux API which were targeted for OVS. Most
> of GRE protocol code is now consolidated in ip_gre module.
>
> Pravin B Shelar (2):
>   openvswitch: Use regular GRE net_device instead of vport
>   gre: Remove support for sharing GRE protocol hook.
>
>  include/net/gre.h              |  97 ++--------
>  include/net/ip_tunnels.h       |   6 +-
>  net/ipv4/gre_demux.c           | 235 +-----------------------
>  net/ipv4/ip_gre.c              | 400 ++++++++++++++++++++++++++++++++++++++---
>  net/ipv4/ip_tunnel.c           |   6 +-
>  net/ipv4/ipip.c                |   2 +-
>  net/ipv6/sit.c                 |   2 +-
>  net/openvswitch/Kconfig        |   1 -
>  net/openvswitch/vport-gre.c    | 230 +++---------------------
>  net/openvswitch/vport-netdev.c |   5 +-
>  net/openvswitch/vport-netdev.h |   2 +
>  net/openvswitch/vport.h        |   2 +-
>  12 files changed, 431 insertions(+), 557 deletions(-)
>
> --
> 1.8.3.1
>
