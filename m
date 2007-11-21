From: Patrick McHardy <kaber@trash.net>
Subject: Re: Routing tables associated with VLANs dissappear when parent ethX
 down/up
Date: Wed, 21 Nov 2007 22:12:55 +0100
Message-ID: <47449F57.7080500@trash.net>
References: <474387E4.7020802@candelatech.com>	<47448C4F.3060107@candelatech.com> <20071121120027.54c277ea@freepuppy.rosehill> <4744943E.2010000@trash.net> <47449AE9.5020301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42309 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbXKUVNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 16:13:09 -0500
In-Reply-To: <47449AE9.5020301@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
>> Stephen Hemminger wrote:
>>>
>>> But then if you are doing bonding or bridging of vlan's and you 
>>> bring down the root network device, the upper layer is not
>>> notified (for failover).
>>>   
>>
>> operstate should be enough for this I guess. Ben, what does iproute show
>> for the vlan device when the lower device is down?
>
> It looks like it knows, assuming M-DOWN is useful information.
> Eth2 is un-plugged, by the way.
>
> [root@lanforge-33-46 ~]# ifconfig eth2 up
> [root@lanforge-33-46 ~]# ip link show eth2.2
> 125: eth2.2@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc 
> noqueue
>     link/ether 00:03:2d:08:33:47 brd ff:ff:ff:ff:ff:ff
> [root@lanforge-33-46 ~]# ifconfig eth2 down
> [root@lanforge-33-46 ~]# ip link show eth2.2
> 125: eth2.2@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP,M-DOWN> mtu 1500 
> qdisc noqueue
>     link/ether 00:03:2d:08:33:47 brd ff:ff:ff:ff:ff:ff
> [root@lanforge-33-46 ~]# 

That comes from iproute itself, but the missing LOWER-UP flag
indicates it and that should be enough for bridging and bonding.
I'm unsure about this though since its still a big difference in
userspace visible behaviour, people might just as well manually
configure failover once routing disappears or the device goes down,
or just have routing fall through to different routes. All this
wouldn't work anymore.

Maybe we can make this optional somehow without too much uglyness?

