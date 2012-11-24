From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: VXLAN multicast receive not working
Date: Sat, 24 Nov 2012 01:24:42 +0000 (UTC)
Message-ID: <k8p7kq$p65$1@ger.gmane.org>
References: <20121122000525.GA3447@fliwatuet.svr02.mucip.net>
 <20121122000913.GB3447@fliwatuet.svr02.mucip.net>
 <k8p35s$pd6$1@ger.gmane.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59527 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932512Ab2KXBY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 20:24:56 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Tc4UR-0001Vb-GO
	for netdev@vger.kernel.org; Sat, 24 Nov 2012 02:25:03 +0100
Received: from nat64.discard.me.uk ([90.155.46.46])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 02:25:03 +0100
Received: from berni by nat64.discard.me.uk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 02:25:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernhard Schmidt <berni@birkenwald.de> wrote:

>>> The same VXLAN domain is defined on the Nexus 1000V and a VM is attached
>>> to it. When I send some broadcast traffic down vxlan0 (i.e. ping
>>> 10.1.1.2 which generates an ARP request) the VM sees the packet just
>>> fine.
>>> 
>>> When I do it the other way around (the VM sends a broadcast ARP for
>>> 10.1.1.3) I see a packet coming into eth1 on the multicast group, but
>>> vxlan0 stays silent. 
>>
>> I think I found a possible reason, my vxlan interface is on top of eth1
>>
>> 7: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue
>> state UNKNOWN mode DEFAULT 
>>     link/ether 96:06:c6:cf:a0:2e brd ff:ff:ff:ff:ff:ff
>>     vxlan id 12340 group 239.0.0.42 dev eth1 port 32768 61000 ageing 300 
>>
>> but the multicast group is joined only on eth0
>
> Confirmed working as soon as eth0 can receive the group multicast
> address (connected to the same VLAN), even if the vxlan0 interface is
> still configured to eth1.

When swapping the configuration around using eth0 for the VXLAN
transport and eth1 for Management, the group is joined on eth1. It is
always joined where the default route points, so it looks like the
interface is not set at all.

# ip route add <group>/32 dev <vxlanintf>

works around the problem.

Bernhard
