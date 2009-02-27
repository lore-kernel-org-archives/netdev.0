From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 08:25:58 -0700
Message-ID: <49A80606.1040508@mlbassoc.com>
References: <20090227125305.GW17040@xi.wantstofly.org> <49A7E87D.5090203@mlbassoc.com> <20090227132319.GY17040@xi.wantstofly.org> <49A7EA3D.8070800@mlbassoc.com> <20090227142754.GB17040@xi.wantstofly.org> <49A7FA57.7030504@mlbassoc.com> <20090227144004.GC17040@xi.wantstofly.org> <49A7FEE1.2020705@mlbassoc.com> <20090227145746.GD17040@xi.wantstofly.org> <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:4565 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754695AbZB0P0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:26:13 -0500
In-Reply-To: <20090227151441.GE17040@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Fri, Feb 27, 2009 at 08:08:22AM -0700, Gary Thomas wrote:
> 
>>>> OK, I did that:
>>>>   Sending discover...
>>>>   PHY: 0:01 - Link is Up - 1000/Full
>>>>
>>>> I now see the fixed PHY (pretender, configured at build time)
>>>> and the 8 LAN sockets:
>>>>   root@ppc_target:~ ls /sys/bus/mdio_bus/devices/
>>>>   0:01         24520:01:01  24520:01:03  24520:01:05  24520:01:07
>>>>   24520:01:00  24520:01:02  24520:01:04  24520:01:06
>>>>
>>>> But nothing seems to get through the switch.  Of course, I
>>>> know that the switch and connections are working because that's
>>>> the path I downloaded/booted the kernel from.
>>>>
>>>> Getting closer :-) Any ideas?
>>> :-)  Do you see messages in your syslog about the lan interfaces
>>> being up, full duplex, etc?  Something a la (from one of my boards):
>>>
>>> 	lan1: link up, 1000 Mb/s, full duplex, flow control disabled
>>> 	lan2: link up, 1000 Mb/s, full duplex, flow control disabled
>> This does seem to work:
>>   root@ppc_target:~ ifconfig lan1.1 up
>>   root@ppc_target:~ lan1.1: link up, 100 Mb/s, full duplex, flow control disabled
>>
>> When I try it on other ports:
>>   root@ppc_target:~ ifconfig lan1.2 up
>>   root@ppc_target:~ ifconfig lan1.3 up
>> Those ports aren't plugged (and I'm 6000 miles from them, literally,
>> so I can't change that)
> 
> OK, that makes sense then.
> 
> 
>>> If yes, can you up the interfaces, and send some packets over them
>>> and see if the TX counters on eth0 increase?  If yes, can you dump
>>> the packets sent out over eth0 using tcpdump?
>> I tried to ping out and into the box.  Nothing seems to go anywhere:
>>
>> root@ppc_target:~ ifconfig
>> eth0      Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
>>           inet addr:192.168.12.189  Bcast:192.168.12.255  Mask:255.255.255.0
>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>>           TX packets:17 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:1000
>>           RX bytes:0 (0.0 B)  TX bytes:1810 (1.7 KiB)
>>           Base address:0x6000
>>
>> lan1.1    Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:0
>>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>>
>> Running tcpdump on the external network (192.168.12.x), I saw
>> no activity.
>>
>> Do I need to do anything more than "ifconfig lan1.1 up"?
> 
> IP addresses should be attached to the lanX.X interfaces, not to eth0
> -- eth0 will only be carrying specially tagged (DSA/EDSA) packets.
> So you should move the IP address to lan1.1.
> 
> Can you trying pinging via lan1.1 and then seeing if there are
> packets transmitted out over eth0, and dump those packets with tcpdump?
> 

It looks like the packets are going out, but I don't see anything
on the wire.  After a few ping attempts:

root@ppc_target:~ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:41 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:2974 (2.9 KiB)
          Base address:0x6000

lan1.1    Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
          inet addr:192.168.12.189  Bcast:192.168.12.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:39 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:1638 (1.5 KiB)

The eth0 and lan1.1 counters are going up at more or less the
same rate.

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
