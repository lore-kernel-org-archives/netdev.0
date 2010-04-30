From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe and mac-vlans problem
Date: Fri, 30 Apr 2010 15:04:59 -0700
Message-ID: <4BDB540B.3080005@candelatech.com>
References: <4BDA07DB.8020206@candelatech.com> <201004302000.58763.arnd@arndb.de> <4BDB1CF3.8030906@candelatech.com> <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, NetDev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35601 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154Ab0D3WFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 18:05:10 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2010 02:13 PM, Tantilov, Emil S wrote:

>> I will double-check the NIC chipset on the system that showed the
>> problem yesterday.
>
> I ran a quick test in my setup with 82599 and was able to pass traffic
> on all 50 mac-vlans without issues. This is on net-next.

I attempted this on an 82598 system, and it reproduces the problem
for me, so I think that must be what the customer was using as well
(I haven't gotten access to their system again, yet)

I created 50 mac-vlans on eth11, but it does NOT go PROMISC
mode as far as I can tell.  Only 14 of the mac-vlans are
working.  I'm using 64kbps UDP streams, 1k packets (ie, light load).

[root@i7-1qc-1 lanforge]# cat /sys/class/net/eth11/flags
0x1003

[root@i7-1qc-1 lanforge]# ip link show dev eth11
2: eth11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
     link/ether 00:e0:ed:11:25:12 brd ff:ff:ff:ff:ff:ff

I put it into promisc mode and now they all work:

[root@i7-1qc-1 lanforge]# ip link show dev eth11
2: eth11: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
     link/ether 00:e0:ed:11:25:12 brd ff:ff:ff:ff:ff:ff
[root@i7-1qc-1 lanforge]# cat /sys/class/net/eth11/flags
0x1103


This is on a slightly modified 2.6.31.12 kernel.  I haven't had a chance to try
this on a more recent kernel yet.

lspci:
03:00.0 Ethernet controller: Intel Corporation 82598EB 10 Gigabit AF Dual Port Network Connection (rev 01)
03:00.1 Ethernet controller: Intel Corporation 82598EB 10 Gigabit AF Dual Port Network Connection

Please let me know if I can offer any additional information.  It will probably take a few days before I can
get the .34 kernel in testing.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

