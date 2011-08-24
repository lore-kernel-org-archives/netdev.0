From: Ben Greear <greearb@candelatech.com>
Subject: Re: Interface without IP address can route??
Date: Wed, 24 Aug 2011 06:24:54 -0700
Message-ID: <4E54FBA6.6090905@candelatech.com>
References: <4E5443CD.60502@candelatech.com> <1314190890.25967.114.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev <netdev@vger.kernel.org>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43175 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab1HXNZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 09:25:34 -0400
In-Reply-To: <1314190890.25967.114.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2011 06:01 AM, jamal wrote:
>
> It makes sense to behave this way.
> IPv4 addresses are owned by the system not interfaces.
> If you want to control the forwarding behavior, control ARP so it doesnt
> respond on the interfaces with no IP.

ARP is already controlled, but interface was effectively promisc,
so it received packets anyway.  This allows me to bridge packets
in user-space using packet sockets.

I understand your argument about IPs being owned by system instead of
interface, but I think it's the wrong behaviour in this case.  Can
you think of any case where this behaviour actually helps?

Either way, it appears I can work around this by explicitly disabling
forwarding for this particular interface.

Thanks,
Ben

>
> cheers,
> jamal
> On Tue, 2011-08-23 at 17:20 -0700, Ben Greear wrote:
>> I just noticed on a 3.0.1 kernel that the system is routing packets
>> received on an interface without an IP address. (I was trying to use the
>> interface in a user-space wifi_station-to-wired bridge application).
>>
>> [root@lf0301-demo1 lanforge]# cat /proc/sys/net/ipv4/conf/sta1/forwarding
>> 1
>> [root@lf0301-demo1 lanforge]# ifconfig sta1
>> sta1      Link encap:Ethernet  HWaddr 00:03:2D:12:16:0D
>>             UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>             RX packets:85248 errors:0 dropped:0 overruns:0 frame:0
>>             TX packets:1419 errors:0 dropped:0 overruns:0 carrier:0
>>             collisions:0 txqueuelen:1000
>>             RX bytes:67423391 (64.2 MiB)  TX bytes:1087581 (1.0 MiB)
>>
>>
>> Seems that older stock kernels have forwarding set for interfaces without
>> IP addresses too, so maybe it's always been this way...
>>
>> Anyway, I can add some logic to my config to explicitly disable
>> routing for interfaces w/out IP address, but it seems to me that
>> it should automatically not route packets received on an interface
>> that had no IP address on it..
>>
>> Thanks,
>> Ben
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
