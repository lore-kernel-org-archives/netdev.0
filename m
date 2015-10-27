From: "Simon Wood" <simon@mungewell.org>
Subject: [Regression/Oops] nsc-ircc: 4.3.0rc6/rc7 No backlight on Thinkpad
 T60P
Date: Tue, 27 Oct 2015 09:07:57 -0600
Message-ID: <668ab5528ec8345f98e09e2efb074105.squirrel@mungewell.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20151027090757_40520"
Cc: "Samuel Ortiz" <samuel@sortiz.org>, netdev@vger.kernel.org,
	simon@mungewell.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_20151027090757_40520
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

Tried the latest kernel and have the issue where the LCD backlight does
not light (ie dark screen) after the kernel has booted.

It appears that there is a 'oops' with the nsc-ircc driver, and I assume
that this is the root of the problem. 4.3.0rc6 and rc7 are bad, rc2 seems
OK.

--
Oct 23 07:35:08 retrobox kernel: [   23.640044] nsc-ircc, driver loaded
(Dag Brattli)
Oct 23 07:35:08 retrobox kernel: [   23.640730] BUG: unable to handle
kernel NULL pointer dereference at 00000130
Oct 23 07:35:08 retrobox kernel: [   23.641422] IP: [<c1017802>]
arch_dma_alloc_attrs+0x12/0x70
Oct 23 07:35:08 retrobox kernel: [   23.641953] *pdpt = 00000000363cb001
*pde = 0000000000000000
Oct 23 07:35:08 retrobox kernel: [   23.642517] Oops: 0000 [#1] SMP
Oct 23 07:35:08 retrobox kernel: [   23.642849] Modules linked in:
nsc_ircc(+) snd_seq_device snd_timer snd floppy(+) irda soundcore
crc_ccitt shpchp 8250_fintek video mac_hid parport_pc ppdev lp parport
autofs4 e1000e psmouse ptp pata_acpi pps_core
Oct 23 07:35:08 retrobox kernel: [   23.644011] CPU: 0 PID: 267 Comm:
systemd-udevd Not tainted 4.3.0-rc6-g920+ #10
Oct 23 07:35:08 retrobox kernel: [   23.644011] Hardware name: LENOVO
2008VPX/2008VPX, BIOS 79ETE5WW (2.25 ) 08/27/2009
Oct 23 07:35:08 retrobox kernel: [   23.644011] task: f37c71c0 ti:
f63cc000 task.ti: f63cc000
Oct 23 07:35:08 retrobox kernel: [   23.644011] EIP: 0060:[<c1017802>]
EFLAGS: 00010202 CPU: 0
Oct 23 07:35:08 retrobox kernel: [   23.644011] EIP is at
arch_dma_alloc_attrs+0x12/0x70
Oct 23 07:35:08 retrobox kernel: [   23.644011] EAX: f63cdd08 EBX:
00000000 ECX: 000080d0 EDX: f63cdd0c
Oct 23 07:35:08 retrobox kernel: [   23.644011] ESI: f6afe66c EDI:
c1a305c0 EBP: f63cdd00 ESP: f63cdcfc
Oct 23 07:35:08 retrobox kernel: [   23.644011]  DS: 007b ES: 007b FS:
00d8 GS: 00e0 SS: 0068
Oct 23 07:35:08 retrobox kernel: [   23.644011] CR0: 80050033 CR2:
00000130 CR3: 36945200 CR4: 000006f0
Oct 23 07:35:08 retrobox kernel: [   23.644011] Stack:
Oct 23 07:35:08 retrobox kernel: [   23.644011]  00003830 f63cdd20
f8532a11 00000000 000080d0 f63cdd68 f6afe000 f6afe500
Oct 23 07:35:08 retrobox kernel: [   23.644011]  f6afe598 f63cdd68
f85371c9 c19ce2e2 f85340bc 00000000 f63cddc8 f63cdd58
Oct 23 07:35:08 retrobox kernel: [   23.644011]  c10b9be1 00000000
00000006 00000000 00000000 f8533267 f63cdd6c f63cdd60
Oct 23 07:35:08 retrobox kernel: [   23.644011] Call Trace:
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f8532a11>]
dma_alloc_attrs.constprop.18+0x4b/0x71 [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f85371c9>]
nsc_ircc_open+0x1c9/0x42c [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c10b9be1>] ?
vprintk_default+0x41/0x60
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f85375e4>]
nsc_ircc_init+0x1b8/0xbd4 [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1002136>]
do_one_initcall+0xc6/0x200
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f853742c>] ?
nsc_ircc_open+0x42c/0x42c [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f853742c>] ?
nsc_ircc_open+0x42c/0x42c [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1002136>] ?
do_one_initcall+0xc6/0x200
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f853742c>] ?
nsc_ircc_open+0x42c/0x42c [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c171d8db>] ?
preempt_schedule_common+0x1b/0x40
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c171d925>] ?
_cond_resched+0x25/0x30
--

Cheers,
Simon.
------=_20151027090757_40520
Content-Type: text/plain; name="thinkpad-t60p-no-lcd-backlight.txt"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment;
 filename="thinkpad-t60p-no-lcd-backlight.txt"

syslog-4.3.0-rc6-20151022-bad
--
Oct 23 07:35:08 retrobox kernel: [   23.109988] ACPI: Video Device [VID1] (multi-head: yes  rom: no  post: no)
Oct 23 07:35:08 retrobox kernel: [   23.115543] acpi device:06: registered as cooling_device0
Oct 23 07:35:08 retrobox kernel: [   23.115669] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:05/LNXVIDEO:01/input/input7
Oct 23 07:35:08 retrobox kernel: [   23.216754] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
Oct 23 07:35:08 retrobox kernel: [   23.305523] NET: Registered protocol family 23
Oct 23 07:35:08 retrobox kernel: [   23.637255] nsc-ircc 00:05: [io  0x02f8-0x02ff]
Oct 23 07:35:08 retrobox kernel: [   23.637369] nsc-ircc 00:05: [irq 3]
Oct 23 07:35:08 retrobox kernel: [   23.637373] nsc-ircc 00:05: [dma 1]
Oct 23 07:35:08 retrobox kernel: [   23.637840] nsc-ircc 00:05: activated
Oct 23 07:35:08 retrobox kernel: [   23.639969] nsc-ircc, chip->init
Oct 23 07:35:08 retrobox kernel: [   23.639983] nsc-ircc, Found chip at base=0x164e
Oct 23 07:35:08 retrobox kernel: [   23.640044] nsc-ircc, driver loaded (Dag Brattli)
Oct 23 07:35:08 retrobox kernel: [   23.640730] BUG: unable to handle kernel NULL pointer dereference at 00000130
Oct 23 07:35:08 retrobox kernel: [   23.641422] IP: [<c1017802>] arch_dma_alloc_attrs+0x12/0x70
Oct 23 07:35:08 retrobox kernel: [   23.641953] *pdpt = 00000000363cb001 *pde = 0000000000000000 
Oct 23 07:35:08 retrobox kernel: [   23.642517] Oops: 0000 [#1] SMP 
Oct 23 07:35:08 retrobox kernel: [   23.642849] Modules linked in: nsc_ircc(+) snd_seq_device snd_timer snd floppy(+) irda soundcore crc_ccitt shpchp 8250_fintek video mac_hid parport_pc ppdev lp parport autofs4 e1000e psmouse ptp pata_acpi pps_core
Oct 23 07:35:08 retrobox kernel: [   23.644011] CPU: 0 PID: 267 Comm: systemd-udevd Not tainted 4.3.0-rc6-g920+ #10
Oct 23 07:35:08 retrobox kernel: [   23.644011] Hardware name: LENOVO 2008VPX/2008VPX, BIOS 79ETE5WW (2.25 ) 08/27/2009
Oct 23 07:35:08 retrobox kernel: [   23.644011] task: f37c71c0 ti: f63cc000 task.ti: f63cc000
Oct 23 07:35:08 retrobox kernel: [   23.644011] EIP: 0060:[<c1017802>] EFLAGS: 00010202 CPU: 0
Oct 23 07:35:08 retrobox kernel: [   23.644011] EIP is at arch_dma_alloc_attrs+0x12/0x70
Oct 23 07:35:08 retrobox kernel: [   23.644011] EAX: f63cdd08 EBX: 00000000 ECX: 000080d0 EDX: f63cdd0c
Oct 23 07:35:08 retrobox kernel: [   23.644011] ESI: f6afe66c EDI: c1a305c0 EBP: f63cdd00 ESP: f63cdcfc
Oct 23 07:35:08 retrobox kernel: [   23.644011]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Oct 23 07:35:08 retrobox kernel: [   23.644011] CR0: 80050033 CR2: 00000130 CR3: 36945200 CR4: 000006f0
Oct 23 07:35:08 retrobox kernel: [   23.644011] Stack:
Oct 23 07:35:08 retrobox kernel: [   23.644011]  00003830 f63cdd20 f8532a11 00000000 000080d0 f63cdd68 f6afe000 f6afe500
Oct 23 07:35:08 retrobox kernel: [   23.644011]  f6afe598 f63cdd68 f85371c9 c19ce2e2 f85340bc 00000000 f63cddc8 f63cdd58
Oct 23 07:35:08 retrobox kernel: [   23.644011]  c10b9be1 00000000 00000006 00000000 00000000 f8533267 f63cdd6c f63cdd60
Oct 23 07:35:08 retrobox kernel: [   23.644011] Call Trace:
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f8532a11>] dma_alloc_attrs.constprop.18+0x4b/0x71 [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f85371c9>] nsc_ircc_open+0x1c9/0x42c [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c10b9be1>] ? vprintk_default+0x41/0x60
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f85375e4>] nsc_ircc_init+0x1b8/0xbd4 [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1002136>] do_one_initcall+0xc6/0x200
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f853742c>] ? nsc_ircc_open+0x42c/0x42c [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f853742c>] ? nsc_ircc_open+0x42c/0x42c [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1002136>] ? do_one_initcall+0xc6/0x200
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f853742c>] ? nsc_ircc_open+0x42c/0x42c [nsc_ircc]
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c171d8db>] ? preempt_schedule_common+0x1b/0x40
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c171d925>] ? _cond_resched+0x25/0x30
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c11a5eb5>] ? kmem_cache_alloc_trace+0x165/0x1d0
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1156945>] ? do_init_module+0x21/0x1b5
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1156945>] ? do_init_module+0x21/0x1b5
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1156974>] do_init_module+0x50/0x1b5
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c10e5696>] load_module+0x1c96/0x24c0
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c10e608d>] SyS_finit_module+0x7d/0xc0
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1172573>] ? vm_mmap_pgoff+0x83/0xa0
Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<c1720d17>] sysenter_do_call+0x12/0x12
Oct 23 07:35:08 retrobox kernel: [   23.644011] Code: 00 83 c4 10 31 c0 5b 5e 5f 5d c3 66 90 66 90 66 90 66 90 66 90 66 90 66 90 55 89 e5 53 3e 8d 74 26 00 8b 0a 83 e1 f8 89 0a 8b 18 <8b> 9b 30 01 00 00 83 eb 01 81 fb fe ff ff 00 77 03 83 c9 01 89
Oct 23 07:35:08 retrobox kernel: [   23.644011] EIP: [<c1017802>] arch_dma_alloc_attrs+0x12/0x70 SS:ESP 0068:f63cdcfc
Oct 23 07:35:08 retrobox kernel: [   23.644011] CR2: 0000000000000130
Oct 23 07:35:08 retrobox kernel: [   23.667541] ---[ end trace f8d3793989516980 ]---
Oct 23 07:35:08 retrobox kernel: [   23.737711] intel_rng: FWH not detected
Oct 23 07:35:08 retrobox kernel: [   24.088456] ACPI Warning: SystemIO range 0x0000000000001028-0x000000000000102F conflicts with OpRegion 0x0000000000001000-0x000000000000107F (\_SB_.PCI0.LPC_.PMIO) (20150818/utaddress-254)
Oct 23 07:35:08 retrobox kernel: [   24.090114] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
Oct 23 07:35:08 retrobox kernel: [   24.101011] ACPI Warning: SystemIO range 0x00000000000011B0-0x00000000000011BF conflicts with OpRegion 0x0000000000001180-0x00000000000011BF (\_SB_.PCI0.LPC_.LPIO) (20150818/utaddress-254)
Oct 23 07:35:08 retrobox kernel: [   24.102573] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
Oct 23 07:35:08 retrobox kernel: [   24.103490] ACPI Warning: SystemIO range 0x0000000000001180-0x00000000000011AF conflicts with OpRegion 0x0000000000001180-0x00000000000011BF (\_SB_.PCI0.LPC_.LPIO) (20150818/utaddress-254)
Oct 23 07:35:08 retrobox kernel: [   24.105063] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
Oct 23 07:35:08 retrobox kernel: [   24.105977] lpc_ich: Resource conflict(s) found affecting gpio_ich
Oct 23 07:35:08 retrobox kernel: [   24.240700] pci 0000:00:1e.0: enabling device (0005 -> 0007)
Oct 23 07:35:08 retrobox kernel: [   24.241251] yenta_cardbus 0000:15:00.0: CardBus bridge found [17aa:2012]
Oct 23 07:35:08 retrobox kernel: [   24.241877] yenta_cardbus 0000:15:00.0: Using INTVAL to route CSC interrupts to PCI
Oct 23 07:35:08 retrobox kernel: [   24.242567] yenta_cardbus 0000:15:00.0: Routing CardBus interrupts to PCI
--


syslog-4.2.0-20151025-good
--
Oct 26 08:16:53 retrobox kernel: [   22.162185] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
Oct 26 08:16:53 retrobox kernel: [   22.234951] NET: Registered protocol family 23
Oct 26 08:16:53 retrobox kernel: [   22.428734] nsc-ircc 00:05: [io  0x02f8-0x02ff]
Oct 26 08:16:53 retrobox kernel: [   22.428849] nsc-ircc 00:05: [irq 3]
Oct 26 08:16:53 retrobox kernel: [   22.428854] nsc-ircc 00:05: [dma 1]
Oct 26 08:16:53 retrobox kernel: [   22.429280] nsc-ircc 00:05: activated
Oct 26 08:16:53 retrobox kernel: [   22.432575] nsc-ircc, chip->init
Oct 26 08:16:53 retrobox kernel: [   22.432590] nsc-ircc, Found chip at base=0x164e
Oct 26 08:16:53 retrobox kernel: [   22.432630] nsc-ircc, driver loaded (Dag Brattli)
Oct 26 08:16:53 retrobox kernel: [   22.432898] IrDA: Registered device irda0
Oct 26 08:16:53 retrobox kernel: [   22.432900] nsc-ircc, Using dongle: IBM31T1100 or Temic TFDS6000/TFDS6500
Oct 26 08:16:53 retrobox kernel: [   22.683829] intel_rng: FWH not detected
Oct 26 08:16:53 retrobox kernel: [   22.914998] pci 0000:00:1e.0: enabling device (0005 -> 0007)
Oct 26 08:16:53 retrobox kernel: [   22.915032] yenta_cardbus 0000:15:00.0: CardBus bridge found [17aa:2012]
Oct 26 08:16:53 retrobox kernel: [   22.915057] yenta_cardbus 0000:15:00.0: Using INTVAL to route CSC interrupts to PCI
Oct 26 08:16:53 retrobox kernel: [   22.915060] yenta_cardbus 0000:15:00.0: Routing CardBus interrupts to PCI
Oct 26 08:16:53 retrobox kernel: [   22.915067] yenta_cardbus 0000:15:00.0: TI: mfunc 0x01d01002, devctl 0x64
--

------=_20151027090757_40520--
