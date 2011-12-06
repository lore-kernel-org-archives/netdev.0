From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] fsl_pq_mdio: Clean up tbi address configuration
Date: Mon, 5 Dec 2011 23:38:14 -0600
Message-ID: <436A94C3-8F5B-4A8F-A46B-B66B503B98A0@kernel.crashing.org>
References: <1321024239-18861-1-git-send-email-afleming@freescale.com> <20111114.002630.2254622894958283155.davem@davemloft.net> <D789ECCE-08DE-4E6D-BCA7-2C54EC5758B7@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45658 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976Ab1LFFiU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:38:20 -0500
In-Reply-To: <D789ECCE-08DE-4E6D-BCA7-2C54EC5758B7@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 1, 2011, at 10:38 PM, Kumar Gala wrote:

> 
> On Nov 13, 2011, at 11:26 PM, David Miller wrote:
> 
>> From: Andy Fleming <afleming@freescale.com>
>> Date: Fri, 11 Nov 2011 09:10:39 -0600
>> 
>>> The code for setting the address of the internal TBI PHY was
>>> convoluted enough without a maze of ifdefs. Clean it up a bit
>>> so we allow the logic to fail down to -ENODEV at the end of
>>> the if/else ladder, rather than using ifdefs to repeat the same
>>> failure code over and over.
>>> 
>>> Also, remove the support for the auto-configuration. I'm not aware of
>>> anyone using it, and it ends up using the bus mutex before it's been
>>> initialized.
>>> 
>>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> 
>> Applied, thanks.
> 
> I believe we need this on mainline otherwise we get something like:
> 
> Fixed MDIO Bus: probed
> Unable to handle kernel paging request for data at address 0x00000000
> Faulting instruction address: 0xc0451630
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=2 P1022 DS
> Modules linked in:
> NIP: c0451630 LR: c0451618 CTR: 00000007
> REGS: ef03fce0 TRAP: 0300   Not tainted  (3.2.0-rc3-00099-g883381d)
> MSR: 00029000 <EE,ME,CE>  CR: 24042022  XER: 00000000
> DEAR: 00000000, ESR: 00800000
> TASK = ef040000[1] 'swapper' THREAD: ef03e000 CPU: 0
> GPR00: ef03fd98 ef03fd90 ef040000 ef1ab22c 00000000 00000002 ffeb0000 0000fffe
> GPR08: b0541215 00000000 00000000 00000000 24042028 23c406c2 00000000 00000000
> GPR16: c0000a00 00000014 3fffffff 03ff9000 00000015 7ff3a760 f1044030 fffffff4
> GPR24: c053e128 ef1ab230 c056a3a8 ef03e000 ef040000 ef1ab22c 00000000 ef1ab228
> NIP [c0451630] __mutex_lock_slowpath+0xb4/0x190
> LR [c0451618] __mutex_lock_slowpath+0x9c/0x190
> Call Trace:
> [ef03fdd0] [c0451758] mutex_lock+0x4c/0x50
> [ef03fde0] [c02b5124] mdiobus_read+0x38/0x74
> [ef03fe00] [c02b41f4] get_phy_id+0x24/0x80
> [ef03fe20] [c02b9de4] fsl_pq_mdio_probe+0x3b4/0x580
> [ef03feb0] [c0266120] platform_drv_probe+0x20/0x30
> [ef03fec0] [c0264bbc] driver_probe_device+0xa4/0x1d4
> [ef03fee0] [c0264da8] __driver_attach+0xbc/0xc0
> [ef03ff00] [c0263ac0] bus_for_each_dev+0x60/0x9c
> [ef03ff30] [c02647f4] driver_attach+0x24/0x34
> [ef03ff40] [c0264444] bus_add_driver+0x1ac/0x274
> [ef03ff70] [c02651b0] driver_register+0x88/0x154
> [ef03ff90] [c0266450] platform_driver_register+0x68/0x78
> [ef03ffa0] [c05d93b8] fsl_pq_mdio_init+0x18/0x28
> [ef03ffb0] [c0001eb8] do_one_initcall+0x34/0x1a8
> [ef03ffe0] [c05bb82c] kernel_init+0xa0/0x13c
> [ef03fff0] [c000d878] kernel_thread+0x4c/0x68
> Instruction dump:
> 801c0020 2f800063 419dffe8 3bbf0004 7fa3eb78 48001aad 813f000c 38010008
> 3b3f0008 901f000c 93210008 9121000c
> 3800ffff 93810010 7c0004ac
> ---[ end trace 1643a9a9c5097f8f ]---
> Kernel panic - not syncing: Attempted to kill init!
> Call Trace:
> [ef03fbc0] [c0008044] show_stack+0x44/0x154 (unreliable)
> [ef03fc00] [c04532c8] panic+0xa4/0x1d8
> [ef03fc50] [c0049a00] do_exit+0x5dc/0x684
> [ef03fca0] [c000a6f0] die+0xdc/0x1b4
> [ef03fcc0] [c00128d0] bad_page_fault+0xb4/0xfc
> [ef03fcd0] [c000ebe4] handle_page_fault+0x7c/0x80
> --- Exception: 300 at __mutex_lock_slowpath+0xb4/0x190
>   LR = __mutex_lock_slowpath+0x9c/0x190
> [ef03fd90] [00000000]   (null) (unreliable)
> [ef03fdd0] [c0451758] mutex_lock+0x4c/0x50
> [ef03fde0] [c02b5124] mdiobus_read+0x38/0x74
> [ef03fe00] [c02b41f4] get_phy_id+0x24/0x80
> [ef03fe20] [c02b9de4] fsl_pq_mdio_probe+0x3b4/0x580
> [ef03feb0] [c0266120] platform_drv_probe+0x20/0x30
> [ef03fec0] [c0264bbc] driver_probe_device+0xa4/0x1d4
> [ef03fee0] [c0264da8] __driver_attach+0xbc/0xc0
> [ef03ff00] [c0263ac0] bus_for_each_dev+0x60/0x9c
> [ef03ff30] [c02647f4] driver_attach+0x24/0x34
> [ef03ff40] [c0264444] bus_add_driver+0x1ac/0x274
> [ef03ff70] [c02651b0] driver_register+0x88/0x154
> [ef03ff90] [c0266450] platform_driver_register+0x68/0x78
> [ef03ffa0] [c05d93b8] fsl_pq_mdio_init+0x18/0x28
> [ef03ffb0] [c0001eb8] do_one_initcall+0x34/0x1a8
> [ef03ffe0] [c05bb82c] kernel_init+0xa0/0x13c
> [ef03fff0] [c000d878] kernel_thread+0x4c/0x68
> Rebooting in 180 seconds..

David,

Any comment on getting this patch pulled into net.git?

- k