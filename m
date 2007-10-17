From: Milan Kocian <milon@wq.cz>
Subject: Re: Difference between device statistics from ifconfig and ip -s l
	l
Date: Wed, 17 Oct 2007 12:13:03 +0200
Message-ID: <20071017101303.GB16356@wq.cz>
References: <20071017092659.GA16356@wq.cz> <4715D79E.7020201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-sitel.lam.cz ([212.71.129.172]:54461 "EHLO nt.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750930AbXJQKNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 06:13:08 -0400
Content-Disposition: inline
In-Reply-To: <4715D79E.7020201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 11:36:30AM +0200, Patrick McHardy wrote:
> Milan Kocian wrote:
>> hello,
>> see dropped packets, please:
>> sit:~# ifconfig eth0
>> eth0      Link encap:Ethernet  HWaddr 00:04:23:D6:D5:DE            UP 
>> BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>           RX packets:522284892 errors:0 dropped:16800 overruns:0 frame:0
>>           TX packets:506064445 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:1000           RX bytes:1405350664 (1.3 
>> GiB)  TX bytes:4082649020 (3.8 GiB)
>>           Base address:0xac00 Memory:ff6e0000-ff700000 see via ip l l 
>> (here are no dropped packets):
>> sit:~# ip -s l l dev eth0
>> 2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc htb qlen 1000
>>     link/ether 00:04:23:d6:d5:de brd ff:ff:ff:ff:ff:ff
>>     RX: bytes  packets  errors  dropped overrun mcast       2494988681 
>> 523755694 0       0       0       57458      TX: bytes  packets  errors  
>> dropped carrier collsns     453184821  507470461 0       0       0       0 
>>      but see more detailed stats (dropped packet are as missed in RX 
>> errors ?!):
>> sit:~# ip -s -s l l dev eth0
>> 2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc htb qlen 1000
>>     link/ether 00:04:23:d6:d5:de brd ff:ff:ff:ff:ff:ff
>>     RX: bytes  packets  errors  dropped overrun mcast       2752159866 
>> 524110163 0       0       0       57485      RX errors: length  crc     
>> frame   fifo    missed
>>                0        0       0       0       16800      TX: bytes  
>> packets  errors  dropped carrier collsns     607359337  507807361 0       
>> 0       0       0          TX errors: aborted fifo    window  heartbeat
>>                0        0       0       0      Is this bug or feature ? 
>> From my point of view is somewhere lost any sum.
>> Or is it driver dependent? Kernel 2.6.23.1 (in 2.6.20.20 is the same 
>> behavior), driver e1000. iproute2-ss070313; net-tools 1.60, ifconfig 1.42 
>> (2001-04-13)
>
>
> ifconfig gets its data from /proc/net/dev, which adds up rx_errors
> and rx_missed.
>

Adds up rx_errors and rx_missed and prints it as dropped ? Ok, ifconfig is
a little old. But why I don't see missed packets from RX errors detailed stats 
(ip -s -s l l) in non-detailed stats as errors and see zero ?

regards,

-- 
Milan Kocian
