From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Figuring out how vti works
Date: Thu, 18 Sep 2014 11:20:50 +0200
Message-ID: <20140918092050.GV6390@secunet.com>
References: <20140915142043.GA22070@master>
 <20140917052811.GT6390@secunet.com>
 <CAHjjW16qdT6RWuJaUd1c6k39RgcPtfsyF=V-dVowW_2UwhF_dw@mail.gmail.com>
 <20140918050807.GA10599@master>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Joe M <joe9mail@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:42357 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754949AbaIRJVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 05:21:00 -0400
Content-Disposition: inline
In-Reply-To: <20140918050807.GA10599@master>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 12:08:07AM -0500, Joe M wrote:
> Hello Steffen,
> 
> Checking further with printk's, I can see
> 
> vti_tunnel_init being called for both ip_vti0 and vtil tunnels. But,
> when vti_tunnel_xmit is called, it is called with ip_vti0 tunnel and
> not the vtil tunnel. I am not sure if I am setting the route wrong.

If you can't get traffic into the tunnel, then the routing is
likely to be wrong. 

> 
> master# echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward
> 1
> master# modprobe ip_vti
> master# ipsec start
> Starting strongSwan 5.2.0 IPsec [starter]...
> master# ip tunnel add vtil mode vti local 192.168.0.11 remote 192.168.1.232 ikey 1 okey 1
> master# ip link set vtil up
> master# sleep 10
> master# ip route add 192.168.1.0/24 dev vtil
> master# ip route list
> default via 192.168.0.1 dev enp4s0  metric 202
> 127.0.0.0/8 dev lo  scope host
> 192.168.0.0/24 dev enp4s0  proto kernel  scope link  src 192.168.0.11  metric 202
> 192.168.1.0/24 dev vtil  scope link
> 
> ip link list
> .
> .
> .
> 13: ip_vti0@NONE: <NOARP,UP,LOWER_UP> mtu 1428 qdisc noqueue state UNKNOWN mode DEFAULT group default
>     link/ipip 0.0.0.0 brd 0.0.0.0

Why is the ip_vti0 interface up? This should be down after inserting
the ip_vti module and I don't see that you've set it up with the
commands above.

Set the ip_vti0 interface down and try to find out where your
packets are getting dropped. As I said already, netstat -i and
/proc/net/xfrm_stat can help.
