From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2:  receive dma mapping error handling
Date: Sat, 30 Jan 2010 11:30:22 -0500
Message-ID: <4B645E9E.10605@majjas.com>
References: <4B60707F.1000608@majjas.com> <20100127095614.14313677@nehalam>
 <4B608128.7090607@majjas.com> <4B6089C7.4010803@majjas.com>
 <4B61ADF1.7060705@majjas.com> <4B61BEA4.1030905@majjas.com>
 <20100128090835.0d93e53a@nehalam> <4B61DB79.4080703@majjas.com>
 <20100128223447.GC3109@del.dom.local> <4B621316.8070308@majjas.com>
 <20100128225621.GD3109@del.dom.local> <4B6216B9.1010802@majjas.com>
 <20100128153643.0fca3c51@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754151Ab0A3QaO@vger.kernel.org>
In-reply-to: <20100128153643.0fca3c51@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/28/2010 6:36 PM, Stephen Hemminger wrote:
> Please try this patch (and only this patch), on 2.6.33-rc5[*];
> none of the other patches that did not make it upstream because that
> confuses things too much.
>
> The code that checks for DMA mapping errors on receive buffers would
> not handle errors correctly.  I doubt you have these errors, but if you
> did then it would explain the problems.  The code has to be a little
> tricky and build mapping for new rx buffer before releasing old one,
> that way if new mapping fails, the old one can be reused.
>
> If it works for you, I will resubmit with signed-off.
>    
Nope - tx crash again. This time the system stayed up (but hosed) for a 
few hours. When I tried to recover eth0, the system crashed.
Brief summary of events (log extract below):

System start Jan 28 19:29
Everything seemed good (load and all) until 17:13:11 the following day 
when I got rx errors:

Jan 29 17:13:11 mail kernel: sky2 eth0: rx error, status 0x6230010 
length 1518
Jan 29 17:13:11 mail kernel: sky2 eth0: rx error, status 0x7f40010 
length 1518
Jan 29 17:13:11 mail kernel: sky2 eth0: rx error, status 0x8180010 
length 1518
Jan 29 17:13:12 mail kernel: sky2 eth0: rx error, status 0x7f40010 
length 1518
Jan 29 17:13:12 mail kernel: sky2 eth0: rx error, status 0x6230010 
length 1518
Jan 29 17:13:12 mail kernel: sky2 eth0: rx error, status 0x8180010 
length 1518
Jan 29 17:13:12 mail kernel: sky2 eth0: rx error, status 0x6230010 
length 1518
Jan 29 17:13:12 mail kernel: sky2 eth0: rx error, status 0x7f40010 
length 1518
Jan 29 17:13:12 mail kernel: sky2 eth0: rx error, status 0x8180010 
length 1518
Jan 29 17:13:14 mail kernel: sky2 eth0: rx error, status 0x5f60010 
length 1518

The system continued running normally after this until this morning (Jan 
30) at 0:44:55:
Jan 30 05:44:55 mail kernel: DRHD: handling fault status reg 2
Jan 30 05:44:55 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
fault addr ffc4331ff000
Jan 30 05:44:55 mail kernel: DMAR:[fault reason 06] PTE Read access is 
not set
Jan 30 05:44:55 mail kernel: net_ratelimit: 2 callbacks suppressed
Jan 30 05:44:55 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0xc0000000
Jan 30 05:44:55 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
Jan 30 05:45:01 mail kernel: ------------[ cut here ]------------
Jan 30 05:45:01 mail kernel: WARNING: at net/sched/sch_generic.c:255 
dev_watchdog+0xf3/0x161()
Jan 30 05:45:01 mail kernel: Hardware name: System Product Name
Jan 30 05:45:01 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
queue 0 timed out
Jan 30 05:45:01 mail kernel: Modules linked in: iptable_raw 
iptable_mangle ipt_MASQUERADE iptable_nat nf_nat cpufreq_stats 
ip6table_filter ip6table_mangle ip6_tables bridge stp appletalk psnap 
llc nfsd lockd nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc 
acpi_cpufreq sit tunnel4 ipt_LOG nf_conntrack_netbios_ns 
nf_conntrack_ftp xt_DSCP xt_dscp xt_MARK nf_conntrack_ipv6 xt_multiport 
ipv6 dm_multipath kvm_intel kvm snd_hda_codec_analog snd_hda_intel 
snd_ens1371 gameport snd_hda_codec snd_rawmidi snd_ac97_codec 
gspca_spca505 ac97_bus gspca_main snd_hwdep videodev snd_seq 
snd_seq_device v4l1_compat snd_pcm v4l2_compat_ioctl32 snd_timer snd 
soundcore snd_page_alloc firewire_ohci pcspkr i2c_i801 firewire_core wmi 
asus_atk0110 crc_itu_t sky2 hwmon iTCO_wdt iTCO_vendor_support fbcon 
tileblit font bitblit softcursor raid456 async_raid6_recov async_pq 
raid6_pq async_xor xor async_memcpy async_tx raid1 ata_generic pata_acpi 
pata_marvell nouveau ttm drm_kms_helper drm agpgart fb i2c_algo_bit 
cfbcopyarea i2c_core cf
Jan 30 05:45:01 mail kernel: bimgblt cfbfillrect [last unloaded: nf_nat]
Jan 30 05:45:01 mail kernel: Pid: 0, comm: swapper Tainted: G        W  
2.6.33-rc5WITHMMAPNODMARFORKTIPSKY2DMAMAP-00283-gd4d37bd-dirty #1
Jan 30 05:45:01 mail kernel: Call Trace:
Jan 30 05:45:01 mail kernel: <IRQ>  [<ffffffff8104a03d>] 
warn_slowpath_common+0x7c/0x94
Jan 30 05:45:01 mail kernel: [<ffffffff8104a0ac>] 
warn_slowpath_fmt+0x41/0x43
Jan 30 05:45:01 mail kernel: [<ffffffff813d2f43>] ? netif_tx_lock+0x44/0x6c
Jan 30 05:45:01 mail kernel: [<ffffffff813d30ab>] dev_watchdog+0xf3/0x161
Jan 30 05:45:01 mail kernel: [<ffffffff8106a31f>] ? 
sched_clock_cpu+0x44/0xce
Jan 30 05:45:01 mail kernel: [<ffffffff8105761a>] 
run_timer_softirq+0x1c3/0x26b
Jan 30 05:45:01 mail kernel: [<ffffffff8105060c>] __do_softirq+0xf8/0x1cd
Jan 30 05:45:01 mail kernel: [<ffffffff8107192b>] ? 
tick_program_event+0x2a/0x2c
Jan 30 05:45:01 mail kernel: [<ffffffff8100ab1c>] call_softirq+0x1c/0x30
Jan 30 05:45:01 mail kernel: [<ffffffff8100c2b3>] do_softirq+0x4b/0xa3
Jan 30 05:45:01 mail kernel: [<ffffffff810501f8>] irq_exit+0x4a/0x8c
Jan 30 05:45:01 mail kernel: [<ffffffff81461859>] 
smp_apic_timer_interrupt+0x86/0x94
Jan 30 05:45:01 mail kernel: [<ffffffff8100a5d3>] 
apic_timer_interrupt+0x13/0x20
Jan 30 05:45:01 mail kernel: <EOI>  [<ffffffff812afbd4>] ? 
acpi_idle_enter_bm+0x256/0x28a
Jan 30 05:45:01 mail kernel: [<ffffffff812afbcd>] ? 
acpi_idle_enter_bm+0x24f/0x28a
Jan 30 05:45:01 mail kernel: [<ffffffff8139574c>] 
cpuidle_idle_call+0x9e/0xfa
Jan 30 05:45:01 mail kernel: [<ffffffff81008c05>] cpu_idle+0xb4/0xf6
Jan 30 05:45:01 mail kernel: [<ffffffff81455d48>] 
start_secondary+0x201/0x242
Jan 30 05:45:01 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan 30 05:45:01 mail kernel: sky2 eth0: tx timeout
Jan 30 05:45:01 mail kernel: sky2 eth0: transmit ring 14 .. 102 
report=14 done=14
Jan 30 05:45:01 mail kernel: sky2 eth0: disabling interface
Jan 30 05:45:01 mail kernel: sky2 eth0: enabling interface

This down/up continued for several hours until I intervened at about 10:05.

I saw that there was no eth0 connectivity, eth1 was ok. It appeard that 
eth0 was receiving traffic but unable to send. arpwatch was reporting 
bogons, DHCP showed many DISCOVER/OFFER pairs, no REQUEST/ACK. Pings to 
any system failed; arp showed incomplete for anything hanging off of 
eth0. arping also failed.
I manually stopped and started eth0 (ifconfig) and reset iptables 
(although eth0 has no filters).

As I started looking at logs, the system hung and rebooted. I'm up now 
with dma debug enabled, however as with 2.6.32.4 num_entries is dropping 
and I don't think that dma debug will remain enabled long enough to 
catch a crash.

So, as I see things, there are two issues here: 1) the TX hang post DMAR 
error and 2) the inability to recover the interface and subsequent 
system instability.
