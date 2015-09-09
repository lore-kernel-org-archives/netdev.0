From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Wed, 09 Sep 2015 17:10:33 +0100
Message-ID: <55F059F9.3080200@arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com> <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	rafael.j.wysocki@intel.com, Suravee.Suthikulpanit@amd.com,
	Catalin.Marinas@arm.com, grant.likely@linaro.org
To: Jeremy Linton <jeremy.linton@arm.com>,
	linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:58833 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808AbbIIQKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 12:10:36 -0400
In-Reply-To: <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy,

On 12/08/15 23:06, Jeremy Linton wrote:
> Add ACPI bindings for the smsc911x driver. Convert the DT specific calls
> to nonspecific device* calls, This allows the driver to work
> with both ACPI and DT configurations. Ethernet should now work when using
> ACPI on ARM Juno.
> 
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
> ---
>  drivers/net/ethernet/smsc/smsc911x.c | 48 +++++++++++++++++-------------------
>  1 file changed, 22 insertions(+), 26 deletions(-)

FWIW, mainline booting with this patch on Juno r1 with ACPI enabled
dies a horrible death:

[...]
ARMH9118:00 supply vdd33a not found, using dummy regulator
ARMH9118:00 supply vddvario not found, using dummy regulator
random: nonblocking pool is initialized
irq 192: nobody cared (try booting with the "irqpoll" option)
CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.2.0+ #4727
Hardware name: ARM Juno development board (r0) (DT)
Call trace:
[<ffffffc000089ae8>] dump_backtrace+0x0/0x128
[<ffffffc000089c20>] show_stack+0x10/0x1c
[<ffffffc00030cdf4>] dump_stack+0x8c/0xd0
[<ffffffc0000f4120>] __report_bad_irq+0x34/0xe0
[<ffffffc0000f44b4>] note_interrupt+0x21c/0x2cc
[<ffffffc0000f1ca4>] handle_irq_event_percpu+0xd0/0x13c
[<ffffffc0000f1d5c>] handle_irq_event+0x4c/0x80
[<ffffffc0000f4eb4>] handle_fasteoi_irq+0xb0/0x188
[<ffffffc0000f125c>] generic_handle_irq+0x30/0x4c
[<ffffffc0000f1580>] __handle_domain_irq+0x5c/0xac
[<ffffffc0000824dc>] gic_handle_irq+0x4c/0x9c
Exception stack(0xffffffc97686f760 to 0xffffffc97686f880)
f760: ffffffc97686c000 ffffffc000932000 ffffffc97686f8b0 ffffffc0000b718c
f780: 0000000040000145 000000000010124c 0000000000000000 ffffffc0009a5800
f7a0: ffffffc0009a5800 ffffffc00053ad40 0000000000000020 000000000ccccccd
f7c0: 002de54480000000 0000000000000020 0000000000000004 ffffffc00064dd8b
f7e0: 0000000000000000 0000000000000005 ffffffc00064ddb0 0000000000000000
f800: fffffffffffffefe 000000000000000e 0000000000000007 0000000000000001
f820: 000000000000000e ffffffc97686c000 ffffffc000932000 ffffffc000915af8
f840: ffffffc97686f8b0 ffffff8000001000 0000000000000040 ffffffc0007df000
f860: 00000000ffff8b1d 0000000000000040 0000000000000202 ffffffc97686f8b0
[<ffffffc0000855a4>] el1_irq+0x64/0xd8
[<ffffffc0000b7538>] irq_exit+0x80/0xd8
[<ffffffc0000f1584>] __handle_domain_irq+0x60/0xac
[<ffffffc0000824dc>] gic_handle_irq+0x4c/0x9c
Exception stack(0xffffffc97686f990 to 0xffffffc97686fab0)
f980:                                   ffffffc976822200 ffffffc976051b80
f9a0: ffffffc97686fae0 ffffffc000639ca8 0000000080000045 ffffffc000385ec0
f9c0: ffffffc9768222a4 0000000000000040 0000000000000005 0000000000000000
f9e0: 0000000000000084 ffffffffffffffff 0000000000000000 ffffffc976400920
fa00: ffffffc976400948 0000000000000000 0000000000000760 00000000000000ae
fa20: 0000000000000030 0000000000000000 0ffffffffffffffe ffffffffffffffff
fa40: 0000000000000e7f 000000000000000c 000000000000073f ffffffc976822200
fa60: ffffffc976051b80 00000000000000c0 0000000000000000 ffffffc9768222a4
fa80: 0000000000000040 ffffffc976029000 0000000000000084 0000000000000040
faa0: ffffffc0006af168 ffffffc97686fae0
[<ffffffc0000855a4>] el1_irq+0x64/0xd8
[<ffffffc0000f36b0>] __setup_irq+0x27c/0x4e8
[<ffffffc0000f3a7c>] request_threaded_irq+0xc4/0x16c
[<ffffffc0004a40fc>] smsc911x_drv_probe+0x730/0xff4
[<ffffffc0004082ac>] platform_drv_probe+0x48/0xb8
[<ffffffc00040678c>] driver_probe_device+0x1e8/0x2e0
[<ffffffc00040691c>] __driver_attach+0x98/0xa0
[<ffffffc0004049b4>] bus_for_each_dev+0x54/0x98
[<ffffffc0004061f8>] driver_attach+0x1c/0x28
[<ffffffc000405e34>] bus_add_driver+0x1c0/0x228
[<ffffffc0004071ac>] driver_register+0x64/0x108
[<ffffffc0004081e0>] __platform_driver_register+0x5c/0x68
[<ffffffc0008c957c>] smsc911x_init_module+0x14/0x20
[<ffffffc0000828c4>] do_one_initcall+0x88/0x1a4
[<ffffffc0008a6ac4>] kernel_init_freeable+0x154/0x1f8
[<ffffffc000634308>] kernel_init+0xc/0xd8
handlers:
[<ffffffc0004a2518>] smsc911x_irqhandler
Disabling IRQ #192
libphy: smsc911x-mdio: probed
smsc911x ARMH9118:00 eth0: attached PHY driver [Generic PHY] (mii_bus:phy_addr=ARMH9118:00-ffff:01, irq=-1)
VFIO - User Level meta-driver version: 0.3
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci-pci: EHCI PCI platform driver
ehci-platform: EHCI generic platform driver
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci-pci: OHCI PCI platform driver
ohci-platform: OHCI generic platform driver
usbcore: registered new interface driver usb-storage
mousedev: PS/2 mouse device common for all mice
rtc-efi rtc-efi: rtc core: registered rtc-efi as rtc0
sdhci: Secure Digital Host Controller Interface driver
sdhci: Copyright(c) Pierre Ossman
sdhci-pltfm: SDHCI platform and OF driver helper
ledtrig-cpu: registered to indicate activity on CPUs
usbcore: registered new interface driver usbhid
usbhid: USB HID core driver
NET: Registered protocol family 17
9pnet: Installing 9P2000 support
Key type dns_resolver registered
registered taskstats version 1
rtc-efi rtc-efi: setting system clock to 2015-08-31 18:48:50 UTC (1441046930)
Waiting for root device /dev/sda1...
Bad mode in Synchronous Abort handler detected, code 0x86000004 -- IABT (current EL)
CPU: 0 PID: 435 Comm: kworker/0:1 Not tainted 4.2.0+ #4727
Hardware name: ARM Juno development board (r0) (DT)
Workqueue: events_power_efficient phy_state_machine
task: ffffffc976bf7080 ti: ffffffc976098000 task.ti: ffffffc976098000
PC is at 0x69c80203010820b0
LR is at phy_state_machine+0x38/0x3d8
pc : [<69c80203010820b0>] lr : [<ffffffc00045df10>] pstate: 60000045
sp : ffffffc97609bd60
x29: ffffffc97609bd60 x28: 0000000000000000 
x27: ffffffc000932000 x26: 0000000000000000 
x25: 0000000000000000 x24: 0000000000000000 
x23: ffffffc97fee2480 x22: ffffffc975c93368 
x21: ffffffc975c933d0 x20: ffffffc975c93000 
x19: ffffffc975c93368 x18: 0000000000000000 
x17: 0000000000000001 x16: 0000000000000011 
x15: ffffffffffffffff x14: ffffff0000000000 
x13: ffffffffffffffff x12: 0000000000000008 
x11: 0000000000000003 x10: 0000000000000760 
x9 : ffffffc97609bd30 x8 : ffffffc976bf7840 
x7 : fefdff366f6e6e6b x6 : 0033428f00000000 
x5 : 0000000000000000 x4 : 0000000000800000 
x3 : ffffffc97fee2480 x2 : 0000000000000000 
x1 : 69c80203010820b0 x0 : ffffffc975c93000 

Internal error: Oops - bad mode: 0 [#1] PREEMPT SMP
Modules linked in:
CPU: 0 PID: 435 Comm: kworker/0:1 Not tainted 4.2.0+ #4727
Hardware name: ARM Juno development board (r0) (DT)
Workqueue: events_power_efficient phy_state_machine
task: ffffffc976bf7080 ti: ffffffc976098000 task.ti: ffffffc976098000
PC is at 0x69c80203010820b0
LR is at phy_state_machine+0x38/0x3d8
pc : [<69c80203010820b0>] lr : [<ffffffc00045df10>] pstate: 60000045
sp : ffffffc97609bd60
x29: ffffffc97609bd60 x28: 0000000000000000 
x27: ffffffc000932000 x26: 0000000000000000 
x25: 0000000000000000 x24: 0000000000000000 
x23: ffffffc97fee2480 x22: ffffffc975c93368 
x21: ffffffc975c933d0 x20: ffffffc975c93000 
x19: ffffffc975c93368 x18: 0000000000000000 
x17: 0000000000000001 x16: 0000000000000011 
x15: ffffffffffffffff x14: ffffff0000000000 
x13: ffffffffffffffff x12: 0000000000000008 
x11: 0000000000000003 x10: 0000000000000760 
x9 : ffffffc97609bd30 x8 : ffffffc976bf7840 
x7 : fefdff366f6e6e6b x6 : 0033428f00000000 
x5 : 0000000000000000 x4 : 0000000000800000 
x3 : ffffffc97fee2480 x2 : 0000000000000000 
x1 : 69c80203010820b0 x0 : ffffffc975c93000 

Process kworker/0:1 (pid: 435, stack limit = 0xffffffc976098020)
Stack: (0xffffffc97609bd60 to 0xffffffc97609c000)
bd60: ffffffc97609bd90 ffffffc0000c8ce8 ffffffc97fee7400 0000000000000000
bd80: ffffffc976349180 ffffffc975c93368 ffffffc97609bdd0 ffffffc0000c8fec
bda0: ffffffc976349180 ffffffc9763491b0 ffffffc97fee2498 ffffffc97fee2480
bdc0: ffffffc976098000 ffffffc00099f35c ffffffc97609be30 ffffffc0000ce914
bde0: ffffffc976344ec0 ffffffc0009a7070 ffffffc0007df5f0 ffffffc976349180
be00: ffffffc0000c8eb8 0000000000000000 0000000000000000 0000000000000000
be20: 0000000000000000 0000000000000000 0000000000000000 ffffffc000085c10
be40: ffffffc0000ce834 ffffffc976344ec0 0000000000000000 0000000000000000
be60: 0000000000000000 ffffffc0000d6ae0 ffffffc0000ce834 0000000000000000
be80: 0000000000000000 ffffffc976349180 0000000000000000 0000000000000000
bea0: ffffffc97609bea0 ffffffc97609bea0 0000000000000000 ffffffc000000000
bec0: ffffffc97609bec0 ffffffc97609bec0 0000000000000000 0000000000000000
bee0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf00: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf40: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf60: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bfa0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bfc0: 0000000000000000 0000000000000000 0000000000000000 0000000000000005
bfe0: 0000000000000000 0000000000000000 380d1498069cb864 936a64483f903586
Call trace:
[<69c80203010820b0>] 0x69c80203010820b0
[<ffffffc0000c8ce4>] process_one_work+0x130/0x304
[<ffffffc0000c8fe8>] worker_thread+0x130/0x438
[<ffffffc0000ce910>] kthread+0xdc/0xf4
Code: bad PC value
---[ end trace 876730031d2f86c1 ]---
Unable to handle kernel paging request at virtual address ffffffffffffffd8
pgd = ffffffc0009d8000
[ffffffffffffffd8] *pgd=0000000000000000, *pud=0000000000000000
Internal error: Oops: 96000005 [#2] PREEMPT SMP
Modules linked in:
CPU: 0 PID: 435 Comm: kworker/0:1 Tainted: G      D         4.2.0+ #4727
Hardware name: ARM Juno development board (r0) (DT)
task: ffffffc976bf7080 ti: ffffffc976098000 task.ti: ffffffc976098000
PC is at kthread_data+0x4/0xc
LR is at wq_worker_sleeping+0x10/0xc4
pc : [<ffffffc0000ceed8>] lr : [<ffffffc0000c9acc>] pstate: 600001c5
sp : ffffffc97609ba40
x29: ffffffc97609ba40 x28: 0000000000000000 
x27: ffffffc9768d0000 x26: 0000000000000000 
x25: 0000000000000000 x24: ffffffc976bf74d8 
x23: ffffffc000636478 x22: ffffffc976bf7080 
x21: ffffffc97fee2c00 x20: ffffffc000932000 
x19: ffffffc000919000 x18: 000000000000000e 
x17: 0000000000000001 x16: 0000000000000007 
x15: 000000000000000e x14: 0000000000000013 
x13: 000000000000001a x12: ffffffc97609ba20 
x11: 0000000000000028 x10: 0000000000000000 
x9 : 0000000000000013 x8 : 0000000000000000 
x7 : 0000000000000044 x6 : 0000000000000001 
x5 : 0000000000000400 x4 : ffffffc97fee3530 
x3 : 0000000000000000 x2 : ffffffc0009a7838 
x1 : 0000000000000000 x0 : 0000000000000000 

Process kworker/0:1 (pid: 435, stack limit = 0xffffffc976098020)
Stack: (0xffffffc97609ba40 to 0xffffffc97609c000)
ba40: ffffffc97609ba60 ffffffc0006362b8 ffffffc97609ba60 0000000000000000
ba60: ffffffc97609bab0 ffffffc000636478 ffffffc976098000 ffffffc97609b7c0
ba80: ffffffc97609bb40 ffffffc976bf73c8 0000000000000001 ffffffc000932000
baa0: 0000000000000000 0000000000000000 ffffffc97609bad0 ffffffc0000b651c
bac0: ffffffc976bf7080 ffffffc0000b64dc ffffffc97609bb50 ffffffc000089dd0
bae0: ffffffc0009a4000 0000000000000000 ffffffc0007db528 ffffffc97609bc40
bb00: ffffffc976098000 ffffffc976bf7080 0000000000000000 0000000000000000
bb20: ffffffc000932000 0000000000000000 ffffffc0009a4000 ffffffc000942858
bb40: ffffffc97609bb40 ffffffc97609bb40 ffffffc97609bb90 ffffffc000089eac
bb60: ffffffc97609bc40 69c80203010820b0 ffffffc97609bd60 69c80203010820b0
bb80: 0000000060000045 0000000000000021 ffffffc97609bba0 ffffffc00008a10c
bba0: ffffffc97609bd60 ffffffc00045df10 ffffffc975c93368 ffffffc975c93000
bbc0: 0000000000000004 0000000000030001 69c80203010820b0 ffffffc0000d5c9c
bbe0: ffffffc97609bc50 ffffffc0000d5de4 ffffffc97ff2d480 ffffffc97ff2bc08
bc00: 0000000000000000 ffffffc976842400 0000000000000005 0000000000000005
bc20: ffffffc000932000 ffffffc976098000 ffffffc97609bc80 ffffffc000100718
bc40: ffffffc975c93000 69c80203010820b0 0000000000000000 ffffffc97fee2480
bc60: 0000000000800000 0000000000000000 0033428f00000000 fefdff366f6e6e6b
bc80: ffffffc976bf7840 ffffffc97609bd30 0000000000000760 0000000000000003
bca0: 0000000000000008 ffffffffffffffff ffffff0000000000 ffffffffffffffff
bcc0: 0000000000000011 0000000000000001 0000000000000000 ffffffc975c93368
bce0: ffffffc975c93000 ffffffc975c933d0 ffffffc975c93368 ffffffc97fee2480
bd00: 0000000000000000 0000000000000000 0000000000000000 ffffffc000932000
bd20: 0000000000000000 ffffffc97609bd60 ffffffc00045df10 ffffffc97609bd60
bd40: 69c80203010820b0 0000000060000045 ffffffc975c93368 ffffffc9768d0000
bd60: ffffffc97609bd90 ffffffc0000c8ce8 ffffffc97fee7400 0000000000000000
bd80: ffffffc976349180 ffffffc975c93368 ffffffc97609bdd0 ffffffc0000c8fec
bda0: ffffffc976349180 ffffffc9763491b0 ffffffc97fee2498 ffffffc97fee2480
bdc0: ffffffc976098000 ffffffc00099f35c ffffffc97609be30 ffffffc0000ce914
bde0: ffffffc976344ec0 ffffffc0009a7070 ffffffc0007df5f0 ffffffc976349180
be00: ffffffc0000c8eb8 0000000000000000 0000000000000000 0000000000000000
be20: 0000000000000000 0000000000000000 0000000000000000 ffffffc000085c10
be40: ffffffc0000ce834 ffffffc976344ec0 0000000000000000 0000000000000000
be60: 0000000000000000 ffffffc0000d6ae0 ffffffc0000ce834 0000000000000000
be80: 0000000000000000 ffffffc976349180 0000000000000000 0000000000000000
bea0: ffffffc97609bea0 ffffffc97609bea0 0000000000000001 ffffffc000010001
bec0: ffffffc97609bec0 ffffffc97609bec0 0000000000000000 0000000000000000
bee0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf00: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf40: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf60: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bf80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bfa0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
bfc0: 0000000000000000 0000000000000000 0000000000000000 0000000000000005
bfe0: 0000000000000000 0000000000000000 380d1498069cb864 936a64483f903586
Call trace:
[<ffffffc0000ceed8>] kthread_data+0x4/0xc
[<ffffffc0006362b4>] __schedule+0x4c8/0x64c
[<ffffffc000636474>] schedule+0x3c/0xac
[<ffffffc0000b6518>] do_exit+0x618/0x924
[<ffffffc000089dcc>] die+0x1a0/0x1bc
[<ffffffc000089ea8>] arm64_notify_die+0x18/0x58
[<ffffffc00008a108>] bad_mode+0x88/0x98
[<ffffffc00045df0c>] phy_state_machine+0x34/0x3d8
[<ffffffc0000c8ce4>] process_one_work+0x130/0x304
[<ffffffc0000c8fe8>] worker_thread+0x130/0x438
[<ffffffc0000ce910>] kthread+0xdc/0xf4
Code: 97ffff86 a8c17bfd d65f03c0 f941fc00 (f85d8000) 

Disabling the driver leads to a booting system again. Booting
with DT seems OK.

I can see two issues here: we have a screaming interrupt, and
we seem to corrupt some workqueue.

How did you get this to work? Firmware release?

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
