From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: pch_gbe: oops with vlan (new)
Date: Fri, 11 May 2012 13:48:17 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44DDF9105@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:40128 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758021Ab2EKUsW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 16:48:22 -0400
Received: from ka-exchange-1.kontronamerica.local ([10.100.2.39]) by mail.us.kontron.com with ESMTP id Vx0AAGBsMkwUCOpH for <netdev@vger.kernel.org>; Fri, 11 May 2012 13:48:21 -0700 (PDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

I am looking for help in debugging a pch_gbe driver oops/abort.

Kernel: version 2.6.32-220.el6.i686 (RHEL6.2)
Driver: pch_gbe version 0.91-NAPI  (source tarball we used is at
https://sendfile.kontron.com/message/24tdUi6MXklnUtBLnOsumq until May
16)
NIC: 0b:00.1 Ethernet controller [0200]: Intel Corporation Platform
Controller Hub EG20T Gigabit Ethernet Controller [8086:8802] (rev 02)

Configuration, with VLAN:
 eth0 (not started)
 eth0.100 = 192.168.100.1
 eth0.200 = 192.168.200.1
 eth0.6  = 192.168.6.1

When starting the VLAN configuration, then doing a ping test for >= 5
minutes, I get a kernel oop/abort message as shown below.  This does not
happen without configuring VLAN.
Where should I look for possible causes for a transmit queue timeout
like this?  

I have contacted the OKI/LAPIS driver authors, but no response so far.
I thought that this group might be able to comment from similar
experiences.

Andy

May 11 11:06:09 kontron kernel: ------------[ cut here ]------------
May 11 11:06:09 kontron kernel: WARNING: at net/sched/sch_generic.c:261
dev_watchdog+0x1ec/0x200() (Not tainted)
May 11 11:06:09 kontron kernel: Hardware name: N/A
May 11 11:06:09 kontron kernel: NETDEV WATCHDOG: eth0 (pch_gbe):
transmit queue 0 timed out
May 11 11:06:09 kontron kernel: Modules linked in: fuse ip6table_filter
ip6_tables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4
nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM
iptable_mangle iptable_filter ip_tables tun bridge autofs4 sunrpc
cpufreq_ondemand acpi_cpufreq mperf 8021q garp stp llc ipv6 ext3 jbd
uinput ppdev parport_pc parport sg microcode pch_gbe(U) mii serio_raw
snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq
snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc ext4
mbcache jbd2 sd_mod crc_t10dif ahci sdhci_pci sdhci mmc_core video
output dm_mirror dm_region_hash dm_log dm_mod [last unloaded:
scsi_wait_scan]
May 11 11:06:09 kontron kernel: Pid: 0, comm: swapper Not tainted
2.6.32-220.el6.i686 #1
May 11 11:06:09 kontron kernel: Call Trace:
May 11 11:06:09 kontron kernel: [<c0454c81>] ?
warn_slowpath_common+0x81/0xc0
May 11 11:06:09 kontron kernel: [<c07a16bc>] ? dev_watchdog+0x1ec/0x200
May 11 11:06:09 kontron kernel: [<c07a16bc>] ? dev_watchdog+0x1ec/0x200
May 11 11:06:09 kontron kernel: [<c0454d53>] ?
warn_slowpath_fmt+0x33/0x40
May 11 11:06:09 kontron kernel: [<c07a16bc>] ? dev_watchdog+0x1ec/0x200
May 11 11:06:09 kontron kernel: [<c0471bfa>] ? insert_work+0x5a/0xb0
May 11 11:06:09 kontron kernel: [<c04656f9>] ?
run_timer_softirq+0x139/0x2c0
May 11 11:06:09 kontron kernel: [<c0831315>] ?
apic_timer_interrupt+0x31/0x38
May 11 11:06:09 kontron kernel: [<c07a14d0>] ? dev_watchdog+0x0/0x200
May 11 11:06:09 kontron kernel: [<c045be4a>] ? __do_softirq+0x8a/0x1a0
May 11 11:06:09 kontron kernel: [<c045bf9d>] ? do_softirq+0x3d/0x50
May 11 11:06:09 kontron kernel: [<c045c0f5>] ? irq_exit+0x65/0x70
May 11 11:06:09 kontron kernel: [<c0428473>] ?
smp_apic_timer_interrupt+0x53/0x90
May 11 11:06:09 kontron kernel: [<c0831315>] ?
apic_timer_interrupt+0x31/0x38
May 11 11:06:09 kontron kernel: [<c045007b>] ?
throttle_cfs_rq+0x6b/0x130
May 11 11:06:09 kontron kernel: [<c064735f>] ? intel_idle+0xaf/0x140
May 11 11:06:09 kontron kernel: [<c075c282>] ?
cpuidle_idle_call+0x72/0x100
May 11 11:06:09 kontron kernel: [<c0408964>] ? cpu_idle+0x94/0xd0
May 11 11:06:09 kontron kernel: [<c082a645>] ?
start_secondary+0x20d/0x252
May 11 11:06:09 kontron kernel: ---[ end trace 3672ff56500ae344 ]---
May 11 11:06:09 kontron NetworkManager[1608]: <info> (eth0): carrier now
OFF (device state 3)
May 11 11:06:09 kontron NetworkManager[1608]: <info> (eth0): device
state change: 3 -> 2 (reason 40)
May 11 11:06:09 kontron NetworkManager[1608]: <info> (eth0):
deactivating device (reason: 40).
