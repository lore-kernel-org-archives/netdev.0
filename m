From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 22 Aug 2009 05:07:41 -0700
Message-ID: <m18whcf3w2.fsf@fess.ebiederm.org>
References: <200903041828.49972.m.bueker@berlin.de>
	<1242001754.4093.12.camel@obelisk.thedillows.org>
	<200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
	<1242077392.3716.15.camel@lap75545.ornl.gov>
	<4A09DC3E.2080807@googlemail.com>
	<1242268709.4979.7.camel@obelisk.thedillows.org>
	<4A0C6504.8000704@googlemail.com>
	<1242328457.32579.12.camel@lap75545.ornl.gov>
	<4A0C7443.1010000@googlemail.com>
	<1243042174.3580.23.camel@obelisk.thedillows.org>
	<m1skfkrik2.fsf@fess.ebiederm.org>
	<1250895567.23419.1.camel@obelisk.thedillows.org>
	<1250897657.23419.5.camel@obelisk.thedillows.org>
	<m1iqggf4rf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?utf-8?Q?B=C3=BCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755830AbZHVMHt@vger.kernel.org>
In-Reply-To: <m1iqggf4rf.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 22 Aug 2009 04\:48\:52 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ebiederm@xmission.com (Eric W. Biederman) writes:

> David Dillow <dave@thedillows.org> writes:
>
>>
>> Re-looking at the code, I'd guess that some IRQ status line is getting
>> stuck high, but I don't see why -- we should acknowledge all outstanding
>> interrupts each time through the loop, whether we care about them or
>> not.
>>
>> Could reproduce a problem with the following patch applied, and send the
>> full dmesg, please?
>
> Here is what I get.
>
> r8169 screaming irq status 00000085 mask 0000ffff event 0000803f napi 0000001d

And now that the machine has come out of it, that was followed by:
Looks like the soft lockup did not manage to trigger in this case.

------------[ cut here ]------------
WARNING: at /home/ebiederm/projects/linux/linux-2.6.30-Arora/net/sched/sch_generic.c:226 dev_watchdog+0xd9/0x14a()
Hardware name: G33M-S2
NETDEV WATCHDOG: eth0 (r8169): transmit timed out
Modules linked in: tulip xt_tcpudp iptable_filter nfsd lockd nfs_acl auth_rpcgss bridge stp exportfs bnep sco l2cap bluetooth sunrpc ipv6 cpufreq_ondemand acpi_cpufreq freq_table ext4 jbd2 crc16 dm_mirror dm_region_hash dm_log dm_multipath dm_mod uinput kvm_intel kvm fuse xt_multiport iptable_nat ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 tun 8021q snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm ppdev ata_generic snd_timer firewire_ohci pata_acpi parport_pc snd firewire_core parport r8169 i2c_i801 pata_jmicron mii pcspkr soundcore sg iTCO_wdt floppy iTCO_vendor_support snd_page_alloc crc_itu_t ahci libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd i915 drm i2c_algo_bit video output i2c_core [last unloaded: microcode]
Pid: 0, comm: swapper Not tainted 2.6.30eric-rtl8169-debug #36
Call Trace:
 <IRQ>  [<ffffffff8104583b>] warn_slowpath_common+0x88/0xb6
 [<ffffffff812ee53c>] ? dev_watchdog+0x0/0x14a
 [<ffffffff810458ec>] warn_slowpath_fmt+0x4b/0x61
 [<ffffffff812d607e>] ? netdev_drivername+0x52/0x70
 [<ffffffff812ee615>] dev_watchdog+0xd9/0x14a
 [<ffffffff810596de>] ? __queue_work+0x44/0x61
 [<ffffffff81050922>] run_timer_softirq+0x169/0x1f5
 [<ffffffff81020306>] ? apic_write+0x24/0x3a
 [<ffffffff81069ce2>] ? clockevents_program_event+0x88/0xa5
 [<ffffffff8104ba7b>] __do_softirq+0xc3/0x1b0
 [<ffffffff8100cfcc>] call_softirq+0x1c/0x28
 [<ffffffff8100e721>] do_softirq+0x51/0xae
 [<ffffffff8104b6d2>] irq_exit+0x52/0xa3
 [<ffffffff81020f11>] smp_apic_timer_interrupt+0x94/0xb8
 [<ffffffff8100c9d3>] apic_timer_interrupt+0x13/0x20
 <EOI>  [<ffffffff81014096>] ? mwait_idle+0x9b/0xcc
 [<ffffffff81014038>] ? mwait_idle+0x3d/0xcc
 [<ffffffff8100ae08>] ? enter_idle+0x33/0x49
 [<ffffffff8100aece>] ? cpu_idle+0xb0/0xf3
 [<ffffffff8136f25c>] ? start_secondary+0x19c/0x1b7
---[ end trace 595b23907a063360 ]---
