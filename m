From: Pedro Garcia <pedro.netdev@dondevamos.com>
Subject: =?UTF-8?Q?=5BBUG=3F=5D=20ip=20forwarding=20keeps=20L=32=20vlan=5F?=
 =?UTF-8?Q?tci=20priority=20=28or=20looks=20like=29?=
Date: Fri, 01 Feb 2013 00:48:30 +0100
Message-ID: <d923b2319a0f6afbbaca6b7c049e5335@dondevamos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 13.Red-213-97-209.staticIP.rima-tde.net ([213.97.209.13]:44673
	"EHLO smtp1.dondevamos.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753183Ab3BAAPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 19:15:33 -0500
Received: from localhost ([127.0.0.1] helo=webmail.dondevamos.com)
	by smtp1.dondevamos.com with esmtp (Exim 4.80)
	(envelope-from <pedro.netdev@dondevamos.com>)
	id 1U13rr-0005D9-1F
	for netdev@vger.kernel.org; Fri, 01 Feb 2013 00:48:32 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have recently found out (3.2.0 kernel) that forwarded packets leave 
the outgoing device with L2 802.1p marking (VLAN 0, prio mark on the 
sbk->vlan_tci), but I have no VLANs configured on the system (even 8021q 
module is not loaded).

It looks like when forwarding a packet, skb->vlan_tci keeps the 
priority from the incoming packet, but IMHO I think a L3 router should 
never forward L2 marking (unless somehow configured by the network 
administrator).

The result is that in my home network, my iPad marks some traffic with 
QoS but my old DSL router (with a 2.6.26 kernel, no way to upgrade) will 
gently drop those packets... (I know the issue in that kernel with VLAN 
0 packets, as I wrote a patch around it a couple of years ago, but it 
was for a latter version of the kernel). As a side effect, some traffic 
will never leave my home network to Internet if the user device uses QoS 
(so no Youtube on HTML5 or IPSEC from my home network on my IOS devices 
since I upgraded my Linux gateway to kernel 3.2)...

I can try to fix this and submit a patch, if it is commonly agreed that 
L2 marking should never traverse by default L3 forwarding.

Also, I have written a xtables filter to properly managing VLAN 0 QoS 
marking from / to tc class priorities(skb->priorirty). I will probably 
submit it to netfilter-devel, if they think it is worth it: I am 
currently using it and happy again :-), as it has the side efect of 
removing the VLAN 0 tci using the proper priomap. It allows setting 
ingress priority from vlan_tci and marking 802.1p priority (1q with VLAN 
0) based on egress priority, but I think this is discussion for 
netfilter-devel.


Best regards,
Pedro
