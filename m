From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH iproute2 2/2] tc/act_tunnel: Introduce ip tunnel action
Date: Tue, 22 Nov 2016 09:50:34 +0200
Message-ID: <20161122075034.GB12067@office.localdomain>
References: <20161121102056.13468-1-amir@vadai.me>
 <20161121102056.13468-3-amir@vadai.me>
 <9B0331B6EBBD0E4684FBFAEDA55776F93D345ED8@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36425 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752869AbcKVHuh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 02:50:37 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so1726939wma.3
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 23:50:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F93D345ED8@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2016 at 11:50:03PM +0000, Rosen, Rami wrote:
> Hi, Amir,
> 
> Following are three minor comments:
> 
> Seems that TCA_TUNNEL_KEY_PAD used anywhere:
I assume you ment that it is _NOT_ used anywhere:
This attribute type is used in the kernel side only - for padding 64bit
attributes. The userspace enum should match the kernel include/uapi one.

>  
> +	TCA_TUNNEL_KEY_PAD,
> +	__TCA_TUNNEL_KEY_MAX,
> +};
> 
> 
> Should be "and destination IP 11.11.0.2" instead of  "and destination IP 11.11.0.1":
ack

> 
> +Tunnel ID (for example VNI in VXLAN tunnel) .TP .B src_ip Outer header 
> +source IP address (IPv4 or IPv6) .TP .B dst_ip Outer header destination 
> +IP address (IPv4 or IPv6) .RE .SH EXAMPLES The following example 
> +encapsulates incoming ICMP packets on eth0 into a vxlan tunnel by 
> +setting metadata to VNI 11, source IP 11.11.0.1 and destination IP
> +11.11.0.1 by forwarding the skb with the metadata to device vxlan0, 
> +which will prepare the VXLAN headers:
> +
> +.RS
> +.EX
> +#tc qdisc add dev eth0 handle ffff: ingress #tc filter add dev eth0 
> +protocol ip parent ffff: \\
> +  flower \\
> +    ip_proto icmp \\
> +  action tunnel_key set \\
> +    src_ip 11.11.0.1 \\
> +    dst_ip 11.11.0.2 \\
> +    id 11 \\
> 
> 
> Typo: should be "ip tunnel" instead of "ip tunel":
ack

> 
> + * m_tunnel_key.c	ip tunel manipulation module
> + *
> + *              This program is free software; you can redistribute it and/or
> 
> Keep on the good work!
Thanks for reviewing,
Amir

> 
> Regards,
> Rami Rosen
> Intel Corporation
