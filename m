From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ip_finish_output_gso: Allow fragmenting segments
 of tunneled skbs if their DF is unset
Date: Mon, 22 Aug 2016 18:08:04 -0700 (PDT)
Message-ID: <20160822.180804.83382759280246017.davem@davemloft.net>
References: <1471767752-7849-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, wenxu@ucloud.cn,
        hannes@stressinduktion.org
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47207 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933073AbcHWBIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 21:08:10 -0400
In-Reply-To: <1471767752-7849-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Sun, 21 Aug 2016 11:22:32 +0300

> In b8247f095e,
> 
>    "net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for local udp tunneled skbs"
> 
> gso skbs arriving from an ingress interface that go through UDP
> tunneling, are allowed to be fragmented if the resulting encapulated
> segments exceed the dst mtu of the egress interface.
> 
> This aligned the behavior of gso skbs to non-gso skbs going through udp
> encapsulation path.
> 
> However the non-gso vs gso anomaly is present also in the following
> cases of a GRE tunnel:
>  - ip_gre in collect_md mode, where TUNNEL_DONT_FRAGMENT is not set
>    (e.g. OvS vport-gre with df_default=false)
>  - ip_gre in nopmtudisc mode, where IFLA_GRE_IGNORE_DF is set
> 
> In both of the above cases, the non-gso skbs get fragmented, whereas the
> gso skbs (having skb_gso_network_seglen that exceeds dst mtu) get dropped,
> as they don't go through the segment+fragment code path.
> 
> Fix: Setting IPSKB_FRAG_SEGS if the tunnel specified IP_DF bit is NOT set.
> 
> Tunnels that do set IP_DF, will not go to fragmentation of segments.
> This preserves behavior of ip_gre in (the default) pmtudisc mode.
> 
> Fixes: b8247f095e ("net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, allow segmentation for local udp tunneled skbs")
> Reported-by: wenxu <wenxu@ucloud.cn>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied, thanks.
