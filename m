From: Kyle McMartin <kmcmartin@redhat.com>
Subject: r8169 transmit queue time outs
Date: Thu, 6 May 2010 10:17:15 -0400
Message-ID: <20100506141715.GC4480@ihatethathostname.lab.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752498Ab0EFORX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 10:17:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

Some of our users have been seeing their r8169 cards just up and stop
transmitting packets pretty quickly after boot with recent kernels.

After trying a few things:
 1- Updating the driver to the latest upstream (and -next).
 2- Downgrading the driver to the last known working release version.

Nothing seems to have helped.

I take it from the fact that the last known working driver no longer
works on a newer kernel to mean that something has changed in the core
net code that makes the r8169 driver particularly unhappy?

The WARN_ON getting triggered is:
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:246 dev_watchdog+0xc6/0x12d() (Not
tainted)
Hardware name: VX800
NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Modules linked in: sunrpc ip6_tables cpufreq_ondemand acpi_cpufreq
dm_multipath
uinput snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep snd_seq
snd_seq_device snd_pcm snd_timer i2c_viapro snd soundcore snd_page_alloc
r8169
serio_raw i2c_core mii pata_acpi ata_generic pata_via [last unloaded:
scsi_wait_scan]
Pid: 0, comm: swapper Not tainted 2.6.31.5-127.fc12.i686.PAE #1
Call Trace:
 [<c043db03>] warn_slowpath_common+0x70/0x87
 [<c06ff9d0>] ? dev_watchdog+0xc6/0x12d
 [<c043db58>] warn_slowpath_fmt+0x29/0x2c
 [<c06ff9d0>] dev_watchdog+0xc6/0x12d
 [<c04471bd>] ? mod_timer+0x20/0x27
 [<c0680021>] ? usb_hcd_poll_rh_status+0x126/0x12e
 [<c06ff90a>] ? dev_watchdog+0x0/0x12d
 [<c0446e91>] run_timer_softirq+0x14e/0x1af
 [<c0442daa>] __do_softirq+0xb1/0x157
 [<c0442e86>] do_softirq+0x36/0x41
 [<c0442f78>] irq_exit+0x2e/0x61
 [<c041cf17>] smp_apic_timer_interrupt+0x6d/0x7b
 [<c04099b5>] apic_timer_interrupt+0x31/0x38
 [<c040f34b>] ? mwait_idle+0x67/0x85
 [<c040811f>] cpu_idle+0x96/0xaf
 [<c0765784>] rest_init+0x58/0x5a
 [<c09a78c3>] start_kernel+0x32b/0x330
 [<c09a7081>] i386_start_kernel+0x70/0x77
---[ end trace 8eb83276b856939b ]---  

And the RH bugzilla ref is:
https://bugzilla.redhat.com/show_bug.cgi?id=538920

I'd be happy to do whatever is necessary to help figure this out.

regards, Kyle
