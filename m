From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/2] net: vrf: Fixup PKTINFO to return enslaved
 device index
Date: Fri, 6 May 2016 19:04:47 -0600
Message-ID: <572D3F2F.4030307@cumulusnetworks.com>
References: <1462477063-21699-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36179 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758804AbcEGBEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 21:04:51 -0400
Received: by mail-ob0-f178.google.com with SMTP id aq1so54349845obc.3
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 18:04:51 -0700 (PDT)
Received: from [192.168.0.4] (65-128-63-165.hlrn.qwest.net. [65.128.63.165])
        by smtp.googlemail.com with ESMTPSA id w140sm5652839oif.24.2016.05.06.18.04.48
        for <netdev@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Fri, 06 May 2016 18:04:49 -0700 (PDT)
In-Reply-To: <1462477063-21699-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/5/16 1:37 PM, David Ahern wrote:
> Applications such as OSPF and BFD need the original ingress device not
> the VRF device; the latter can be derived from the former. To that end
> move the packet intercept from an rx handler that is invoked by
> __netif_receive_skb_core to the ipv4 and ipv6 receive processing.
>
> IPv6 already saves the skb_iif to the control buffer in ipv6_rcv. Since
> the skb->dev has not been switched the cb has the enslaved device. Make
> the same happen for IPv4 by adding the skb_iif to inet_skb_parm and set
> it in ipv4 code after clearing the skb control buffer similar to IPv6.
>  From there the pktinfo can just pull it from cb with the PKTINFO_SKB_CB
> cast.
>
> David Ahern (2):
>    net: l3mdev: Add hook in ip and ipv6
>    net: original ingress device index in PKTINFO
>
>   drivers/net/vrf.c         | 186 ++++++++++++++++++++++------------------------
>   include/linux/ipv6.h      |   3 +-
>   include/linux/netdevice.h |   2 +
>   include/net/ip.h          |   1 +
>   include/net/l3mdev.h      |  43 +++++++++++
>   include/net/tcp.h         |   3 +-
>   net/core/dev.c            |   3 +-
>   net/ipv4/ip_input.c       |   8 ++
>   net/ipv4/ip_sockglue.c    |   7 +-
>   net/ipv6/ip6_input.c      |   7 ++
>   10 files changed, 161 insertions(+), 102 deletions(-)
>

Dave: please ignore. I have an update that better encapsulates the 
inet6_iif and tcp iif change. Will send v2 shortly.
