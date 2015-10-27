From: "Simon Wood" <simon@mungewell.org>
Subject: Re: [Regression/Oops] nsc-ircc: 4.3.0rc6/rc7 No backlight on
 Thinkpad T60P
Date: Tue, 27 Oct 2015 10:52:44 -0600
Message-ID: <d6923436556661aecf881ea41a563fdb.squirrel@mungewell.org>
References: <668ab5528ec8345f98e09e2efb074105.squirrel@mungewell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, "Samuel Ortiz" <samuel@sortiz.org>,
	netdev@vger.kernel.org, simon@mungewell.org
To: =?iso-8859-1?Q?=22Ville_Syrj=E4l=E4=22?=
	<ville.syrjala@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <668ab5528ec8345f98e09e2efb074105.squirrel@mungewell.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Looks like Ville has tracked down a possible problem. Will patch/rebuild
and confirm whether it solves my problem.

https://lkml.org/lkml/2015/10/25/284

Simon.

On Tue, October 27, 2015 9:07 am, Simon Wood wrote:
> Tried the latest kernel and have the issue where the LCD backlight does
> not light (ie dark screen) after the kernel has booted.
>
> It appears that there is a 'oops' with the nsc-ircc driver, and I assume
> that this is the root of the problem. 4.3.0rc6 and rc7 are bad, rc2 seems
> OK.
>
>
> --
> Oct 23 07:35:08 retrobox kernel: [   23.640044] nsc-ircc, driver loaded
> (Dag Brattli)
> Oct 23 07:35:08 retrobox kernel: [   23.640730] BUG: unable to handle
> kernel NULL pointer dereference at 00000130 Oct 23 07:35:08 retrobox
> kernel: [   23.641422] IP: [<c1017802>]
> arch_dma_alloc_attrs+0x12/0x70 Oct 23 07:35:08 retrobox kernel: [
> 23.641953] *pdpt = 00000000363cb001
> *pde = 0000000000000000
> Oct 23 07:35:08 retrobox kernel: [   23.642517] Oops: 0000 [#1] SMP
> Oct 23 07:35:08 retrobox kernel: [   23.642849] Modules linked in:
> nsc_ircc(+) snd_seq_device snd_timer snd floppy(+) irda soundcore crc_ccitt
> shpchp 8250_fintek video mac_hid parport_pc ppdev lp parport autofs4
> e1000e psmouse ptp pata_acpi pps_core Oct 23 07:35:08 retrobox kernel: [
> 23.644011] CPU: 0 PID: 267 Comm:
> systemd-udevd Not tainted 4.3.0-rc6-g920+ #10 Oct 23 07:35:08 retrobox
> kernel: [   23.644011] Hardware name: LENOVO
> 2008VPX/2008VPX, BIOS 79ETE5WW (2.25 ) 08/27/2009
> Oct 23 07:35:08 retrobox kernel: [   23.644011] task: f37c71c0 ti:
> f63cc000 task.ti: f63cc000 Oct 23 07:35:08 retrobox kernel: [   23.644011]
> EIP: 0060:[<c1017802>]
> EFLAGS: 00010202 CPU: 0
> Oct 23 07:35:08 retrobox kernel: [   23.644011] EIP is at
> arch_dma_alloc_attrs+0x12/0x70 Oct 23 07:35:08 retrobox kernel: [
> 23.644011] EAX: f63cdd08 EBX:
> 00000000 ECX: 000080d0 EDX: f63cdd0c
> Oct 23 07:35:08 retrobox kernel: [   23.644011] ESI: f6afe66c EDI:
> c1a305c0 EBP: f63cdd00 ESP: f63cdcfc Oct 23 07:35:08 retrobox kernel: [
> 23.644011]  DS: 007b ES: 007b FS:
> 00d8 GS: 00e0 SS: 0068
> Oct 23 07:35:08 retrobox kernel: [   23.644011] CR0: 80050033 CR2:
> 00000130 CR3: 36945200 CR4: 000006f0
> Oct 23 07:35:08 retrobox kernel: [   23.644011] Stack:
> Oct 23 07:35:08 retrobox kernel: [   23.644011]  00003830 f63cdd20
> f8532a11 00000000 000080d0 f63cdd68 f6afe000 f6afe500 Oct 23 07:35:08
> retrobox kernel: [   23.644011]  f6afe598 f63cdd68 f85371c9 c19ce2e2
> f85340bc 00000000 f63cddc8 f63cdd58 Oct 23 07:35:08 retrobox kernel: [
> 23.644011]  c10b9be1 00000000
> 00000006 00000000 00000000 f8533267 f63cdd6c f63cdd60
> Oct 23 07:35:08 retrobox kernel: [   23.644011] Call Trace:
> Oct 23 07:35:08 retrobox kernel: [   23.644011]  [<f8532a11>]
> dma_alloc_attrs.constprop.18+0x4b/0x71 [nsc_ircc] Oct 23 07:35:08 retrobox
> kernel: [   23.644011]  [<f85371c9>]
> nsc_ircc_open+0x1c9/0x42c [nsc_ircc] Oct 23 07:35:08 retrobox kernel: [
> 23.644011]  [<c10b9be1>] ?
> vprintk_default+0x41/0x60 Oct 23 07:35:08 retrobox kernel: [   23.644011]
> [<f85375e4>]
> nsc_ircc_init+0x1b8/0xbd4 [nsc_ircc] Oct 23 07:35:08 retrobox kernel: [
> 23.644011]  [<c1002136>]
> do_one_initcall+0xc6/0x200 Oct 23 07:35:08 retrobox kernel: [   23.644011]
> [<f853742c>] ?
> nsc_ircc_open+0x42c/0x42c [nsc_ircc] Oct 23 07:35:08 retrobox kernel: [
> 23.644011]  [<f853742c>] ?
> nsc_ircc_open+0x42c/0x42c [nsc_ircc] Oct 23 07:35:08 retrobox kernel: [
> 23.644011]  [<c1002136>] ?
> do_one_initcall+0xc6/0x200 Oct 23 07:35:08 retrobox kernel: [   23.644011]
> [<f853742c>] ?
> nsc_ircc_open+0x42c/0x42c [nsc_ircc] Oct 23 07:35:08 retrobox kernel: [
> 23.644011]  [<c171d8db>] ?
> preempt_schedule_common+0x1b/0x40 Oct 23 07:35:08 retrobox kernel: [
> 23.644011]  [<c171d925>] ?
> _cond_resched+0x25/0x30
> --
>
>
> Cheers,
> Simon.
