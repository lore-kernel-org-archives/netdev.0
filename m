From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 07 Jan 2010 18:11:34 -0500
Message-ID: <4B466A26.5070506@majjas.com>
References: <4B4571D5.30002@majjas.com> <4B457711.1040008@majjas.com>
 <4B458B36.6050509@majjas.com> <20100107074756.GB6258@ff.dom.local>
 <4B459368.2000503@majjas.com> <4B45F841.8030407@majjas.com>
 <20100107180114.GB3088@del.dom.local> <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local> <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753994Ab0AGXMQ@vger.kernel.org>
In-reply-to: <20100107185040.GB3208@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/7/2010 1:50 PM, Jarek Poplawski wrote:
> On Thu, Jan 07, 2010 at 01:43:08PM -0500, Michael Breuer wrote:
>    
>> On 1/7/2010 1:35 PM, Jarek Poplawski wrote:
>>      
>>> On Thu, Jan 07, 2010 at 01:19:41PM -0500, Michael Breuer wrote:
>>>        
>>>> On 1/7/2010 1:01 PM, Jarek Poplawski wrote:
>>>>          
>>>>> On Thu, Jan 07, 2010 at 10:05:37AM -0500, Michael Breuer wrote:
>>>>>            
>>>>>> Bad news - crashed about an hour after I wrote this email - under
>>>>>> load - same crash as before. Network watchdog... lots of attempts to
>>>>>> reset the adapter... then hw watchdog rebooted the system.
>>>>>>              
>>>>> It's a pity. Anyway, I'd be still interested in CONFIG_PACKET_MMAP off
>>>>> if you find time.
>>>>>
>>>>> Jarek P.
>>>>>            
>>>> Ok - any particular patch set to try with? I'm going to start with a
>>>> clean tree using the latest 2.6.32 from git (tried 2.6.33-rc3, but
>>>> can't get a usable console... will look at that later.)
>>>>          
>>> My "Berck E. Nash" and Stephen's "pskb_may_pull" sky2 patches. (BTW,
>>> could you remind if it worked any better with 2.6.31 or earlier?)
>>>
>>> Jarek P.
>>>        
>> I'm not sure my crash-and-burn runs yesterday included the
>> pskb_may_pull patch :(
>>
>> Going to rerun with these patches and with and without MMAP. Will
>> also retry both with jumbo frames if possible.
>>      
> If MMAP then some "alternative" too. But first no MMAP.
>
> Jarek P.
>    
Results:
* no MMAP, mtu=1500, neither alternative patch loaded: adapter crashed:
Jan  7 15:44:23 mail kernel: DRHD: handling fault status reg 2
Jan  7 15:44:23 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
fault addr fffb7bffe000
Jan  7 15:44:23 mail kernel: DMAR:[fault reason 06] PTE Read access is 
not set
Jan  7 15:44:23 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x80000000
Jan  7 15:44:23 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
Jan  7 15:44:24 mail smbd[6572]: [2010/01/07 15:44:24,  0] 
lib/util_sock.c:539(read_fd_with_timeout)
Jan  7 15:44:24 mail smbd[6572]: [2010/01/07 15:44:24,  0] 
lib/util_sock.c:1491(get_peer_addr_internal)
Jan  7 15:44:24 mail smbd[6572]:   getpeername failed. Error was 
Transport endpoint is not connected
Jan  7 15:44:24 mail smbd[6572]:   read_fd_with_timeout: client 0.0.0.0 
read error = Connection timed out.
Jan  7 15:44:44 mail kernel: ------------[ cut here ]------------
Jan  7 15:44:44 mail kernel: WARNING: at net/sched/sch_generic.c:261 
dev_watchdog+0xf3/0x164()
Jan  7 15:44:44 mail kernel: Hardware name: System Product Name
Jan  7 15:44:44 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
queue 0 timed out
Jan  7 15:44:44 mail kernel: Modules linked in: ip6table_filter 
ip6table_mangle ip6_tables ipt_MASQUERADE iptable_nat nf_nat 
iptable_mangle iptable_raw bridge stp appletalk psnap llc nfsd lockd 
nfs_acl auth_rpcgss exportfs hwmon_vid coretemp sunrpc acpi_cpufreq sit 
tunnel4 ipt_LOG nf_conntrack_netbios_ns nf_conntrack_ftp xt_DSCP xt_dscp 
xt_MARK nf_conntrack_ipv6 xt_multiport ipv6 dm_multipath kvm_intel kvm 
snd_hda_codec_analog snd_ens1371 gameport snd_rawmidi snd_ac97_codec 
snd_hda_intel snd_hda_codec ac97_bus snd_hwdep snd_seq snd_seq_device 
snd_pcm gspca_spca505 gspca_main firewire_ohci videodev v4l1_compat 
firewire_core pcspkr v4l2_compat_ioctl32 snd_timer iTCO_wdt i2c_i801 
crc_itu_t iTCO_vendor_support snd soundcore snd_page_alloc sky2 wmi 
asus_atk0110 hwmon fbcon tileblit font bitblit softcursor raid456 
async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx 
raid1 ata_generic pata_acpi pata_marvell nouveau ttm drm_kms_helper drm 
agpgart fb i2c_algo_bit cfbcopyarea i2c_core cfbimgblt cfbfil
Jan  7 15:44:44 mail kernel: lrect [last unloaded: microcode]
Jan  7 15:44:44 mail kernel: Pid: 0, comm: swapper Tainted: G        W  
2.6.32NOMMAP-00847-g50ebb93-dirty #4
Jan  7 15:44:44 mail kernel: Call Trace:
Jan  7 15:44:44 mail kernel: <IRQ>  [<ffffffff8105365a>] 
warn_slowpath_common+0x7c/0x94
Jan  7 15:44:44 mail kernel: [<ffffffff810536c9>] 
warn_slowpath_fmt+0x41/0x43
Jan  7 15:44:44 mail kernel: [<ffffffff813e2dcf>] ? netif_tx_lock+0x44/0x6c
Jan  7 15:44:44 mail kernel: [<ffffffff813e2f37>] dev_watchdog+0xf3/0x164
Jan  7 15:44:44 mail kernel: [<ffffffff8106e8a4>] ? __queue_work+0x3a/0x42
Jan  7 15:44:44 mail kernel: [<ffffffff8106316b>] 
run_timer_softirq+0x1c8/0x270
Jan  7 15:44:44 mail kernel: [<ffffffff8105ae3b>] __do_softirq+0xf8/0x1cd
Jan  7 15:44:44 mail kernel: [<ffffffff8107ef33>] ? 
tick_program_event+0x2a/0x2c
Jan  7 15:44:44 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan  7 15:44:44 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan  7 15:44:44 mail kernel: [<ffffffff8105aa1b>] irq_exit+0x4a/0x8c
Jan  7 15:44:44 mail kernel: [<ffffffff8146e3e2>] 
smp_apic_timer_interrupt+0x86/0x94
Jan  7 15:44:44 mail kernel: [<ffffffff810127e3>] 
apic_timer_interrupt+0x13/0x20
Jan  7 15:44:44 mail kernel: <EOI>  [<ffffffff812c678a>] ? 
acpi_idle_enter_bm+0x256/0x28a
Jan  7 15:44:44 mail kernel: [<ffffffff812c6783>] ? 
acpi_idle_enter_bm+0x24f/0x28a
Jan  7 15:44:44 mail kernel: [<ffffffff813a5ec8>] ? 
cpuidle_idle_call+0x9e/0xfa
Jan  7 15:44:44 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
Jan  7 15:44:44 mail kernel: [<ffffffff814639c2>] ? 
start_secondary+0x201/0x242
Jan  7 15:44:44 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan  7 15:44:44 mail kernel: sky2 eth0: tx timeout
Jan  7 15:44:44 mail kernel: sky2 eth0: transmit ring 77 .. 36 report=77 
done=77
Jan  7 15:44:44 mail kernel: sky2 eth0: disabling interface
Jan  7 15:44:44 mail kernel: sky2 eth0: enabling interface
--- adapter dead after this --- rebooted.
* no MMAP; alternative 1 patch, mtu=1500; no errors; sustained transfer 
rates about 25% lower than what I saw with mmap enabled...(before MMAP 
enabled crashed).
* no MMAP mtu=9000; ran ok at low transfer rates - when high rates 
kicked in, got the sky2 interrupt error & things went south:
Jan  7 15:09:28 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x40000008
Jan  7 15:09:28 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x40000008
After this, remote connections broke and I rebooted... decided to rerun 
w/o MMAP again before going back to MMAP and trying those other sky2 
options...
* Retest of no MMAP + Alternative 1 - just to confirm consistency. 
Worked - no errors. Only version so far that allows the win7 backup to 
complete.
* MMAP + NO DMAR + disable_msi=1... also works w/o errors... leaving 
this one running for a while - also completed a backup successfully. 
Fastest of the lot... about 3x faster than any other version, working or 
not.

I'm leaving this one running for now. Not retesting jumbo for now. Be 
happy to help dig further.

Tentative recommendations:

1) The af alternative patch seems rather necessary. First alternative 
seems to be working, I'd suggest that be submitted and backported to 2.6.32.
2) Steven's pskb_may_pull patch also ought to be included and backported.
3) Jumbo frame support for yukon2 should probably be disabled until/if 
fixed.
4) When possible I'll test dmar and disable_msi, and no dmar and no 
disable_msi. When I first hit issues, I was running without DMAR, but 
also without the above patches. I suppose the non-working permutations 
need to be either fixed or invalidated (or well documented).
5) It would be nice if someone with comparable hardware could reproduce 
these issues. FWIW, I can only recreate the crash running windows backup 
to a cifs share. Copying large files doesn't seem to do it.  Could also 
be some other interaction going on here that perhaps others aren't 
running - would be happy to compare notes.

Notes:
This *could* be coincidental, but maybe not...
With MMAP+NO DMAR + disable_msi there are far fewer ... actually almost 
no... bind error reports... and no bind format error messages. With 
NOMMAP and alternative one there are a few more bind error messages and 
one format error message during the several hours that version was up. 
All other configurations going back perhaps for two weeks have 
significantly more bind error reports - and all versions show increasing 
frequency of bind format errors (IPV6 only) in the roughly 10-15 minutes 
preceding the lockup/crash/interrupt error messages. There are none 
immediately preceding any crash, but perhaps there is some correlation 
between the network errors and bind ipv6 packets.
