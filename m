From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: tg3: link is permanently down after ifdown and ifup
Date: Thu, 10 Dec 2009 07:09:06 +0200
Message-ID: <4B208272.4050808@embedded-sol.com>
References: <4B056158.5060104@embedded-sol.com> <4B056D85.5010904@embedded-sol.com> <1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com> <4B1F631E.5030908@embedded-sol.com> <20091210011931.GA30802@xw6200.broadcom.net> <4B2052C0.4030802@embedded-sol.com> <20091210023136.GA31107@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:40477 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760205AbZLJFJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 00:09:10 -0500
In-Reply-To: <20091210023136.GA31107@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Matt

Matt Carlson wrote:
> On Wed, Dec 09, 2009 at 05:45:36PM -0800, Felix Radensky wrote:
>   
>> Hi, Matt
>>
>> Matt Carlson wrote:
>>     
>>> I understand the problem now.  The problem is that tg3_set_power_state()
>>> puts the phy into a low-power mode when it releases the device.  When
>>> the phy is reacquired, a phy reset is missing to take the device back
>>> out of the low-power mode.
>>>
>>> The patch at the bottom of this email is the fix I'm currently testing.
>>> If you wish, you can try it out.
>>>
>>>   
>>>       
>> Thanks a lot for the fix, I'll ask the guys with access to hardware to 
>> test it.
>>
>> The problem with lost link happened to me when link was synchronized
>> at 1000Mbit/sec. At 100Mbit/sec, ifdown would result in the following
>> soft lockup:
>>
>> BUG: soft lockup - CPU#0 stuck for 61s! [events/0:5]
>> Modules linked in: ehci_hcd usbcore
>> NIP: c0191f0c LR: c018774c CTR: c0191f04
>> REGS: ef83fe60 TRAP: 0901 Not tainted (2.6.31)
>> MSR: 00029000 <EE,ME,CE> CR: 24022084 XER: 00000000
>> TASK = ef8312c0[5] 'events/0' THREAD: ef83e000
>> GPR00: f1040000 ef83ff10 ef8312c0 ef8292c0 00000400 00c04808 00000000 
>> 00000000
>> GPR08: 00000000 00000000 00000006 00c04800 44024084
>> NIP [c0191f0c] tg3_read32+0x8/0x18
>> LR [c018774c] _tw32_flush+0x94/0xa4
>> Call Trace:
>> [ef83ff10] [ef8314b8] 0xef8314b8 (unreliable)
>> [ef83ff30] [c0192074] tg3_adjust_link+0x98/0x24c
>> [ef83ff50] [c017eab0] phy_state_machine+0xd4/0x5b8
>> [ef83ff70] [c0037570] worker_thread+0x124/0x1b8
>> [ef83ffc0] [c003b5fc] kthread+0x78/0x7c
>> [ef83fff0] [c000f584] kernel_thread+0x4c/0x68
>>
>> Can you reproduce this ?
>>
>> Thanks a lot for your help.
>>     
>
> Is this with the "Fix phylib locking strategy" patch in place?
>
>   
Yes, this is with tg3.c and broadcom.c from 2.6.32. The hang occurs on 
read from EMAC Mode register.

Felix.


