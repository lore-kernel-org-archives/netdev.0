From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipip, sit: copy parms.name after register_netdevice
Date: Mon, 12 Dec 2011 18:51:13 -0500 (EST)
Message-ID: <20111212.185113.1211685406728953774.davem@davemloft.net>
References: <CAM7b5hyXkRTUwnE-NwXEff-34WjRfMSBDf2itMVhdJGi4XoA=g@mail.gmail.com>
	<20111207.235602.1465915988125994516.davem@davemloft.net>
	<20111208104619.GA20150@ted-OptiPlex-380>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, jwboyer@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: artisdom@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391Ab1LLXvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 18:51:18 -0500
In-Reply-To: <20111208104619.GA20150@ted-OptiPlex-380>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ted Feng <artisdom@gmail.com>
Date: Thu, 8 Dec 2011 18:46:21 +0800

> From: Ted Feng <artisdom@gmail.com>
> 
> Same fix as 731abb9cb2 for ipip and sit tunnel.
> Commit 1c5cae815d removed an explicit call to dev_alloc_name in
> ipip_tunnel_locate and ipip6_tunnel_locate, because register_netdevice
> will now create a valid name, however the tunnel keeps a copy of the
> name in the private parms structure. Fix this by copying the name back
> after register_netdevice has successfully returned.
> 
> This shows up if you do a simple tunnel add, followed by a tunnel show:
> 
> $ sudo ip tunnel add mode ipip remote 10.2.20.211
> $ ip tunnel
> tunl0: ip/ip  remote any  local any  ttl inherit  nopmtudisc
> tunl%d: ip/ip  remote 10.2.20.211  local any  ttl inherit
> $ sudo ip tunnel add mode sit remote 10.2.20.212
> $ ip tunnel
> sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc 6rd-prefix 2002::/16
> sit%d: ioctl 89f8 failed: No such device
> sit%d: ipv6/ip  remote 10.2.20.212  local any  ttl inherit
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Ted Feng <artisdom@gmail.com>

Applied.
