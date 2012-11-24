From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: VXLAN multicast receive not working
Date: Sat, 24 Nov 2012 00:08:28 +0000 (UTC)
Message-ID: <k8p35s$pd6$1@ger.gmane.org>
References: <20121122000525.GA3447@fliwatuet.svr02.mucip.net>
 <20121122000913.GB3447@fliwatuet.svr02.mucip.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:55242 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932322Ab2KXAIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 19:08:49 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Tc3Im-0004IV-3b
	for netdev@vger.kernel.org; Sat, 24 Nov 2012 01:08:56 +0100
Received: from nat64.discard.me.uk ([90.155.46.46])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 01:08:56 +0100
Received: from berni by nat64.discard.me.uk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 24 Nov 2012 01:08:56 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernhard Schmidt <berni@birkenwald.de> wrote:


> On Thu, Nov 22, 2012 at 01:05:25AM +0100, Bernhard Schmidt wrote:
>
>> The same VXLAN domain is defined on the Nexus 1000V and a VM is attached
>> to it. When I send some broadcast traffic down vxlan0 (i.e. ping
>> 10.1.1.2 which generates an ARP request) the VM sees the packet just
>> fine.
>> 
>> When I do it the other way around (the VM sends a broadcast ARP for
>> 10.1.1.3) I see a packet coming into eth1 on the multicast group, but
>> vxlan0 stays silent. 
>
> I think I found a possible reason, my vxlan interface is on top of eth1
>
> 7: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue
> state UNKNOWN mode DEFAULT 
>     link/ether 96:06:c6:cf:a0:2e brd ff:ff:ff:ff:ff:ff
>     vxlan id 12340 group 239.0.0.42 dev eth1 port 32768 61000 ageing 300 
>
> but the multicast group is joined only on eth0

Confirmed working as soon as eth0 can receive the group multicast
address (connected to the same VLAN), even if the vxlan0 interface is
still configured to eth1.

Bernhard
