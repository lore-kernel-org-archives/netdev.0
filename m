From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: tg3: unable to handle null pointer dereference [Re: Linux 2.6.21-rc6]
Date: Fri, 6 Apr 2007 14:40:14 -0700
Message-ID: <20070406214014.GF3346@us.ibm.com>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:46156 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933103AbXDFVnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 17:43:05 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05.04.2007 [19:50:11 -0700], Linus Torvalds wrote:
> 
> Ok,
>  I don't think there really is anything very interesting here, but we're 
> hopefully whittling down the list of regressions, and fixing various 
> random other small issues while at it.
> 
> Some smallish MIPS updates, networking (and network driver) fixes, removal 
> of a long obsolete framebuffer driver, etc etc. The shortlog really tells 
> the story.
> 
> We should be getting close to a 2.6.21 release, so please update any 
> regression reports you've done,

2.6.21-rc5 is ok. 2.6.21-rc6 results in

[   14.241665] Unable to handle kernel NULL pointer dereference (address 0000000000000000)
[   14.250025] swapper[1]: Oops 11003706212352 [1]
[   14.254753] Modules linked in:
[   14.258046] 
[   14.258047] Pid: 1, CPU 7, comm:              swapper
[   14.264962] psr : 00001210084a6010 ifs : 8000000000000610 ip  : [<a000000100495371>]    Not tainted
[   14.274399] ip is at tg3_chip_reset+0xf1/0x12c0
[   14.279124] unat: 0000000000000000 pfs : 0000000000000610 rsc : 0000000000000003
[   14.286862] rnat: e000001005bc7d40 bsps: e000001005bc0000 pr  : 68105a9195655599
[   14.294598] ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
[   14.302338] csd : 0000000000000000 ssd : 0000000000000000
[   14.307946] b0  : a0000001004952c0 b6  : a00000010038b2e0 b7  : a000000100486580
[   14.315688] f6  : 1003e000000054e304351 f7  : 1003e0000000000000640
[   14.322164] f8  : 1003e000000054e2dd251 f9  : 1003e0000000000000064
[   14.328643] f10 : 10015e7d113fff182eec0 f11 : 1003e000000000073e88a
[   14.335116] r1  : a000000100d4be30 r2  : a000000100b68fc0 r3  : a000000100b68eb0
[   14.342851] r8  : 0000000000000000 r9  : 0000000000000200 r10 : a00000010089d1a8
[   14.350597] r11 : a000000100486580 r12 : e000001005bc7d70 r13 : e000001005bc0000
[   14.358332] r14 : 0000000000000002 r15 : e000001005d08f10 r16 : e000001005d08ee0
[   14.366072] r17 : e000001005d08748 r18 : e000001005d08758 r19 : 0000000000000000
[   14.373815] r20 : e000001005d08748 r21 : 0000000000000000 r22 : 0000000040027401
[   14.381557] r23 : 0000000000027401 r24 : 0000000040000000 r25 : a00000010089d2f0
[   14.389293] r26 : a000000100b5b5c0 r27 : 0000000000000000 r28 : 0000000000000000
[   14.397035] r29 : 0000000000000000 r30 : 0000000000000000 r31 : e000001005d08708
[   14.404847] 
[   14.404848] Call Trace:
[   14.409160]  [<a000000100013900>] show_stack+0x80/0xa0
[   14.409162]                                 sp=e000001005bc7900 bsp=e000001005bc1120
[   14.422595]  [<a0000001000141f0>] show_regs+0x870/0x8a0
[   14.422597]                                 sp=e000001005bc7ad0 bsp=e000001005bc10c8
[   14.436128]  [<a0000001000390f0>] die+0x1b0/0x320
[   14.436131]                                 sp=e000001005bc7ad0 bsp=e000001005bc1080
[   14.449182]  [<a000000100730980>] ia64_do_page_fault+0xa00/0xba0
[   14.449185]                                 sp=e000001005bc7af0 bsp=e000001005bc1028
[   14.463498]  [<a00000010000b760>] ia64_leave_kernel+0x0/0x280
[   14.463501]                                 sp=e000001005bc7ba0 bsp=e000001005bc1028
[   14.477553]  [<a000000100495370>] tg3_chip_reset+0xf0/0x12c0
[   14.477555]                                 sp=e000001005bc7d70 bsp=e000001005bc0fa0
[   14.491516]  [<a000000100496590>] tg3_halt+0x50/0xa0
[   14.491518]                                 sp=e000001005bc7d80 bsp=e000001005bc0f68
[   14.504796]  [<a0000001004a86a0>] tg3_init_one+0x1c80/0x3080
[   14.504799]                                 sp=e000001005bc7d80 bsp=e000001005bc0eb8
[   14.518796]  [<a000000100399c70>] pci_device_probe+0x1f0/0x2c0
[   14.518799]                                 sp=e000001005bc7dd0 bsp=e000001005bc0e70
[   14.532961]  [<a000000100466560>] really_probe+0x100/0x3a0
[   14.532963]                                 sp=e000001005bc7dd0 bsp=e000001005bc0e20
[   14.546745]  [<a0000001004669c0>] driver_probe_device+0x1c0/0x1e0
[   14.546747]                                 sp=e000001005bc7dd0 bsp=e000001005bc0de8
[   14.561148]  [<a000000100466c80>] __driver_attach+0xc0/0x160
[   14.561150]                                 sp=e000001005bc7dd0 bsp=e000001005bc0db0
[   14.575108]  [<a000000100464bb0>] bus_for_each_dev+0xb0/0x120
[   14.575111]                                 sp=e000001005bc7dd0 bsp=e000001005bc0d78
[   14.589157]  [<a000000100466240>] driver_attach+0x40/0x60
[   14.589160]                                 sp=e000001005bc7df0 bsp=e000001005bc0d58
[   14.602862]  [<a000000100465330>] bus_add_driver+0xf0/0x3c0
[   14.602864]                                 sp=e000001005bc7df0 bsp=e000001005bc0d18
[   14.616736]  [<a000000100467180>] driver_register+0xe0/0x1a0
[   14.616738]                                 sp=e000001005bc7df0 bsp=e000001005bc0cf8
[   14.630696]  [<a00000010039a1a0>] __pci_register_driver+0x120/0x1a0
[   14.630699]                                 sp=e000001005bc7df0 bsp=e000001005bc0cc0
[   14.645280]  [<a0000001008e8270>] tg3_init+0x30/0x60
[   14.645283]                                 sp=e000001005bc7e00 bsp=e000001005bc0ca8
[   14.658540]  [<a0000001008a85f0>] init+0x390/0x740
[   14.658542]                                 sp=e000001005bc7e00 bsp=e000001005bc0c58
[   14.671627]  [<a0000001000113d0>] kernel_thread_helper+0xd0/0x100
[   14.671629]                                 sp=e000001005bc7e30 bsp=e000001005bc0c30
[   14.686023]  [<a000000100009140>] start_kernel_thread+0x20/0x40
[   14.686025]                                 sp=e000001005bc7e30 bsp=e000001005bc0c30
[   14.700284] Kernel panic - not syncing: Attempted to kill init!

on an 8-way IA64. I'm guessing it's one of these:

> Michael Chan (5):
>       [TG3]: Eliminate the unused TG3_FLAG_SPLIT_MODE flag.
>       [TG3]: Exit irq handler during chip reset.
>       [TG3]: Update version and reldate.

probably "Exit irq handler during chip reset"?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
