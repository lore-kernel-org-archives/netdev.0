From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: Regression in bonding between 2.6.26.8 and 2.6.27.6
Date: Wed, 19 Nov 2008 08:53:26 +0100
Message-ID: <4923C5F6.5000409@krogh.cc>
References: <491FEAD5.4090205@krogh.cc> <17663.1226965523@death.nxdomain.ibm.com> <49232489.4000504@krogh.cc> <17409.1227041619@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:40268 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752621AbYKSHxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 02:53:37 -0500
In-Reply-To: <17409.1227041619@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jay.

You're right. I misconfigured the static setup while moving it for 
testing and I moved the misconfiguration back to the dynamic setup. I'll 
make another response to the same message trying to fill in the 
questions while having it configured correctly.

Jesper

Jay Vosburgh wrote:
> Jesper Krogh <jesper@krogh.cc> wrote:
> 
>> Jay Vosburgh wrote:
> [...]
>>> 	What exactly does "doesn't get up" mean? 
>> Looks like this:
>> # ifconfig bond0
>> bond0     Link encap:Ethernet  HWaddr 00:1e:68:57:82:b2
>>          inet6 addr: fe80::21e:68ff:fe57:82b2/64 Scope:Link
>>          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>>          RX packets:74 errors:0 dropped:0 overruns:0 frame:0
>>          TX packets:17 errors:0 dropped:0 overruns:0 carrier:0
>>          collisions:0 txqueuelen:0
>>          RX bytes:5952 (5.8 KB)  TX bytes:1900 (1.8 KB)
>>
>> (usually this would have been assigned an ip-address using dhcp, does that
>> with 2.6.26.8, with the same configuration). Manually running dhclient on
>> the interface doesn't bring it up either.
> 
> 	For this case, when there's a non-zero HWaddr assigned, what is
> in /proc/net/bonding/bond0 and what bonding related messages are in
> dmesg or /var/log/messages?
> [...]
>> Booting up with static ip configuration it looks like this:
>>
>> # ifconfig
>> bond0     Link encap:Ethernet  HWaddr 00:00:00:00:00:00 
>>
>>          inet addr:10.194.132.90  Bcast:10.194.133.255 Mask:255.255.254.0
>>          UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1 
>>          RX packets:0 errors:0 dropped:0 overruns:0 frame:0 
>>          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0 
>>          collisions:0 txqueuelen:0 
>>          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>>
>> Apparently correct, but absolutely no traffic can go through the interface.
> 
> 	This is different, and not correct: there's no HWaddr.  That
> probably means there are no slaves.  This is most likely a totally
> separate problem; the first information suggests that the bond has
> slaves, but isn't working; this suggests that the bond has no slaves
> (which is why it won't work).
> 
>> Configured with a static ip. ifconfig claims that the interface is up and
>> configured with the ip-address.
>>
>> # cat /proc/net/bonding/bond0
>> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
>>
>> Bonding Mode: IEEE 802.3ad Dynamic link aggregation
>> Transmit Hash Policy: layer2 (0)
>> MII Status: down
>> MII Polling Interval (ms): 100
>> Up Delay (ms): 0
>> Down Delay (ms): 0
>>
>> 802.3ad info
>> LACP rate: slow
>> bond bond0 has no active aggregator
>>
>> # ifconfig bond0
>> bond0     Link encap:Ethernet  HWaddr 00:00:00:00:00:00
>>          inet addr:10.194.132.90  Bcast:10.194.133.255  Mask:255.255.254.0
>>          UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1
>>          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>>          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>>          collisions:0 txqueuelen:0
>>          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
> 
> 	As with the prior information, the above indicates that there
> are no slaves attached to the bond.  There's no HWaddr, and the
> /proc/net/bonding/bond0 lists no slaves.
> 
> 	For this case (bonding HWaddr all zeros), what does dmesg or
> /var/log/messages list for bonding?  This is most likely some kind of
> configuration problem causing no interfaces to be enslaved.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

