From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Figuring out how vti works
Date: Wed, 17 Sep 2014 07:28:11 +0200
Message-ID: <20140917052811.GT6390@secunet.com>
References: <20140915142043.GA22070@master>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Joe M <joe9mail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49638 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbaIQF2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2014 01:28:22 -0400
Content-Disposition: inline
In-Reply-To: <20140915142043.GA22070@master>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 09:20:43AM -0500, Joe M wrote:
> Hello Steffen Klassert,
> 
> Very sorry for this bother.
> 
> I could not figure out how vti works with ipsec and your patch was the
> latest to ip_vti.c. If you cannot help, please excuse me.
> 
> I cannot get the vpn traffic to get on the vti tunnel. tcpdump on vti
> does not show anything. I think the tunnel lookup code, for some
> reason, is not able to use the "vtil" tunnel.

Do you know where the packets are getting dropped?
netstat -i or /proc/net/xfrm_stat could give a hint.

> 
> The pings worked fine if I remove the ip_vti and ip_tunnel modules,
> the "mark=1" from /etc/ipsec.conf and the iptables mangle rules to
> set-mark.

You don't need to set the mark with iptables.
You just have to ensure that the policy and state marks
match the tunnel keys. I.e. direction in and forward must
match the ikey, direction out must match the okey.

> 
> sudo ip tunnel list
> vtil: ip/ip  remote 192.168.1.232  local 192.168.0.11  ttl inherit ikey 0  okey 1

Your ikey does not match the policy and the state mark.

> 
> sudo ip xfrm policy
> src 192.168.1.0/24 dst 192.168.0.0/24
>         dir fwd priority 2883
>         mark 1/0xffffffff
>         tmpl src <bnglr public ip> dst 192.168.0.11
>                 proto esp reqid 2 mode tunnel
> src 192.168.1.0/24 dst 192.168.0.0/24
>         dir in priority 2883
>         mark 1/0xffffffff

If you set mark 1 here, the tunnel should set ikey 1.

> 
> I tried setting the mangle rules to set-mark but that did not help. I
> could not find any more documentation.
> 

Please try without setting a mark with netfilter.
