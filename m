From: Patrick McHardy <kaber@trash.net>
Subject: Re: macvlan on top mlx4 fails
Date: Fri, 29 Jan 2010 16:03:06 +0100
Message-ID: <4B62F8AA.5080400@trash.net>
References: <4B62F12F.9020302@fr.ibm.com> <4B62F4F7.9080701@trash.net> <4B62F6FA.9070000@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41325 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440Ab0A2PDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 10:03:12 -0500
In-Reply-To: <4B62F6FA.9070000@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Patrick McHardy wrote:
>> Daniel Lezcano wrote:
>>> Hi all,
>>>
>>> I am trying to have a macvlan on top of an ethernet driver infiniband
>>> emulation communicating with the macvlan on anoher host with the same
>>> configuration. But I am not able to ping them through the ip address
>>> assigned to each macvlan.
>>>
>>> On the host1 (s1):
>>>
>>> ...
>>> s2:~ # ping 1.2.3.5
>>> PING 1.2.3.5 (1.2.3.5) 56(84) bytes of data.
>>> From 1.2.3.4: icmp_seq=2 Destination Host Unreachable
>>> From 1.2.3.4 icmp_seq=2 Destination Host Unreachable
>>> From 1.2.3.4 icmp_seq=3 Destination Host Unreachable
>>> From 1.2.3.4 icmp_seq=4 Destination Host Unreachable
>>> ^C
>>> --- 1.2.3.5 ping statistics ---
>>> 5 packets transmitted, 0 received, +4 errors, 100% packet loss, time
>>> 4010ms
>>> , pipe 3
>>>
>>> The arp cache:
>>>
>>> Address                  HWtype  HWaddress           Flags Mask    Iface
>>> 1.2.3.5                          (incomplete)    mc1
>>>
>>>
>>> When doing a tcpdump on s2 host, I have arp who-as request:
>>>
>>>
>>> 09:14:20.764389 arp who-has 1.2.3.5 tell 1.2.3.4
>>> 09:14:20.764394 arp who-has 1.2.3.5 tell 1.2.3.4
>>> 09:14:20.764427 arp who-has 1.2.3.5 tell 1.2.3.4
>>>
>>>
>>> But doing the same tcpdump on the s1 host I don't see there arp request.
>>>
>>> The output of lscpi:
>>>
>>> s2:~ # lspci
>>> 0000:00:01.0 RAID bus controller: IBM Obsidian chipset SCSI controller
>>> (rev 02)
>>> 0001:00:01.0 USB Controller: NEC Corporation USB (rev 43)
>>> 0001:00:01.1 USB Controller: NEC Corporation USB (rev 43)
>>> 0001:00:01.2 USB Controller: NEC Corporation USB 2.0 (rev 04)
>>> 0002:00:01.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev
>>> 02)
>>> 0003:01:00.0 InfiniBand: Mellanox Technologies MT25418 [ConnectX IB DDR,
>>> PCIe 2.0 2.5GT/s] (rev a0)
>>>
>>>
>>> I am a newbie on infiniband so I was wondering if I did something wrong
>>> or if this is unsupported.
>>
>> Well, I don't know much about infiniband myself. On which device
>> are you running tcpdump? 
> 
> I did:
> 
> tcpdump -i any arp dst or src 1.2.3.5
> 
> In case its the eth-device, does running
>> tcpdump directly on top of the ib-devices make any difference?
> 
> Yes, right. The arp request are seen on eth1 but not on the ib.

That would be fine unless I'm misunderstanding your setup - with
macvlan bound to eth1 they should be visible on both eth1 any the
macvlan device.

I'm guessing that you have a filter misconfiguration. You need
arp_ignore=1 and possibly rp_filter=0.

>> Perhaps its not properly propagating the promiscous mode flag or
>> the secondary unicast addresses.
> 
> Is it possible to check that ?

If the devices are not already in promiscous mode, you should see
"device XXX entered promiscuous mode" for both devices in the
ring buffer.
