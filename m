From: Ben Greear <greearb@candelatech.com>
Subject: Re: Routing tables associated with VLANs dissappear when parent ethX
 down/up
Date: Wed, 21 Nov 2007 12:54:01 -0800
Message-ID: <47449AE9.5020301@candelatech.com>
References: <474387E4.7020802@candelatech.com>	<47448C4F.3060107@candelatech.com> <20071121120027.54c277ea@freepuppy.rosehill> <4744943E.2010000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:35412 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483AbXKUUyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 15:54:10 -0500
In-Reply-To: <4744943E.2010000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Stephen Hemminger wrote:
>> On Wed, 21 Nov 2007 11:51:43 -0800
>> Ben Greear <greearb@candelatech.com> wrote:
>>
>>  
>>> For consideration, this patch seems to work for me.  I'm not sure
>>> why we ever listed to these events.  I've only tested on a NIC that
>>> doesn't support hw-accel at the moment..will test with e1000 later.
>>>
>>> Thanks,
>>> Ben
>>>
>>>     
>>
>> But then if you are doing bonding or bridging of vlan's and you bring 
>> down the root network device, the upper layer is not
>> notified (for failover).
>>   
> 
> operstate should be enough for this I guess. Ben, what does iproute show
> for the vlan device when the lower device is down?

It looks like it knows, assuming M-DOWN is useful information.
Eth2 is un-plugged, by the way.

[root@lanforge-33-46 ~]# ifconfig eth2 up
[root@lanforge-33-46 ~]# ip link show eth2.2
125: eth2.2@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
     link/ether 00:03:2d:08:33:47 brd ff:ff:ff:ff:ff:ff
[root@lanforge-33-46 ~]# ifconfig eth2 down
[root@lanforge-33-46 ~]# ip link show eth2.2
125: eth2.2@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP,M-DOWN> mtu 1500 qdisc noqueue
     link/ether 00:03:2d:08:33:47 brd ff:ff:ff:ff:ff:ff
[root@lanforge-33-46 ~]#

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

