From: Ben Greear <greearb@candelatech.com>
Subject: Re: Add/Delete IPv6 addresses and netlink
Date: Tue, 17 Jun 2008 08:47:33 -0700
Message-ID: <4857DC95.8000709@candelatech.com>
References: <48571470.7010307@candelatech.com> <20080617121821.GC20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:52006 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbYFQPrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 11:47:40 -0400
In-Reply-To: <20080617121821.GC20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> * Ben Greear <greearb@candelatech.com> 2008-06-16 18:33
>   
>> I am not sure whether I am just confused about how all of this is 
>> supposed to work or not, but the
>> following commands will leave the global address in tentative state:
>>
>> ip link set eth1 down; ip -6 addr flush dev eth1;
>> ip -6 addr add 2000::9:2/112 scope global dev eth1
>> ip link set eth1 up
>> # Wait 10+ seconds
>> ip -6 addr show dev eth1
>> 3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>>    inet6 2000::9:2/112 scope global tentative
>>       valid_lft forever preferred_lft forever
>>    inet6 fe80::203:2dff:fe0c:d022/64 scope link
>>       valid_lft forever preferred_lft forever
>>     
>
> Do you see a "ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready"
> message in the console when you up the device?
>   

No, I do not see this message.   I do see a driver message in the kernel:

Jun 17 08:43:04 localhost kernel: eth1: link up, 100Mbps, full-duplex, 
lpa 0x41E1

I'm using the 8139too driver.  I notice that it shows full link
speed (100-FD) when the NIC is admin down.   Maybe that is causing it to not
go through an expected state change?

I'll work on doing this same test with a vanilla kernel but on this 
hardware just in case I've
screwed something up somewhere...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


