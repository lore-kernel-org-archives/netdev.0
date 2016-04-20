From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 1/1] drivers: net: cpsw: Prevent NUll pointer
 dereference with two PHYs
Date: Wed, 20 Apr 2016 12:37:48 +0300
Message-ID: <57174DEC.5090104@ti.com>
References: <57165269.40207@ti.com>
 <20160419131443.7a3b3ef7.drivshin.allworx@gmail.com> <57167C79.20205@ti.com>
 <20160419.184339.1558043853032502121.davem@davemloft.net>
 <20160419193808.29dc51c3.drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <andrew.goodbody@cambrionix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <tony@atomide.com>
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160419193808.29dc51c3.drivshin.allworx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/20/2016 02:38 AM, David Rivshin (Allworx) wrote:
> On Tue, 19 Apr 2016 18:43:39 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Grygorii Strashko <grygorii.strashko@ti.com>
>> Date: Tue, 19 Apr 2016 21:44:09 +0300
>>
>>> May be you can send revert + your patch 1 (only fix for this issue).
>>>
>>> Dave, Does that sound good to you?
>>
>> Sure.
> 
> OK, I will hopefully have that ready tomorrow evening.
> 
> Anything in particular I should mention in the revert commit message?
> I didn't find a discussion on it, other than the earlier statement that
> "it breaks boot on many TI boards".
> 

Such kind of issues are tracked automatically now for ARM through https://kernelci.org
Example:
https://storage.kernelci.org/next/next-20160419/arm-multi_v7_defconfig+CONFIG_EFI=y/lab-cambridge/boot-am335x-boneblack.txt

And We're trying to auto check it internally also
https://github.com/nmenon/kernel-test-logs

Below is my boot log:


 ata1: SATA max UDMA/133 mmio [mem 0x4a140000-0x4a1410ff] port 0x100 irq 332
 mtdoops: mtd device (mtddev=name/number) must be supplied
 davinci_mdio 48485000.mdio: davinci mdio revision 1.6
 davinci_mdio 48485000.mdio: detected phy mask fffffff9
 libphy: 48485000.mdio: probed
 davinci_mdio 48485000.mdio: phy[1]: device 48485000.mdio:01, driver unknown
 davinci_mdio 48485000.mdio: phy[2]: device 48485000.mdio:02, driver unknown
 cpsw 48484000.ethernet: Detected MACID = 74:da:ea:47:7d:9c
 cpsw 48484000.ethernet: cpsw: Random MACID = ca:39:e7:f3:28:69
 Unable to handle kernel paging request at virtual address fffffffc
 pgd = c0004000
 [fffffffc] *pgd=affae861, *pte=00000000, *ppte=00000000
 Internal error: Oops: 37 [#1] SMP ARM
 Modules linked in:
 CPU: 1 PID: 1 Comm: swapper/0 Tainted: G        W       4.6.0-rc4-next-20160419-00002-g94c3d2a #4
 Hardware name: Generic DRA74X (Flattened Device Tree)
 task: ee0c4d80 ti: ee0c6000 task.ti: ee0c6000
 PC is at kset_find_obj+0x28/0xa4
 LR is at kset_find_obj+0x3c/0xa4
 pc : [<c04814b4>]    lr : [<c04814c8>]    psr: a0000013
 sp : ee0c7ec8  ip : 00000000  fp : c0b005a0
 
 [<c04814b4>] (kset_find_obj) from [<c0523780>] (driver_find+0x14/0x30)
 ata1: SATA link down (SStatus 0 SControl 300)
 [<c0523780>] (driver_find) from [<c0523804>] (driver_register+0x68/0xf8)
 [<c0523804>] (driver_register) from [<c010185c>] (do_one_initcall+0x3c/0x178)
 [<c010185c>] (do_one_initcall) from [<c0b00e94>] (kernel_init_freeable+0x218/0x2e8)
 [<c0b00e94>] (kernel_init_freeable) from [<c07a4bc8>] (kernel_init+0x8/0x118)
 [<c07a4bc8>] (kernel_init) from [<c01078d0>] (ret_from_fork+0x14/0x24)
 Code: e5954000 e1550004 e2444004 0a00000a (e5943000) 
 ---[ end trace 593c492662ed437e ]---
 Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
 
 CPU0: stopping
 CPU: 0 PID: 0 Comm: swapper/0 Tainted: G      D W       4.6.0-rc4-next-20160419-00002-g94c3d2a #4
 Hardware name: Generic DRA74X (Flattened Device Tree)
 [<c01101dc>] (unwind_backtrace) from [<c010c2a4>] (show_stack+0x10/0x14)
 [<c010c2a4>] (show_stack) from [<c047f01c>] (dump_stack+0xb0/0xe4)
 [<c047f01c>] (dump_stack) from [<c010e7cc>] (handle_IPI+0x2c4/0x360)
 [<c010e7cc>] (handle_IPI) from [<c0101574>] (gic_handle_irq+0x84/0x94)
 [<c0101574>] (gic_handle_irq) from [<c07abc78>] (__irq_svc+0x58/0x78)
 Exception stack(0xc0c01f58 to 0xc0c01fa0)
 1f40:                                                       c0108318 00000000
 1f60: 00000000 00000000 c0c02a34 00000000 00000000 c0cbe5f8 c0c029cc c0cbe5f8
 1f80: c0b71a38 c0cbd3a9 00000000 c0c01fa8 c0108318 c010831c 60000013 ffffffff
 [<c07abc78>] (__irq_svc) from [<c010831c>] (arch_cpu_idle+0x20/0x3c)
 [<c010831c>] (arch_cpu_idle) from [<c0184c58>] (cpu_startup_entry+0x30c/0x3f0)
 [<c0184c58>] (cpu_startup_entry) from [<c0b00c04>] (start_kernel+0x33c/0x3b4)
 [<c0b00c04>] (start_kernel) from [<8000807c>] (0x8000807c)


-- 
regards,
-grygorii
