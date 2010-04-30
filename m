From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe and mac-vlans problem
Date: Fri, 30 Apr 2010 16:26:44 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE5560B00@rrsmsx501.amr.corp.intel.com>
References: <4BDA07DB.8020206@candelatech.com>
 <201004302000.58763.arnd@arndb.de> <4BDB1CF3.8030906@candelatech.com>
 <EA929A9653AAE14F841771FB1DE5A1365FE55609F0@rrsmsx501.amr.corp.intel.com>
 <4BDB57A6.1090400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Arnd Bergmann <arnd@arndb.de>, NetDev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26730 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118Ab0D3W0s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 18:26:48 -0400
In-Reply-To: <4BDB57A6.1090400@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> On 04/30/2010 02:13 PM, Tantilov, Emil S wrote:
>> Ben Greear wrote:
>>> On 04/30/2010 11:00 AM, Arnd Bergmann wrote:
>>>> On Friday 30 April 2010 00:27:39 Ben Greear wrote:
>>>>> Basically, we create 50 mac-vlans, with sequential MAC addresses
>>>>> and sequential IP addresses, and set up ip rules properly.
>>>>> 
>>>>> The issue is that only 10 or so of the mac-vlans receive other
>>>>> than broadcast packets.  The ixgbe NIC doesn't show PROMISC mode.
>>>> 
>>>> I just took a brief look at the driver and noticed that 82599
>>>> should be able to handle 128 entries before going into promisc
>>>> mode, while 82598 (the same driver) does 16.
>>>> 
>>>> Maybe the logic for>16 entries is wrong, so you could try forcing
>>>> hw->mac.num_rar_entries to 16 for 82599 as well.
>>> 
>>> I think I was actually on an 825998 system when I saw it yesterday,
>>> but I have seen similar issues on 82599, though I didn't take time
>>> to debug it fully, so it could have been something else.
>>> 
>>> I will double-check the NIC chipset on the system that showed the
>>> problem yesterday.
>> 
>> I ran a quick test in my setup with 82599 and was able to pass
>> traffic on all 50 mac-vlans without issues. This is on net-next.
> 
> For an 82599 system, I can get 127 mac-vlans working out of 500
> created. 
> 
> That NIC also does not go PROMISC with lots (500) of mac-vlans.
> 
> Once I put it in promisc mode manually, it works fine.
> 
> So, I think whatever logic is supposed to put the NIC into promisc
> mode when it overflows it's lookup tables isn't working for ixgbe
> in 2.6.31.12.

Yeah, you're right. I was able to repro it. 

We'll look into it.

Thanks,
Emil