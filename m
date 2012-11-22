From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: VXLAN multicast receive not working
Date: Thu, 22 Nov 2012 01:09:13 +0100
Message-ID: <20121122000913.GB3447@fliwatuet.svr02.mucip.net>
References: <20121122000525.GA3447@fliwatuet.svr02.mucip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.svr02.mucip.net ([83.170.6.69]:57037 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166Ab2KVSum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 13:50:42 -0500
Received: from localhost (mail.svr02.mucip.net [127.0.0.1])
	by mailout.mucip.net (Postfix) with ESMTP id B6408A1F
	for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 01:09:17 +0100 (CET)
Received: from mailout.mucip.net ([127.0.0.1])
	by localhost (mail.svr02.mucip.net [127.0.0.1]) (amavisd-new, port 10125)
	with ESMTP id B0CM3FUZzu75 for <netdev@vger.kernel.org>;
	Thu, 22 Nov 2012 01:09:17 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20121122000525.GA3447@fliwatuet.svr02.mucip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 22, 2012 at 01:05:25AM +0100, Bernhard Schmidt wrote:

> The same VXLAN domain is defined on the Nexus 1000V and a VM is attached
> to it. When I send some broadcast traffic down vxlan0 (i.e. ping
> 10.1.1.2 which generates an ARP request) the VM sees the packet just
> fine.
> 
> When I do it the other way around (the VM sends a broadcast ARP for
> 10.1.1.3) I see a packet coming into eth1 on the multicast group, but
> vxlan0 stays silent. 

I think I found a possible reason, my vxlan interface is on top of eth1

7: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue
state UNKNOWN mode DEFAULT 
    link/ether 96:06:c6:cf:a0:2e brd ff:ff:ff:ff:ff:ff
    vxlan id 12340 group 239.0.0.42 dev eth1 port 32768 61000 ageing 300 

but the multicast group is joined only on eth0

root@lxbscDA-VXLAN:~/iproute2# ip maddr
1:	lo
	inet  224.0.0.1
	inet6 ff02::1
2:	eth0
	link  33:33:00:00:00:01
	link  01:00:5e:00:00:01
	link  33:33:ff:8e:0d:c7
	link  01:00:5e:00:00:2a
	inet  239.0.0.42
	inet  224.0.0.1
	inet6 ff02::1:ff8e:dc7 users 2
	inet6 ff02::1
4:	eth1
	link  33:33:00:00:00:01
	link  01:00:5e:00:00:01
	link  33:33:ff:8e:0d:c8
	inet  224.0.0.1
	inet6 ff02::1:ff8e:dc8
	inet6 ff02::1
7:	vxlan0
	link  33:33:00:00:00:01
	link  01:00:5e:00:00:01
	link  33:33:ff:cf:a0:2e
	inet  224.0.0.1
	inet6 ff02::1:ffcf:a02e
	inet6 ff02::1

At first glance I did not spot the issue with my two weeks of C, so
someone else has to hunt this down.

Regards,
Bernhard
