From: David Miller <davem@davemloft.net>
Subject: Re: ip rule and/or route problem in 2.6.37-rc5+
Date: Sun, 19 Dec 2010 21:42:30 -0800 (PST)
Message-ID: <20101219.214230.39170893.davem@davemloft.net>
References: <4D017D0D.50907@candelatech.com>
	<4D01C65A.6090200@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56883
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752602Ab0LTFmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 00:42:01 -0500
In-Reply-To: <4D01C65A.6090200@candelatech.com>
	<4D07E18F.30703@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 09 Dec 2010 22:19:06 -0800

> On 12/09/2010 05:06 PM, Ben Greear wrote:
>>
>> This problem appears to have happened between 2.6.36.1 and 2.6.37-rc2.
>> We haven't fully bisected the problem yet.
>>
>>
>> The basic test:
>>
>> * one normal interface using DHCP
>> * A second interface specified to use it's own routing table.
>> * 'ip rules' to determine behaviour.
>>
>> After running these commands abelow, the system can no longer
>> route out it's normal interface. It appears that the final line
>> is the one that messes things up. If you flush table 10001 after
>> that, things start working again.
>>
>> The 'pref 20' rule is also important. It should not have
>> any affect on this ping, but it appears that it does, somehow.
>> If you remove it, the problem also goes away, regardless of
>> the routes in table 10001.
>>
>>
>> ip rule add pref 512 lookup local
>> ip rule del pref 0 lookup local
>> ip link set eth2 up
>> ip -4 addr add 172.16.0.102/24 broadcast 172.16.0.255 dev eth2
>> ip rule add to 172.16.0.102 iif eth2 lookup local pref 10
>> ip rule add iif eth2 lookup 10001 pref 20
>> ip route add 172.16.0.0/24 dev eth2 table 10001
>> ip route add unreachable 0/0 table 10001
> 
> Seems this is the commit that broke this behaviour:
> 
> 4465b469008bc03b98a1b8df4e9ae501b6c69d4b is first bad commit
> commit 4465b469008bc03b98a1b8df4e9ae501b6c69d4b
> Author: Tom Herbert <therbert@google.com>
> Date:   Sun May 23 19:54:12 2010 +0000
> 
>     ipv4: Allow configuring subnets as local addresses

Tom, please acknowledge this regression you've added to the tree.
