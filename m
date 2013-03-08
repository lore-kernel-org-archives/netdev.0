From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/4] VXLAN: segmentation offload
Date: Thu, 7 Mar 2013 21:40:12 -0800
Message-ID: <20130307214012.52af6292@nehalam.linuxnetplumber.net>
References: <1362698490-2378-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49766 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3CHFkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 00:40:16 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so1043285pad.10
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 21:40:15 -0800 (PST)
In-Reply-To: <1362698490-2378-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Mar 2013 15:21:30 -0800
Pravin B Shelar <pshelar@nicira.com> wrote:

> Following patches add segmentation offload to VXLAN. These
> patches shows performance improvement from 3.9G to 5.8G (+50%)
> with netperf single process TCP_STREAM test on 10G network.
> 
> Pravin B Shelar (4):
>   net: Add skb_headers_offset_update helper function.
>   tunneling: Capture inner mac header during encapsulation.
>   tunneling: Add generic Tunnel segmentation.
>   VXLAN: Use UDP Tunnel segmention.
> 
>  drivers/net/vxlan.c             |   21 ++++++-
>  include/linux/netdev_features.h |    7 +-
>  include/linux/skbuff.h          |   36 ++++++++++++
>  net/core/ethtool.c              |    1 +
>  net/core/skbuff.c               |   36 +++++-------
>  net/ipv4/af_inet.c              |    6 ++-
>  net/ipv4/tcp.c                  |    1 +
>  net/ipv4/udp.c                  |  116 ++++++++++++++++++++++++++++++--------
>  net/ipv6/ip6_offload.c          |    1 +
>  net/ipv6/udp_offload.c          |   10 +++-
>  10 files changed, 181 insertions(+), 54 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks good, I wonder how well this will work with vendors plans to
offload segmentation of tunnel packets in hardware?

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
