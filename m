From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Wed, 27 Jan 2010 13:33:48 -0500
Message-ID: <4B60870C.2060308@majjas.com>
References: <20100120094103.GA6225@ff.dom.local> <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local> <4B59E7EB.3050605@majjas.com>
 <20100122215304.GA3105@del.dom.local> <4B5A2362.6000306@majjas.com>
 <20100122230605.GB3105@del.dom.local> <4B5A33D8.90501@majjas.com>
 <20100122234656.GC3105@del.dom.local> <4B5A39BD.8020305@majjas.com>
 <20100123232133.GA3487@del.dom.local> <4B605D1B.60402@majjas.com>
 <20100127085049.5b5048e9@nehalam> <4B60707F.1000608@majjas.com>
 <20100127094531.53c85aa7@nehalam> <4B607E70.4060402@majjas.com>
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
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.srv.hcvlny.cv.net ([167.206.4.196]:39594 "EHLO
	mta1.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735Ab0A0SeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 13:34:07 -0500
In-reply-to: <4B607E70.4060402@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2010 12:57 PM, Michael Breuer wrote:
> On 1/27/2010 12:45 PM, Stephen Hemminger wrote:
>> On Wed, 27 Jan 2010 11:57:35 -0500
>> Michael Breuer<mbreuer@majjas.com>  wrote:
>>
>>
> Ah - ok... will poke around there... if you have any suggestions, 
> diagnostics, whatever, let me know. Also, just an FYI - before 
> rebooting with copybreak back to defaults, I tried mtu=9000 again. 
> That hung the server immediately - no diagnostic output - system froze 
> until watchdog rebooted. Don't know right now if the copybreak had 
> anything to do with this, but when I've tried in the past I've had 
> errors on sky2, but never crashed the system like this. Only two 
> things different were copybreak and the length of time the system had 
> been up. I'll try later with copybreak default and copybreak=1 to see 
> if that affects mtu behavior.
>
FYI - just redid this a few times. Looks like it's how long the system 
was up, not copybreak wrt crash on resetting MTU.

That said, while the system seems OK after resetting the MTU, I do get a 
WARNING from netdev watchdog - same warning regardless of copybreak. 
Setting the mtu back to 1500 generates rx errors after which things 
work. Going back to 9000 again does not generate new errors.

Jan 27 13:21:54 mail kernel: ------------[ cut here ]------------
Jan 27 13:21:54 mail kernel: WARNING: at net/sched/sch_generic.c:261 
dev_watchdog+0xf3/0x164()
Jan 27 13:21:54 mail kernel: Hardware name: System Product Name
Jan 27 13:21:54 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
queue 0 timed out
Jan 27 13:21:54 mail kernel: Modules linked in: microcode(+) 
ip6table_mangle ip6table_filter ip6_tables ipt_MASQUERADE iptable_nat 
nf_nat iptable_mangle iptable_raw bridge stp appletalk psnap llc nfsd 
lockd nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc 
acpi_cpufreq sit tunnel4 ipt_LOG nf_conntrack_netbios_ns 
nf_conntrack_ftp nf_conntrack_ipv6 xt_multiport xt_DSCP xt_dscp xt_MARK 
ipv6 dm_multipath kvm_intel kvm snd_hda_codec_analog snd_ens1371 
gameport snd_rawmidi snd_ac97_codec snd_hda_intel snd_hda_codec 
snd_hwdep ac97_bus snd_seq gspca_spca505 gspca_main videodev 
snd_seq_device asus_atk0110 v4l1_compat snd_pcm hwmon 
v4l2_compat_ioctl32 pcspkr i2c_i801 firewire_ohci firewire_core 
crc_itu_t snd_timer snd soundcore wmi snd_page_alloc sky2 iTCO_wdt 
iTCO_vendor_support fbcon tileblit font bitblit softcursor raid456 
async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx 
raid1 ata_generic pata_acpi pata_marvell nouveau ttm drm_kms_helper drm 
agpgart fb i2c_algo_bit cfbcopyarea i2c_core cfb
Jan 27 13:21:54 mail kernel: imgblt cfbfillrect [last unloaded: ip6_tables]
Jan 27 13:21:54 mail kernel: Pid: 0, comm: swapper Tainted: G        W  
2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty #6
Jan 27 13:21:54 mail kernel: Call Trace:
Jan 27 13:21:54 mail kernel: <IRQ>  [<ffffffff810536ee>] 
warn_slowpath_common+0x7c/0x94
Jan 27 13:21:54 mail kernel: [<ffffffff8105375d>] 
warn_slowpath_fmt+0x41/0x43
Jan 27 13:21:54 mail kernel: [<ffffffff813e3b6b>] ? netif_tx_lock+0x44/0x6c
Jan 27 13:21:54 mail kernel: [<ffffffff813e3cd3>] dev_watchdog+0xf3/0x164
Jan 27 13:21:54 mail kernel: [<ffffffff8106e990>] ? __queue_work+0x3a/0x42
Jan 27 13:21:54 mail kernel: [<ffffffff8106323f>] 
run_timer_softirq+0x1c8/0x270
Jan 27 13:21:54 mail kernel: [<ffffffff8105af0f>] __do_softirq+0xf8/0x1cd
Jan 27 13:21:54 mail kernel: [<ffffffff8107f0ab>] ? 
tick_program_event+0x2a/0x2c
Jan 27 13:21:54 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan 27 13:21:54 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan 27 13:21:54 mail kernel: [<ffffffff8105aaef>] irq_exit+0x4a/0x8c
Jan 27 13:21:54 mail kernel: [<ffffffff81470612>] 
smp_apic_timer_interrupt+0x86/0x94
Jan 27 13:21:54 mail kernel: [<ffffffff810127e3>] 
apic_timer_interrupt+0x13/0x20
Jan 27 13:21:54 mail kernel: <EOI>  [<ffffffff812c729a>] ? 
acpi_idle_enter_bm+0x256/0x28a
Jan 27 13:21:54 mail kernel: [<ffffffff812c7293>] ? 
acpi_idle_enter_bm+0x24f/0x28a
Jan 27 13:21:54 mail kernel: [<ffffffff813a6c3c>] ? 
cpuidle_idle_call+0x9e/0xfa
Jan 27 13:21:54 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
Jan 27 13:21:54 mail kernel: [<ffffffff81465ba5>] ? 
start_secondary+0x201/0x242
Jan 27 13:21:54 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan 27 13:21:54 mail kernel: sky2 eth0: tx timeout
Jan 27 13:21:54 mail kernel: sky2 eth0: transmit ring 51 .. 10 report=51 
done=51
Jan 27 13:21:54 mail kernel: sky2 eth0: disabling interface
Jan 27 13:21:54 mail kernel: sky2 eth0: enabling interface


