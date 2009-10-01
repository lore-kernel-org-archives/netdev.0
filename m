From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: tg3: Badness at kernel/mutex.c:207
Date: Thu, 01 Oct 2009 11:36:38 +0200
Message-ID: <4AC47826.1000809@embedded-sol.com>
References: <4ABE85B9.3020304@embedded-sol.com> <20090928205128.GA12652@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:47030 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996AbZJAJgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 05:36:36 -0400
In-Reply-To: <20090928205128.GA12652@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Matt

Matt Carlson wrote:
> On Sat, Sep 26, 2009 at 02:20:57PM -0700, Felix Radensky wrote:
>   
>> Hi,
>>
>> I'm running linux-2.6.31 on a custom MPC8536 based board with BCM57760 chip.
>> Both tg3 driver, and Broadcom PHY driver are modules.
>>
>> Each time I run ifconfig eth2 up, I get the following error message:
>>
>> Badness at kernel/mutex.c:207
>> NIP: c025132c LR: c0251314 CTR: c0251334
>> REGS: efbedbd0 TRAP: 0700   Not tainted  (2.6.31)
>> MSR: 00029000 <EE,ME,CE>  CR: 24020422  XER: 00000000
>> TASK = efacce10[1080] 'ifconfig' THREAD: efbec000
>> GPR00: 00000000 efbedc80 efacce10 00000001 00007020 00000002 00000000 
>> 00000200
>> GPR08: 00029000 c0350000 c0330000 00000001 24020424 10057d94 000002a0 
>> 1000d82c
>> GPR16: 1000d81c 1000d814 10010000 10050000 ef897a0c efbede18 ffff8914 
>> ef897a00
>> GPR24: 00008000 c034b480 efbec000 efb0122c c0350000 efacce10 ef82d2c0 
>> efb01228
>> NIP [c025132c] __mutex_lock_slowpath+0x1f0/0x1f8
>> LR [c0251314] __mutex_lock_slowpath+0x1d8/0x1f8
>> Call Trace:
>> [efbedcd0] [c025134c] mutex_lock+0x18/0x34
>> [efbedcf0] [f534a228] tg3_chip_reset+0x7cc/0x9f8 [tg3]
>> [efbedd20] [f534a8f0] tg3_reset_hw+0x58/0x2360 [tg3]
>> [efbedd70] [f5351dd4] tg3_open+0x610/0x910 [tg3]
>> [efbeddb0] [c01e1c6c] dev_open+0x100/0x138
>> [efbeddd0] [c01dff20] dev_change_flags+0x80/0x1ac
>> [efbeddf0] [c02232cc] devinet_ioctl+0x648/0x824
>> [efbede60] [c0223de4] inet_ioctl+0xcc/0xf8
>> [efbede70] [c01cdf44] sock_ioctl+0x60/0x300
>> [efbede90] [c008a35c] vfs_ioctl+0x34/0x8c
>> [efbedea0] [c008a580] do_vfs_ioctl+0x88/0x724
>> [efbedf10] [c008ac5c] sys_ioctl+0x40/0x74
>> [efbedf40] [c000f814] ret_from_syscall+0x0/0x3c
>> Instruction dump:
>> 0fe00000 4bfffe80 801a000c 5409016f 4182fe60 4bf0f6d9 2f830000 41befe54
>> 3d20c035 8009c2c0 2f800000 40befe44 <0fe00000> 4bfffe3c 9421ffe0 7c0802a6
>>
>> Does it indicate a real problem, or something that can be ignored ?
>>
>> Additional information from kernel log:
>>
>> tg3.c:v3.99 (April 20, 2009)
>> tg3 0002:05:00.0: enabling bus mastering
>> tg3 0002:05:00.0: PME# disabled
>> tg3 mdio bus: probed
>> eth2: Tigon3 [partno(BCM57760) rev 57780001] (PCI Express) MAC address 
>> 00:10:18:00:00:00
>> eth2: attached PHY driver [Broadcom BCM57780] (mii_bus:phy_addr=500:01)
>> eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
>> eth2: dma_rwctrl[76180000] dma_mask[64-bit]
>> tg3 0002:05:00.0: PME# disabled
>>     
>
> Yes, this is a real problem.  The driver is taking the MDIO bus lock
> while holding the device's own spinlock.  I think I may have a
> workaround.  Let me test it and get back to you.
>   

Did you have a chance to look into it ?

Thanks.

Felix.

