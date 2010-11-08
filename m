From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Sky2 2.6.36-09934-g2aab243 DMAR error with tcp timestamp
 enabled
Date: Sun, 7 Nov 2010 19:13:04 -0800
Message-ID: <20101107191304.4a6cdfa4@s6510>
References: <20100128223447.GC3109@del.dom.local>
	<4B621316.8070308@majjas.com>
	<20100128225621.GD3109@del.dom.local>
	<4B6216B9.1010802@majjas.com>
	<20100128153643.0fca3c51@nehalam>
	<4B645EF4.4050701@majjas.com>
	<20100131003449.GA11935@del.dom.local>
	<4B650D53.2010607@majjas.com>
	<4B65D0F9.2020602@majjas.com>
	<4B65FD12.7090101@majjas.com>
	<20100131221835.GA3317@del.dom.local>
	<20100201102018.7b597992@nehalam>
	<4B68F664.6050007@majjas.com>
	<4B69A897.7030408@majjas.com>
	<20100203085618.6662cc6f@nehalam>
	<4B69AD5C.5030601@majjas.com>
	<4CD58911.3050201@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43770 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753940Ab0KHDNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Nov 2010 22:13:08 -0500
In-Reply-To: <4CD58911.3050201@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 06 Nov 2010 12:57:53 -0400
Michael Breuer <mbreuer@majjas.com> wrote:

> Basically, if I enable tcp timestamps (now disabled) I get a sky2 hang. 
> As with the earlier issue the effects are not seen until after a couple 
> days of uptime and seem exacerbated by load.
> 
> I can't 100% confirm that the problem is not occurring without tcp 
> timestamps, but will leave the system up for a while to try to confirm. 
> This didn't occur previously without tcp timestamps enabled, but I also 
> pulled git changes between the two events.
> 
> I'm now also on 2.6.37-rc1.... I did a quick scan and didn't see any 
> obvious commits between 2.6.36-09934 and -rc1 that would have affected this.
> 
>  From the log:
> Nov  2 05:41:54 mail kernel: DRHD: handling fault status reg 2
> Nov  2 05:41:54 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
> fault addr ffea3000
> Nov  2 05:41:54 mail kernel: DMAR:[fault reason 06] PTE Read access is 
> not set
> Nov  2 05:41:54 mail kernel: sky2 0000:06:00.0: error interrupt 
> status=0x80000000
> Nov  2 05:41:54 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
> Nov  2 05:42:01 mail clamd[9755]: SelfCheck: Database status OK.
> Nov  2 05:42:11 mail root: ping of potter failed
> Nov  2 05:42:16 mail kernel: ------------[ cut here ]------------
> Nov  2 05:42:16 mail kernel: WARNING: at net/sched/sch_generic.c:258 
> dev_watchdog+0x251/0x260()
> Nov  2 05:42:16 mail kernel: Hardware name: System Product Name
> Nov  2 05:42:16 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
> queue 0 timed out
> Nov  2 05:42:16 mail kernel: Modules linked in: cpufreq_stats 
> ip6table_filter ip6table_mangle ip6_tables ipt_MASQUERADE iptable_nat 
> nf_nat iptable_mangle iptable_raw ebtable_nat ebtables bridge stp 
> appletalk psnap llc nfsd lockd nfs_acl auth_rpcgss exportfs coretemp 
> sunrpc acpi_cpufreq mperf sit tunnel4 ipt_LOG nf_conntrack_netbios_ns 
> nf_conntrack_ftp xt_DSCP xt_dscp xt_mark nf_conntrack_ipv6 
> nf_defrag_ipv6 xt_state xt_multiport ipv6 kvm_intel kvm 
> snd_hda_codec_analog snd_ens1371 gameport snd_rawmidi snd_ac97_codec 
> snd_hda_intel snd_hda_codec ac97_bus snd_hwdep snd_seq snd_seq_device 
> snd_pcm gspca_spca505 gspca_main snd_timer videodev snd v4l1_compat 
> i2c_i801 sky2 v4l2_compat_ioctl32 iTCO_wdt pcspkr asus_atk0110 
> i7core_edac edac_core soundcore iTCO_vendor_support snd_page_alloc 
> microcode raid456 async_raid6_recov async_pq raid6_pq async_xor xor 
> async_memcpy async_tx raid1 ata_generic firewire_ohci pata_acpi 
> firewire_core crc_itu_t pata_marvell nouveau ttm drm_kms_helper drm 
> i2c_algo_bit i2c_core video output [
> Nov  2 05:42:16 mail kernel: last unloaded: ip6_tables]
> Nov  2 05:42:16 mail kernel: Pid: 0, comm: swapper Tainted: G        W   
> 2.6.36-09934-g2aab243 #44
> Nov  2 05:42:16 mail kernel: Call Trace:
> Nov  2 05:42:16 mail kernel: <IRQ>  [<ffffffff81058a4f>] 
> warn_slowpath_common+0x7f/0xc0
> Nov  2 05:42:16 mail kernel: [<ffffffff81058b46>] 
> warn_slowpath_fmt+0x46/0x50
> Nov  2 05:42:16 mail kernel: [<ffffffff814603d1>] dev_watchdog+0x251/0x260
> Nov  2 05:42:16 mail kernel: [<ffffffff8108a4a6>] ? 
> tick_program_event+0x26/0x30
> Nov  2 05:42:16 mail kernel: [<ffffffff8107eed4>] ? 
> hrtimer_interrupt+0x134/0x240
> Nov  2 05:42:16 mail kernel: [<ffffffff81068ab0>] 
> run_timer_softirq+0x160/0x390
> Nov  2 05:42:16 mail kernel: [<ffffffff8108a368>] ? 
> tick_dev_program_event+0x48/0x110
> Nov  2 05:42:16 mail kernel: [<ffffffff81460180>] ? dev_watchdog+0x0/0x260
> Nov  2 05:42:16 mail kernel: [<ffffffff8105f981>] __do_softirq+0xb1/0x220
> Nov  2 05:42:16 mail kernel: [<ffffffff8100cfdc>] call_softirq+0x1c/0x30
> Nov  2 05:42:16 mail kernel: [<ffffffff8100ea15>] do_softirq+0x65/0xa0
> Nov  2 05:42:16 mail kernel: [<ffffffff8105f845>] irq_exit+0x85/0x90
> Nov  2 05:42:16 mail kernel: [<ffffffff81511d61>] do_IRQ+0x71/0xf0
> Nov  2 05:42:16 mail kernel: [<ffffffff8150a7d3>] ret_from_intr+0x0/0x11
> Nov  2 05:42:16 mail kernel: <EOI>  [<ffffffff812e4165>] ? 
> intel_idle+0xd5/0x170
> Nov  2 05:42:16 mail kernel: [<ffffffff812e4148>] ? intel_idle+0xb8/0x170
> Nov  2 05:42:16 mail kernel: [<ffffffff81425b51>] 
> cpuidle_idle_call+0x91/0x150
> Nov  2 05:42:16 mail kernel: [<ffffffff8100aa8b>] cpu_idle+0xbb/0x150
> Nov  2 05:42:16 mail kernel: [<ffffffff814f1785>] rest_init+0x75/0x80
> Nov  2 05:42:16 mail kernel: [<ffffffff81b4ae9b>] start_kernel+0x3dc/0x3e7
> Nov  2 05:42:16 mail kernel: [<ffffffff81b4a346>] 
> x86_64_start_reservations+0x131/0x135
> Nov  2 05:42:16 mail kernel: [<ffffffff81b4a450>] 
> x86_64_start_kernel+0x106/0x115
> Nov  2 05:42:16 mail kernel: ---[ end trace d9d3a1889f8925bf ]---
> Nov  2 05:42:16 mail kernel: sky2 0000:06:00.0: eth0: tx timeout
> Nov  2 05:42:16 mail kernel: sky2 0000:06:00.0: eth0: transmit ring 29 
> .. 117 report=29 done=29
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks like a hardware issue, never saw it before.
Are you running MTU > 1500?
Does turning off TSO help?

One possibility is that NET_IP_ALIGN changed. Now the ethernet header is
aligned and the IP header is not.


