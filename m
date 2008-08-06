From: Indan Zupancic <indan@nul.nu>
Subject: Re: Realtek 8111C transmit timed out
Date: Wed, 6 Aug 2008 14:57:05 +0000 (UTC)
Message-ID: <loom.20080806T144054-201@post.gmane.org>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com> <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com> <20080805214250.GA23226@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:34580 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792AbYHFPAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 11:00:11 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KQkUc-000273-CK
	for netdev@vger.kernel.org; Wed, 06 Aug 2008 15:00:02 +0000
Received: from 84-245-32-19.dsl.cambrium.nl ([84.245.32.19])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 15:00:02 +0000
Received: from indan by 84-245-32-19.dsl.cambrium.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 15:00:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu <at> fr.zoreil.com> writes:
> 
> (please Cc: the maintainer)
> 
> John P Poet <jppoet <at> gmail.com> :
> [...]
> > I just tried applying ALL the patches found here:
> > 
> > http://userweb.kernel.org/~romieu/r8169/2.6.27-rc1/20080803.tar.bz2
> > 
> > against 2.6.26.1.  Worked for a while, I then I got:
> 
> Try to add 0002-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch
> from http://userweb.kernel.org/~romieu/r8169/2.6.26/20080717/
> 
> It is in 2.6.27-rc1 as 77332894c21165404496c56763d7df6c15c4bb09.
> 

I'm running a git version just before 2.6.27-rc2 and while the card 
worked fine in 2.6.26, after a resume from suspend to ram I now get:

[ 8367.073701] r8169 0000:01:00.0: restoring config space at offset 0x1 
(was 0x100007, writing 0x100407)
[ 8367.073863] sd 2:0:0:0: [sda] Starting disk
[ 8367.077786] r8169: eth0: link up
[ 8367.265653] ata4.01: configured for UDMA/100
[ 8371.953804] ata3.00: configured for UDMA/133
[ 8371.964803] sd 2:0:0:0: [sda] 390721968 512-byte hardware sectors (200050 MB)
[ 8371.964833] sd 2:0:0:0: [sda] Write Protect is off
[ 8371.964836] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[ 8371.964883] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled,
doesn't support DPO or FUA
[ 8371.975538] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[ 8371.975545] pci 0000:00:02.0: setting latency timer to 64
[ 8371.977770] PM: Finishing wakeup.
[ 8371.977772] Restarting tasks ... done.
[ 8397.700577] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
[ 8397.700590] ------------[ cut here ]------------
[ 8397.700592] WARNING: at
/home/indan/src/git/linux-2.6/net/sched/sch_generic.c:219 
dev_watchdog+0xfa/0x14a()
[ 8397.700594] Modules linked in: i915 drm
[ 8397.700600] Pid: 0, comm: swapper Not tainted 2.6.27-rc1 #8
[ 8397.700602] 
[ 8397.700602] Call Trace:
[ 8397.700604]  <IRQ>  [<ffffffff80235512>] warn_on_slowpath+0x51/0x77
[ 8397.700612]  [<ffffffff80236043>] printk+0x4e/0x56
[ 8397.700615]  [<ffffffff804cda7d>] _spin_lock_irqsave+0x18/0x3a
[ 8397.700619]  [<ffffffff8023dd61>] lock_timer_base+0x26/0x4c
[ 8397.700622]  [<ffffffff804cdd80>] _spin_unlock_irqrestore+0x2d/0x39
[ 8397.700625]  [<ffffffff8023deee>] __mod_timer+0xbb/0xcd
[ 8397.700628]  [<ffffffff8022869a>] calc_delta_fair+0x1a/0x34
[ 8397.700632]  [<ffffffff8024448a>] queue_delayed_work_on+0xaa/0xba
[ 8397.700635]  [<ffffffff8047d14c>] dev_watchdog+0x0/0x14a
[ 8397.700637]  [<ffffffff8047d246>] dev_watchdog+0xfa/0x14a
[ 8397.700641]  [<ffffffff8024916e>] hrtimer_hres_active+0x1a/0x30
[ 8397.700643]  [<ffffffff8023d806>] run_timer_softirq+0x16e/0x1e9
[ 8397.700647]  [<ffffffff8024c478>] getnstimeofday+0x33/0x6e
[ 8397.700651]  [<ffffffff80239e88>] __do_softirq+0x60/0xab
[ 8397.700654]  [<ffffffff8020c73c>] call_softirq+0x1c/0x28
[ 8397.700657]  [<ffffffff8020e981>] do_softirq+0x2c/0x6b
[ 8397.700660]  [<ffffffff80239d83>] irq_exit+0x36/0x8d
[ 8397.700664]  [<ffffffff8021c014>] smp_apic_timer_interrupt+0x7b/0x86
[ 8397.700667]  [<ffffffff8020c186>] apic_timer_interrupt+0x66/0x70
[ 8397.700668]  <EOI>  [<ffffffff80211af2>] read_tsc+0x0/0x1c
[ 8397.700674]  [<ffffffff80212380>] mwait_idle+0x35/0x38
[ 8397.700677]  [<ffffffff80209e94>] cpu_idle+0x76/0xbc
[ 8397.700679] 
[ 8397.700680] ---[ end trace 8c87f3ce26ef3799 ]---
[ 8397.726489] r8169: eth0: link up
[ 8409.700338] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
[ 8409.704926] r8169: eth0: link up
[ 8421.700095] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
[ 8421.727525] r8169: eth0: link up
[ 8433.699859] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
[ 8433.704200] r8169: eth0: link up

Earlier in boot I have:

[    0.205570] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    0.205622] r8169 0000:01:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    0.205678] r8169 0000:01:00.0: setting latency timer to 64
[    0.206002] eth0: RTL8101e at 0xffffc2000002a000, 00:19:66:5c:94:a7, XID
34200000 IRQ 221

Greetings,

Indan


