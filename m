From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe and mac-vlans problem
Date: Thu, 6 May 2010 18:06:34 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FEA26A969@rrsmsx501.amr.corp.intel.com>
References: <4BDA07DB.8020206@candelatech.com>
 <201004302000.58763.arnd@arndb.de> <4BDB1CF3.8030906@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com>
 <4BDB57A6.1090400@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FE5560B00@rrsmsx501.amr.corp.intel.com>
 <4BE2ECEE.7070200@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FEA26A2D0@rrsmsx501.amr.corp.intel.com>
 <4BE32B4A.2030409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Arnd Bergmann <arnd@arndb.de>, NetDev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33544 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944Ab0EGAGh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 20:06:37 -0400
In-Reply-To: <4BE32B4A.2030409@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> On 05/06/2010 10:51 AM, Tantilov, Emil S wrote:
> 
>> Hi Ben,
>> 
>> We do have a patch in testing (see attached). It may not apply
>> cleanly as it is on top of some other patches currently in
>> validation. Let me know if it works for you.  
> 
> It wasn't difficult to backport this patch to 2.6.31.12....
> 
> I just tested this on an 85998 NIC and 50 MAC-VLANs worked fine.
> 
> The NIC doesn't show as PROMISC in any way I can detect, but I guess
> it must actually be in PROMISC mode:

Yes the interface is in promisc mode. The driver sets the FCTRL.UPE bit
(unicast promisc mode) when the number of allowed rar_entries is exceeded. 

> 
> [root@i7-1qc-1 ~]# cat /sys/class/net/eth11/flags
> 0x1003
> 
> [root@i7-1qc-1 ~]# ip link show dev eth11
> 2: eth11: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
>      state UP qlen 1000 link/ether 00:e0:ed:11:25:12 brd
> ff:ff:ff:ff:ff:ff 

The IFF_PROMISC flag is not set in this case. That's how the driver knows when the promisc mode is turned by the user.

Thanks,
Emil
