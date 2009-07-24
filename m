From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Jumbo frame question...
Date: Fri, 24 Jul 2009 11:44:06 -0700
Message-ID: <4A6A00F6.3030005@hp.com>
References: <200907241141.55097.rgetz@blackfin.uclinux.org>	<20090724.093243.201296391.davem@davemloft.net>	<4A69E3CF.1040805@hp.com> <200907241421.55986.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:2829 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903AbZGXSoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 14:44:15 -0400
In-Reply-To: <200907241421.55986.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robin Getz wrote:
> On Fri 24 Jul 2009 12:39, Rick Jones pondered:
> 
>>David Miller wrote:
>>
>>>From: Robin Getz <rgetz@blackfin.uclinux.org>
>>>Date: Fri, 24 Jul 2009 11:41:55 -0400
>>>
>>>
>>>>Should a gigabit card, configured as 100, be sending jumbo UDP frames?
>>>>
>>>>My understanding, is no - this is a spec violation..
>>
>>In so far as there is no de jure spec for Jumbo Frames, it is rather
>>difficult to have a spec violation :).
> 
> 
> The spec I was talking about was the MTU...
> 
> rgetz@pinky:~> /sbin/ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:11:11:B0:A5:D4
>           inet addr:192.168.0.10  Bcast:192.168.0.255  Mask:255.255.255.0
>           inet6 addr: fe80::211:11ff:feb0:a5d4/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:45978 errors:5 dropped:0 overruns:0 frame:0
>           TX packets:44536 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:3193 txqueuelen:1000
>           RX bytes:11583575 (11.0 Mb)  TX bytes:20025122 (19.0 Mb)
>           Interrupt:16
> 
> 
> My MTU is 1500, but when tftp requests a block size of over that - the host 
> does not fragment it (like I thought it should).

Well, you should have said that to begin with!-)  Saying "Jumbo Frames" makes 
people think you have enabled JumboFrames - ie increased the MTU to something 
like 9000 bytes.

>>Not a case of too much rope?  Given that (IIRC) Jumbo Frame was not
>>introduced in Ethernet NICs until Gigabit came along (eg Alteon), the
>>chances a (legacy) 100 Mbit/s network would have JF-capable NICs is epsilon.
> 
> 
> Yeah - I think that this is the issue - my old hub (which is what I normally 
> use for ethernet testing is only transferring it's MTU (1500 bytes), and 
> dropping the rest...
> 
> Isn't there a MTU max size discovery that should be done somewhere before the 
> host sends jumbo packets?
> 
> http://tools.ietf.org/html/rfc1191
> 
> And -- in the UDP/TFTP case - isn't the server responsible for determining 
> this? (since it need to determine if fragmentation needs to happen or not?)

PathMTU discovery is based on the receipt of ICMP messages saying in essence 
"this datagram was too big to forwared without fragmenting and the don't 
fragment bit was set, please send nothing larger than <foo> this way"

That only happens when crossing routers, so if this TFTP transfer is over the 
local LAN, there is no router to say so, leaving the choice of fragment size to 
the sending system.

Does this NIC offer UDP Fragmentation Offload but perhaps only in GbE mode, but 
the driver doesn't clear that bit when the speed is 100 Mbit, or perhaps 
something up the stack cached knowledge that changed on it?

rick jones
