From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 08:29:09 -0700
Message-ID: <49A806C5.1010200@mlbassoc.com>
References: <20090227132319.GY17040@xi.wantstofly.org> <49A7EA3D.8070800@mlbassoc.com> <20090227142754.GB17040@xi.wantstofly.org> <49A7FA57.7030504@mlbassoc.com> <20090227144004.GC17040@xi.wantstofly.org> <49A7FEE1.2020705@mlbassoc.com> <20090227145746.GD17040@xi.wantstofly.org> <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org> <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:3562 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755290AbZB0P3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:29:24 -0500
In-Reply-To: <20090227152721.GG17040@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Fri, Feb 27, 2009 at 08:25:58AM -0700, Gary Thomas wrote:
> 
>>>>> If yes, can you up the interfaces, and send some packets over them
>>>>> and see if the TX counters on eth0 increase?  If yes, can you dump
>>>>> the packets sent out over eth0 using tcpdump?
>>>> I tried to ping out and into the box.  Nothing seems to go anywhere:
>>>>
>>>> root@ppc_target:~ ifconfig
>>>> eth0      Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
>>>>           inet addr:192.168.12.189  Bcast:192.168.12.255  Mask:255.255.255.0
>>>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>>>>           TX packets:17 errors:0 dropped:0 overruns:0 carrier:0
>>>>           collisions:0 txqueuelen:1000
>>>>           RX bytes:0 (0.0 B)  TX bytes:1810 (1.7 KiB)
>>>>           Base address:0x6000
>>>>
>>>> lan1.1    Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
>>>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>>>>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>>>>           collisions:0 txqueuelen:0
>>>>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>>>>
>>>> Running tcpdump on the external network (192.168.12.x), I saw
>>>> no activity.
>>>>
>>>> Do I need to do anything more than "ifconfig lan1.1 up"?
>>> IP addresses should be attached to the lanX.X interfaces, not to eth0
>>> -- eth0 will only be carrying specially tagged (DSA/EDSA) packets.
>>> So you should move the IP address to lan1.1.
>>>
>>> Can you trying pinging via lan1.1 and then seeing if there are
>>> packets transmitted out over eth0, and dump those packets with tcpdump?
>> It looks like the packets are going out, but I don't see anything
>> on the wire.  After a few ping attempts:
>>
>> root@ppc_target:~ ifconfig
>> eth0      Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>>           TX packets:41 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:1000
>>           RX bytes:0 (0.0 B)  TX bytes:2974 (2.9 KiB)
>>           Base address:0x6000
>>
>> lan1.1    Link encap:Ethernet  HWaddr 00:1D:11:81:00:00
>>           inet addr:192.168.12.189  Bcast:192.168.12.255  Mask:255.255.255.0
>>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>>           TX packets:39 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:0
>>           RX bytes:0 (0.0 B)  TX bytes:1638 (1.5 KiB)
>>
>> The eth0 and lan1.1 counters are going up at more or less the
>> same rate.
> 
> Can you run tcpdump on eth0 to see what the packets look like?

Locally (on the board with the switch)?  That will take a while to
set up as it's a 100% embedded system, runs from FLASH, etc.


-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
