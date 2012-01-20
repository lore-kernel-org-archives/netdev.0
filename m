From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression: sky2 kernel between 3.1 and 3.2.1 (last known good
 3.0.9)
Date: Fri, 20 Jan 2012 08:26:59 -0800
Message-ID: <20120120082659.1e06853e@nehalam.linuxnetplumber.net>
References: <20100120094103.GA6225@ff.dom.local>
	<4B58B217.8030001@majjas.com>
	<20100121204133.GB3085@del.dom.local>
	<4B59E7EB.3050605@majjas.com>
	<4F1452B1.4010200@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42256 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649Ab2ATQ1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 11:27:03 -0500
In-Reply-To: <4F1452B1.4010200@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jan 2012 11:39:13 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> Synopsis:
> 
> Receiving DMAR and other errors after approximately three days of 
> uptime. The symptoms exactly match errors seen and then fixed around 
> 2.6.32.4.
> 
> While the system remains unaffected for too long to do a bisect, I was 
> able to confirm that the problem exists in the 3.1 stable branch (I 
> jumped from 3.0 to 3.2 when 3.2. was released).
> 
> For now I reverted to the sky2.c from 3.0.9 and am running the rest of 
> the kernel from 3.1.2, but won't be certain that this works until later 
> in the week.
> 
> Note that 20 seconds prior to the log extract below were DHCP renewal 
> attempts on eth1, the issue below was on eth0. Not sure it's relevant, 
> however back in 2010 a preceding DHCP event did turn out to be relevant 
> to the manifestation of the bug.
> 
> The 3.2.1-dirty I'm running is from git with a single local patch - for 
> sidewinder force-feedback support (shouldn't be relevant to the sky2 issue).
> 
> Log extract:
> 
> Jan 16 05:49:46 mail kernel: [198230.628919] DRHD: handling fault status 
> reg 2
> Jan 16 05:49:46 mail kernel: [198230.628925] sky2 0000:06:00.0: error 
> interrupt status=0x80000000
> Jan 16 05:49:46 mail kernel: [198230.628929] DMAR:[DMA Read] Request 
> device [06:00.0] fault addr fff78000
> Jan 16 05:49:46 mail kernel: [198230.628931] DMAR:[fault reason 06] PTE 
> Read access is not set
> Jan 16 05:49:46 mail kernel: [198230.628939] sky2 0000:06:00.0: PCI 
> hardware error (0x2010)
> Jan 16 05:49:53 mail dhclient[1616]: DHCPREQUEST on eth1 to 
> 10.240.184.29 port 67
> Jan 16 05:50:01 mail kernel: [198246.288400] ------------[ cut here 
> ]------------
> Jan 16 05:50:01 mail kernel: [198246.288408] WARNING: at 
> net/sched/sch_generic.c:255 dev_watchdog+0x247/0x250()
> Jan 16 05:50:01 mail kernel: [198246.288411] Hardware name: System 
> Product Name
> Jan 16 05:50:01 mail kernel: [198246.288413] NETDEV WATCHDOG: eth0 
> (sky2): transmit queue 0 timed out
> Jan 16 05:50:01 mail kernel: [198246.288415] Modules linked in: tcp_lp 
> cpufreq_stats ebtable_nat ebtables nf_conntrack_netbios_ns 
> nf_conntrack_broadcast ip6table_mangle ip6table_filter ip6_tables 
> iptable_mangle ipt_MASQUERADE iptable_nat nf_nat iptable_raw tun bridge 
> stp llc lockd sit tunnel4 ipt_LOG nf_conntrack_ftp nf_conntrack_ipv6 
> nf_defrag_ipv6 xt_CHECKSUM xt_multiport xt_DSCP w83627ehf xt_mark 
> xt_dscp hwmon_vid binfmt_misc raid1 btrfs sunrpc zlib_deflate libcrc32c 
> snd_hda_codec_analog snd_ens1371 gameport snd_hda_intel snd_rawmidi 
> snd_ac97_codec snd_hda_codec snd_hwdep ac97_bus snd_seq snd_seq_device 
> snd_pcm gspca_spca505 snd_timer gspca_main snd videodev media soundcore 
> i2c_i801 iTCO_wdt microcode v4l2_compat_ioctl32 snd_page_alloc 
> i7core_edac sky2 edac_core pcspkr iTCO_vendor_support virtio_net virtio 
> virtio_ring kvm_intel kvm uinput ipv6 raid456 async_raid6_recov async_pq 
> raid6_pq async_xor firewire_ohci firewire_core pata_acpi ata_generic xor 
> async_memcpy async_tx crc_itu_t pata_marvell nouveau ttm d
> Jan 16 05:50:01 mail kernel: rm_kms_helper drm i2c_algo_bit i2c_core 
> mxm_wmi video [last unloaded: nf_conntrack_broadcast]
> Jan 16 05:50:01 mail kernel: [198246.288487] Pid: 0, comm: swapper/0 
> Tainted: G        W    3.2.1-dirty #1
> Jan 16 05:50:01 mail kernel: [198246.288489] Call Trace:
> Jan 16 05:50:01 mail kernel: [198246.288491] <IRQ>  [<ffffffff81050a4f>] 
> warn_slowpath_common+0x7f/0xc0
> Jan 16 05:50:01 mail kernel: [198246.288501]  [<ffffffff8101f0bd>] ? 
> lapic_next_event+0x1d/0x30
> Jan 16 05:50:01 mail kernel: [198246.288504]  [<ffffffff81050b46>] 
> warn_slowpath_fmt+0x46/0x50
> Jan 16 05:50:01 mail kernel: [198246.288509]  [<ffffffff81009319>] ? 
> read_tsc+0x9/0x20
> Jan 16 05:50:01 mail kernel: [198246.288513]  [<ffffffff814a81e7>] 
> dev_watchdog+0x247/0x250
> Jan 16 05:50:01 mail kernel: [198246.288518]  [<ffffffff8105fbbb>] 
> run_timer_softirq+0x12b/0x3b0
> Jan 16 05:50:01 mail kernel: [198246.288521]  [<ffffffff814a7fa0>] ? 
> qdisc_reset+0x50/0x50
> Jan 16 05:50:01 mail kernel: [198246.288525]  [<ffffffff81057d18>] 
> __do_softirq+0xa8/0x210
> Jan 16 05:50:01 mail kernel: [198246.288529]  [<ffffffff8157496c>] 
> call_softirq+0x1c/0x30
> Jan 16 05:50:01 mail kernel: [198246.288533]  [<ffffffff810041e5>] 
> do_softirq+0x65/0xa0
> Jan 16 05:50:01 mail kernel: [198246.288536]  [<ffffffff810580fe>] 
> irq_exit+0x8e/0xb0
> Jan 16 05:50:01 mail kernel: [198246.288539]  [<ffffffff815750a3>] 
> do_IRQ+0x63/0xe0
> Jan 16 05:50:01 mail kernel: [198246.288543]  [<ffffffff8156ad2e>] 
> common_interrupt+0x6e/0x6e
> Jan 16 05:50:01 mail kernel: [198246.288545] <EOI>  [<ffffffff81307b6d>] 
> ? intel_idle+0xed/0x150
> Jan 16 05:50:01 mail kernel: [198246.288551]  [<ffffffff81307b4f>] ? 
> intel_idle+0xcf/0x150
> Jan 16 05:50:01 mail kernel: [198246.288555]  [<ffffffff8144d331>] 
> cpuidle_idle_call+0xc1/0x280
> Jan 16 05:50:01 mail kernel: [198246.288559]  [<ffffffff8100122a>] 
> cpu_idle+0xca/0x120
> Jan 16 05:50:01 mail kernel: [198246.288563]  [<ffffffff8154741e>] 
> rest_init+0x72/0x74
> Jan 16 05:50:01 mail kernel: [198246.288568]  [<ffffffff81b6abdd>] 
> start_kernel+0x3b5/0x3c0
> Jan 16 05:50:01 mail kernel: [198246.288572]  [<ffffffff81b6a32b>] 
> x86_64_start_reservations+0x132/0x136
> Jan 16 05:50:01 mail kernel: [198246.288576]  [<ffffffff81b6a140>] ? 
> early_idt_handlers+0x140/0x140
> Jan 16 05:50:01 mail kernel: [198246.288580]  [<ffffffff81b6a431>] 
> x86_64_start_kernel+0x102/0x111
> Jan 16 05:50:01 mail kernel: [198246.288583] ---[ end trace 
> bb26011d21a2b1d7 ]---
> Jan 16 05:50:01 mail kernel: [198246.288586] sky2 0000:06:00.0: eth0: tx 
> timeout
> Jan 16 05:50:01 mail kernel: [198246.288593] sky2 0000:06:00.0: eth0: 
> transmit ring 115 .. 10 report=115 done=115
> 
> 
> 


Which exact chip version is this?
  dmesg | grep sky2
  lspci
