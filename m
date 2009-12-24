From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Thu, 24 Dec 2009 14:18:12 -0500
Message-ID: <4B33BE74.3030704@majjas.com>
References: <4B300A2A.8040305@gmail.com> <4B300E30.9090707@majjas.com>
 <4B3114E3.1070602@majjas.com> <4B329FA3.9090904@majjas.com>
 <20091223230102.4bb0100e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754357AbZLXTSI@vger.kernel.org>
In-reply-to: <20091223230102.4bb0100e.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'll be the first to admit I don't know much about network drivers... 
but I am wondering why __free_page(frag->page); is called in 
skb_put_frags when the fragment length is zero. I don't see why that 
page pointer wouldn't potentially be reused afterwords.


On 12/24/2009 2:01 AM, Andrew Morton wrote:
> cc's added again.
>
> On Wed, 23 Dec 2009 17:54:27 -0500 Michael Breuer<mbreuer@majjas.com>  wrote:
>
>    
>> Ok - not the firmware.  Ran another Windows backup and sky2 went down.
>>
>> Nothing in dmesg.old - have oops in syslog. System became unresponsive
>> and watchdog kicked in after a minute.
>>
>> Also note that I have a similar oops with VT-D disabled (posted here on
>> 12/5). I'm attaching the oops from that below this oops for comparison.
>> That also happened under similar load.
>>
>> On the assumption that I can recreate this (although it takes a while)
>> please let me know how I can help.
>>
>> What's in my log (starting with an smbd error about 2 min before the
>> oops (note: the dchpd is not the system doing the backup).
>>      
> This (nastily wordwrapped) oops appers to be quite different from
> Berck's one.
>
>
>
>    
>> Dec 23 17:31:05 mail smbd[20712]: [2009/12/23 17:31:05,  0]
>> smbd/nttrans.c:2076(call_nt_transact_ioctl)
>> Dec 23 17:31:05 mail smbd[20712]:   call_nt_transact_ioctl(0x900eb):
>> Currently not implemented.
>> Dec 23 17:31:34 mail clamd[3449]: SelfCheck: Database status OK.
>> Dec 23 17:32:22 mail named[4284]: client 208.78.169.235#32797: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:32:22 mail named[4284]: client 208.78.169.235#32797: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:32:22 mail named[4284]: client 208.78.169.235#32797: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:32:54 mail dhcpd: DHCPINFORM from 10.0.0.3 via eth0
>> Dec 23 17:32:54 mail dhcpd: DHCPACK to 10.0.0.3 (00:21:5d:cb:a1:74) via eth0
>> Dec 23 17:32:58 mail kernel: DRHD: handling fault status reg 2
>> Dec 23 17:32:58 mail kernel: DMAR:[DMA Read] Request device [06:00.0]
>> fault addr fff8423fe000
>> Dec 23 17:32:58 mail kernel: DMAR:[fault reason 06] PTE Read access is
>> not set
>> Dec 23 17:32:58 mail kernel: sky2 0000:06:00.0: error interrupt
>> status=0x80000000
>> Dec 23 17:32:58 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
>> Dec 23 17:33:06 mail kernel: ------------[ cut here ]------------
>> Dec 23 17:33:06 mail kernel: WARNING: at net/sched/sch_generic.c:255
>> dev_watchdog+0xf3/0x161()
>> Dec 23 17:33:06 mail kernel: Hardware name: System Product Name
>> Dec 23 17:33:06 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit
>> queue 0 timed out
>> Dec 23 17:33:06 mail kernel: Modules linked in: ip6table_filter
>> ip6table_mangle ip6_tables iptable_raw iptable_mangle ipt_MASQUERADE
>> iptable_nat nf_nat bridge stp appletalk psnap llc nfsd lockd nfs_acl
>> auth_rpcgss exportfs sunrpc hwmon_vid coretemp acpi_cpufreq sit tunnel4
>> ipt_LOG nf_conntrack_netbios_ns nf_conntrack_ftp xt_DSCP xt_dscp xt_MARK
>> nf_conntrack_ipv6 xt_multiport ipv6 dm_multipath kvm_intel kvm
>> snd_hda_codec_analog snd_ens1371 gameport snd_hda_intel snd_hda_codec
>> snd_rawmidi snd_ac97_codec ac97_bus snd_hwdep snd_seq snd_seq_device
>> snd_pcm snd_timer gspca_spca505 snd gspca_main soundcore snd_page_alloc
>> videodev firewire_ohci sky2 v4l1_compat v4l2_compat_ioctl32
>> firewire_core iTCO_wdt wmi asus_atk0110 iTCO_vendor_support i2c_i801
>> hwmon pcspkr crc_itu_t raid456 async_raid6_recov async_pq raid6_pq
>> async_xor xor async_memcpy async_tx raid1 ata_generic pata_acpi
>> pata_marvell nouveau ttm drm_kms_helper drm agpgart fb i2c_algo_bit
>> cfbcopyarea i2c_core cfbimgblt cfbfillrect [last unloaded: ip6_tables]
>> Dec 23 17:33:06 mail kernel: Pid: 0, comm: swapper Tainted: G        W
>> 2.6.32-09281-g1c42cda #6
>> Dec 23 17:33:06 mail kernel: Call Trace:
>> Dec 23 17:33:06 mail kernel:<IRQ>   [<ffffffff8104afbd>]
>> warn_slowpath_common+0x7c/0x94
>> Dec 23 17:33:06 mail kernel: [<ffffffff8104b02c>]
>> warn_slowpath_fmt+0x41/0x43
>> Dec 23 17:33:06 mail kernel: [<ffffffff813d096f>] ? netif_tx_lock+0x44/0x6c
>> Dec 23 17:33:06 mail kernel: [<ffffffff813d0ad7>] dev_watchdog+0xf3/0x161
>> Dec 23 17:33:06 mail kernel: [<ffffffff8105610c>] ? cascade+0x6a/0x84
>> Dec 23 17:33:06 mail kernel: [<ffffffff81058558>]
>> run_timer_softirq+0x1c8/0x270
>> Dec 23 17:33:06 mail kernel: [<ffffffff81051595>] __do_softirq+0xf8/0x1cd
>> Dec 23 17:33:06 mail kernel: [<ffffffff810720af>] ?
>> tick_program_event+0x2a/0x2c
>> Dec 23 17:33:06 mail kernel: [<ffffffff8100ab1c>] call_softirq+0x1c/0x30
>> Dec 23 17:33:06 mail kernel: [<ffffffff8100c2b3>] do_softirq+0x4b/0xa3
>> Dec 23 17:33:06 mail kernel: [<ffffffff81051181>] irq_exit+0x4a/0x8c
>> Dec 23 17:33:06 mail kernel: [<ffffffff8145ed99>]
>> smp_apic_timer_interrupt+0x86/0x94
>> Dec 23 17:33:06 mail kernel: [<ffffffff8100a5d3>]
>> apic_timer_interrupt+0x13/0x20
>> Dec 23 17:33:06 mail kernel:<EOI>   [<ffffffff812ae5fa>] ?
>> acpi_idle_enter_bm+0x256/0x28a
>> Dec 23 17:33:06 mail kernel: [<ffffffff812ae5f3>] ?
>> acpi_idle_enter_bm+0x24f/0x28a
>> Dec 23 17:33:06 mail kernel: [<ffffffff81393308>]
>> cpuidle_idle_call+0x9e/0xfa
>> Dec 23 17:33:06 mail kernel: [<ffffffff81008c05>] cpu_idle+0xb4/0xf6
>> Dec 23 17:33:06 mail kernel: [<ffffffff814532b2>]
>> start_secondary+0x201/0x242
>> Dec 23 17:33:06 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
>> Dec 23 17:33:06 mail kernel: sky2 eth0: tx timeout
>> Dec 23 17:33:06 mail kernel: sky2 eth0: disabling interface
>> Dec 23 17:33:06 mail kernel: sky2 eth0: enabling interface
>> Dec 23 17:33:06 mail NetworkManager:<info>   (eth0): carrier now OFF
>> (device state 1)
>> Dec 23 17:33:11 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
>> duplex, flow control both
>> Dec 23 17:33:11 mail NetworkManager:<info>   (eth0): carrier now ON
>> (device state 1)
>> Dec 23 17:33:26 mail kernel: sky2 eth0: tx timeout
>> Dec 23 17:33:26 mail kernel: sky2 eth0: disabling interface
>> Dec 23 17:33:26 mail kernel: sky2 eth0: enabling interface
>> Dec 23 17:33:26 mail NetworkManager:<info>   (eth0): carrier now OFF
>> (device state 1)
>> Dec 23 17:33:28 mail named[4284]: client 114.80.99.2#44695: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:33:28 mail named[4284]: client 114.80.99.2#44695: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:33:28 mail named[4284]: client 114.80.99.2#44695: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:33:29 mail named[4284]: client 114.80.99.2#44695: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:33:29 mail named[4284]: client 114.80.99.2#44695: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:33:29 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
>> duplex, flow control both
>> Dec 23 17:33:29 mail NetworkManager:<info>   (eth0): carrier now ON
>> (device state 1)
>> Dec 23 17:33:30 mail named[4284]: client 114.80.99.2#44695: view
>> External: query (cache) './NS/IN' denied
>> Dec 23 17:33:38 mail named[4284]: error (connection refused) resolving
>> '121.93.27.216.blackholes.mail-abuse.org/A/IN': 168.61.5.195#53
>> Dec 23 17:33:44 mail kernel: sky2 eth0: tx timeout
>> Dec 23 17:33:44 mail kernel: sky2 eth0: disabling interface
>> Dec 23 17:33:44 mail kernel: sky2 eth0: enabling interface
>> Dec 23 17:33:44 mail NetworkManager:<info>   (eth0): carrier now OFF
>> (device state 1)
>> Dec 23 17:33:49 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
>> duplex, flow control both
>> Dec 23 17:33:49 mail NetworkManager:<info>   (eth0): carrier now ON
>> (device state 1)
>> Dec 23 17:33:52 mail dhcpd: DHCPINFORM from 10.0.0.11 via eth0
>> Dec 23 17:33:52 mail dhcpd: DHCPACK to 10.0.0.11 (00:1a:92:8d:30:81) via
>> eth0
>> Dec 23 17:34:01 mail smbd[24783]: [2009/12/23 17:34:01,  0]
>> lib/util_sock.c:539(read_fd_with_timeout)
>> Dec 23 17:34:01 mail smbd[24783]: [2009/12/23 17:34:01,  0]
>> lib/util_sock.c:1491(get_peer_addr_internal)
>> Dec 23 17:34:01 mail smbd[24783]:   getpeername failed. Error was
>> Transport endpoint is not connected
>> Dec 23 17:34:01 mail smbd[24783]:   read_fd_with_timeout: client 0.0.0.0
>> read error = Connection reset by peer.
>> Dec 23 17:34:04 mail abrt: Kerneloops: Reported 1 kernel oopses to Abrt
>> Dec 23 17:34:04 mail abrtd: Directory 'kerneloops-1261607644-1' creation
>> detected
>> Dec 23 17:34:04 mail abrtd: Getting local universal unique identification
>> Dec 23 17:34:04 mail abrtd: New crash, saving
>> Dec 23 17:34:04 mail abrtd: Activation of plugin 'RunApp' was not
>> successful: Plugin 'RunApp' is not registered
>> Dec 23 17:34:04 mail kernel: sky2 eth0: tx timeout
>> Dec 23 17:34:04 mail kernel: sky2 eth0: disabling interface
>> Dec 23 17:34:04 mail kernel: sky2 eth0: enabling interface
>> Dec 23 17:34:04 mail NetworkManager:<info>   (eth0): carrier now OFF
>> (device state 1)
>> Dec 23 17:34:09 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
>> duplex, flow control both
>> Dec 23 17:34:09 mail NetworkManager:<info>   (eth0): carrier now ON
>> (device state 1)
>> Dec 23 17:34:11 mail logger: ping of potter failed
>> Dec 23 17:34:19 mail kernel: sky2 eth0: tx timeout
>> Dec 23 17:34:19 mail kernel: sky2 eth0: disabling interface
>> Dec 23 17:34:19 mail kernel: sky2 eth0: enabling interface
>> Dec 23 17:34:19 mail NetworkManager:<info>   (eth0): carrier now OFF
>> (device state 1)
>> Dec 23 17:34:22 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
>> duplex, flow control both
>> Dec 23 17:34:22 mail NetworkManager:<info>   (eth0): carrier now ON
>> (device state 1)
>> Dec 23 17:37:40 mail kernel: imklog 4.4.2, log source = /proc/kmsg started.
>>
>> Oops from 12/5 (no vt-d; no intel_iommu, firmware .12)
>>
>> Dec  5 11:27:41 mail kernel: ------------[ cut here ]------------
>> Dec  5 11:27:41 mail kernel: WARNING: at lib/dma-debug.c:898
>> check_sync+0xbd/0x426()
>> Dec  5 11:27:41 mail kernel: Hardware name: System Product Name
>> Dec  5 11:27:41 mail kernel: sky2 0000:06:00.0: DMA-API: device driver
>> tries to sync DMA memory it has not allocated [device
>> address=0x000000031a57e022] [size=66 bytes]
>> Dec  5 11:27:41 mail kernel: Modules linked in: bridge stp appletalk
>> psnap llc nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc hwmon_vid
>> coretemp acpi_cpufreq sit tunnel4 ipt_LOG ipt_MASQUERADE iptable_nat
>> nf_nat iptable_mangle iptable_raw nf_conntrack_netbios_ns
>> nf_conntrack_ftp nf_conntrack_ipv6 xt_multiport ip6table_filter xt_DSCP
>> xt_dscp xt_MARK ip6table_mangle ip6_tables ipv6 dm_multipath kvm_intel
>> kvm snd_hda_codec_analog snd_ens1371 gameport snd_rawmidi snd_ac97_codec
>> snd_hda_intel snd_hda_codec ac97_bus gspca_spca505 snd_hwdep snd_seq
>> snd_seq_device firewire_ohci gspca_main snd_pcm videodev firewire_core
>> sky2 snd_timer v4l1_compat wmi snd v4l2_compat_ioctl32 soundcore
>> crc_itu_t snd_page_alloc asus_atk0110 i2c_i801 iTCO_wdt
>> iTCO_vendor_support pcspkr hwmon raid456 async_raid6_recov async_pq
>> raid6_pq async_xor xor async_memcpy async_tx raid1 ata_generic pata_acpi
>> pata_marvell nouveau ttm drm_kms_helper drm agpgart fb i2c_algo_bit
>> cfbcopyarea i2c_core cfbimgblt cfbfillrect [last unloaded: scsi_wait_scan]
>> Dec  5 11:27:41 mail kernel: Pid: 0, comm: swapper Not tainted
>> 2.6.32-00573-g6cf4d67 #2
>> Dec  5 11:27:41 mail kernel: Call Trace:
>> Dec  5 11:27:41 mail kernel:<IRQ>   [<ffffffff8105365a>]
>> warn_slowpath_common+0x7c/0x94
>> Dec  5 11:27:41 mail kernel: [<ffffffff810536c9>]
>> warn_slowpath_fmt+0x41/0x43
>> Dec  5 11:27:41 mail kernel: [<ffffffff8127b1fd>] check_sync+0xbd/0x426
>> Dec  5 11:27:41 mail kernel: [<ffffffff813ca254>] ?
>> __netdev_alloc_skb+0x34/0x50
>> Dec  5 11:27:41 mail kernel: [<ffffffff8127b8b9>]
>> debug_dma_sync_single_for_cpu+0x42/0x44
>> Dec  5 11:27:41 mail kernel: [<ffffffff81278c5f>] ?
>> swiotlb_sync_single+0x2a/0xb6
>> Dec  5 11:27:41 mail kernel: [<ffffffff81278dbb>] ?
>> swiotlb_sync_single_for_cpu+0xc/0xe
>> Dec  5 11:27:41 mail kernel: [<ffffffffa01cee83>] sky2_poll+0x4c6/0xae1
>> [sky2]
>> Dec  5 11:27:41 mail kernel: [<ffffffff8146bb1a>] ?
>> _spin_unlock_irqrestore+0x29/0x41
>> Dec  5 11:27:41 mail kernel: [<ffffffff813d0ef2>] net_rx_action+0xb5/0x1f3
>> Dec  5 11:27:41 mail kernel: [<ffffffff8105ae3b>] __do_softirq+0xf8/0x1cd
>> Dec  5 11:27:41 mail kernel: [<ffffffff810a2dea>] ?
>> handle_IRQ_event+0x119/0x12b
>> Dec  5 11:27:41 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
>> Dec  5 11:27:41 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
>> Dec  5 11:27:41 mail kernel: [<ffffffff8105aa1b>] irq_exit+0x4a/0x8c
>> Dec  5 11:27:41 mail kernel: [<ffffffff8146fb75>] do_IRQ+0xa5/0xbc
>> Dec  5 11:27:41 mail kernel: [<ffffffff81012613>] ret_from_intr+0x0/0x16
>> Dec  5 11:27:41 mail kernel:<EOI>   [<ffffffff812c6b3e>] ?
>> acpi_idle_enter_bm+0x256/0x28a
>> Dec  5 11:27:41 mail kernel: [<ffffffff812c6b37>] ?
>> acpi_idle_enter_bm+0x24f/0x28a
>> Dec  5 11:27:41 mail kernel: [<ffffffff813a6280>] ?
>> cpuidle_idle_call+0x9e/0xfa
>> Dec  5 11:27:41 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
>> Dec  5 11:27:41 mail kernel: [<ffffffff814651f2>] ?
>> start_secondary+0x201/0x242
>> Dec  5 11:27:41 mail kernel: ---[ end trace ff8485ac82013a8d ]---
>> On 12/22/2009 01:50 PM, Michael Breuer wrote:
>>      
>>> I updated my firmware (Marvell/Yukon)) from .12 to .14. Going to leave
>>> my kernel version unchanged for the next week or so and see if this
>>> recurs.
>>> On 12/21/2009 7:09 PM, Michael Breuer wrote:
>>>        
>>>> Just an FYI - I got one of these today as well - also 2.6.32 (last
>>>> git before 2.6.33 rc1). I also had two similar events previously -
>>>> one 2.6.31, and one 2.6.32 rc7.
>>>>
>>>> I was doing some research today and came across a fair sampling of
>>>> error reports all suggesting that new firmware is a solution.
>>>> Gigabyte (not my MB) has firmware posted, but I haven't yet attempted
>>>> to apply it (nor am I sure how to test it after doing so).
>>>>
>>>> For what it's worth, my three recent events were heavy smb usage -
>>>> windows system backing up. Today's event did not generate an oops as
>>>> my watchdog kicked in and rebooted the system after the kernel
>>>> reported a sky2 error.
>>>>
>>>> The last messages before watchdog:
>>>> Dec 20 05:33:58 mail kernel: DRHD: handling fault status reg 2
>>>> Dec 20 05:33:58 mail kernel: DMAR:[DMA Read] Request device [06:00.0]
>>>> fault addr ffe1a7ffe000
>>>> Dec 20 05:33:58 mail kernel: DMAR:[fault reason 06] PTE Read access
>>>> is not set
>>>> Dec 20 05:33:58 mail kernel: sky2 0000:06:00.0: error interrupt
>>>> status=0x80000000
>>>> Dec 20 05:33:58 mail kernel: sky2 0000:06:00.0: PCI hardware error
>>>> (0x2010)
>>>>
>>>> During the previous event I had vt-d disabled - it was enabled this
>>>> time.
>>>>
>>>>
>>>> On 12/21/2009 6:52 PM, Berck E. Nash wrote:
>>>>          
>>>>> Since 2.6.32, I've been getting kernel panics under heavy network load
>>>>> (bittorrent usage).
>>>>>
>>>>> [ 8673.345873] sky2 eth0: receiver hang detected
>>>>> [ 8673.350368] sky2 eth0: disabling interface
>>>>> [ 8673.354749] BUG: unable to handle kernel NULL pointer dereference at
>>>>> 0000000000000010
>>>>> [ 8673.359748] IP: [<ffffffffa00373d3>] sky2_xmit_frame+0x321/0x5d8
>>>>> [sky2]
>>>>> [ 8673.364675] PGD a09a6067 PUD a09a5067 PMD 0
>>>>> [ 8673.373838] Oops: 0002 [#1] SMP
>>>>> [ 8673.373838] last sysfs file:
>>>>> /sys/devices/platform/coretemp.1/temp1_label
>>>>> [ 8673.383900] CPU 0
>>>>> [ 8673.383900] Modules linked in: nfsd exportfs nfs lockd nfs_acl
>>>>> auth_rpcgss sunrpc nls_cp437 msdos fat kvm_intel kvm fuse snd_rtctimer
>>>>> hwmon_vid nvidia(P) usbhid tuner_simple tuner_types wm8775 tda9887
>>>>> snd_hda_codec_realtek tda8290 snd_hda_intel tuner snd_hda_codec
>>>>> snd_pcm_oss snd_mixer_oss snd_pcm cx25840 snd_seq_dummy snd_seq_oss
>>>>> snd_seq_midi_event ivtv snd_seq i2c_algo_bit cx2341x v4l2_common
>>>>> snd_timer videodev uhci_hcd snd_seq_device v4l1_compat ehci_hcd snd
>>>>> v4l2_compat_ioctl32 i2c_i801 soundcore snd_page_alloc floppy sky2
>>>>> usbcore tveeprom
>>>>> [ 8673.435268] Pid: 4, comm: ksoftirqd/0 Tainted: P           2.6.32.1
>>>>> #3 P5W DH Deluxe
>>>>> [ 8673.438943] RIP: 0010:[<ffffffffa00373d3>]  [<ffffffffa00373d3>]
>>>>> sky2_xmit_frame+0x321/0x5d8 [sky2]
>>>>> [ 8673.448539] RSP: 0018:ffff880001603df8  EFLAGS: 00010246
>>>>> [ 8673.458678] RAX: 0000000000000000 RBX: ffff8800bd201d40 RCX:
>>>>> 0000000000000000
>>>>> [ 8673.465016] RDX: 0000000000000000 RSI: 000000000000008c RDI:
>>>>> 0000000000000000
>>>>> [ 8673.472396] RBP: ffff880001603e48 R08: 0000000000000001 R09:
>>>>> 0000000000000000
>>>>> [ 8673.474083] R10: 000000000000001e R11: 0000000000000ef8 R12:
>>>>> ffff88009bf3ab48
>>>>> [ 8673.484317] R13: ffff8800bef4d000 R14: 0000000000000000 R15:
>>>>> 00000000955fa87e
>>>>> [ 8673.492381] FS:  0000000000000000(0000) GS:ffff880001600000(0000)
>>>>> knlGS:0000000000000000
>>>>> [ 8673.501448] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
>>>>> [ 8673.509707] CR2: 0000000000000010 CR3: 00000000a09bf000 CR4:
>>>>> 00000000000026f0
>>>>> [ 8673.514146] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>>>>> 0000000000000000
>>>>> [ 8673.520661] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
>>>>> 0000000000000400
>>>>> [ 8673.528842] Process ksoftirqd/0 (pid: 4, threadinfo
>>>>> ffff8800bf8b4000,
>>>>> task ffff8800bf8a8650)
>>>>> [ 8673.539212] Stack:
>>>>> [ 8673.539212]  ffff8800992f5980 ffff8800955fa87e ffff8800bd201800
>>>>> 000000428122a659
>>>>> [ 8673.548658]<0>   ffff880001603e48 ffff88009bf3ab48 ffff8800992f5980
>>>>> ffffffff813eaf30
>>>>> [ 8673.556929]<0>   ffff8800bd201800 ffff8800bef03940 ffff880001603e98
>>>>> ffffffff81231de8
>>>>> [ 8673.565432] Call Trace:
>>>>> [ 8673.565432]<IRQ>
>>>>> [ 8673.565432]  [<ffffffff81231de8>] dev_hard_start_xmit+0x21c/0x2b7
>>>>> [ 8673.574516]  [<ffffffff81041746>] ? run_timer_softirq+0x4f/0x1c9
>>>>> [ 8673.579515]  [<ffffffff81240252>] sch_direct_xmit+0x5e/0x154
>>>>> [ 8673.584559]  [<ffffffff81240404>] __qdisc_run+0xbc/0xd5
>>>>> [ 8673.592673]  [<ffffffff8122fb19>] net_tx_action+0xbb/0x10e
>>>>> [ 8673.598719]  [<ffffffff8103dc16>] __do_softirq+0x91/0x11b
>>>>> [ 8673.601787]  [<ffffffff8100be9c>] call_softirq+0x1c/0x28
>>>>> [ 8673.609833]<EOI>
>>>>> [ 8673.610994]  [<ffffffff8100d907>] do_softirq+0x33/0x6b
>>>>> [ 8673.614419]  [<ffffffff8103d71e>] ksoftirqd+0x60/0xd7
>>>>> [ 8673.620082]  [<ffffffff8103d6be>] ? ksoftirqd+0x0/0xd7
>>>>> [ 8673.620082]  [<ffffffff8104aee7>] kthread+0x7a/0x82
>>>>> [ 8673.629310]  [<ffffffff8100bd9a>] child_rip+0xa/0x20
>>>>> [ 8673.634137]  [<ffffffff8104ae6d>] ? kthread+0x0/0x82
>>>>> [ 8673.639492]  [<ffffffff8100bd90>] ? child_rip+0x0/0x20
>>>>> [ 8673.647639] Code: 06 00 00 00 00 89 08 66 c7 40 04 00 00 c6 40 06 01
>>>>> c6 40 07 9f 41 0f b7 c6 48 89 c7 48 c1 e0 03 48 c1 e7 05 48 89 f9 48 03
>>>>> 4b 20<4c>   89 79 10 48 c7 41 08 01 00 00 00 8b 75 cc 89 71 18 48 03 7b
>>>>> [ 8673.667726] RIP  [<ffffffffa00373d3>] sky2_xmit_frame+0x321/0x5d8
>>>>> [sky2]
>>>>> [ 8673.674902]  RSP<ffff880001603df8>
>>>>> [ 8673.674902] CR2: 0000000000000010
>>>>> [ 8673.682956] hda-intel: IRQ timing workaround is activated for card
>>>>> #0. Suggest a bigger bdl_pos_adj.
>>>>> [ 8673.683015] ---[ end trace 2c387977cf1c7c9a ]---
>>>>> [ 8673.683017] Kernel panic - not syncing: Fatal exception in interrupt
>>>>> [ 8673.683020] Pid: 4, comm: ksoftirqd/0 Tainted: P      D
>>>>> 2.6.32.1 #3
>>>>> [ 8673.683021] Call Trace:
>>>>> [ 8673.683023]<IRQ>    [<ffffffff8129839d>] panic+0x75/0x11c
>>>>> [ 8673.683030]  [<ffffffff8100e9a7>] oops_end+0x81/0x8e
>>>>> [ 8673.683033]  [<ffffffff81026e5f>] no_context+0x1ee/0x1fd
>>>>> [ 8673.683036]  [<ffffffff81032a6d>] ? find_busiest_group+0x387/0x8d8
>>>>> [ 8673.683039]  [<ffffffff81026fe0>] __bad_area_nosemaphore+0x172/0x195
>>>>> [ 8673.683041]  [<ffffffff81027011>] bad_area_nosemaphore+0xe/0x10
>>>>> [ 8673.683044]  [<ffffffff8102724b>] do_page_fault+0x114/0x252
>>>>> [ 8673.683047]  [<ffffffff8129a97f>] page_fault+0x1f/0x30
>>>>> [ 8673.683054]  [<ffffffffa00373d3>] ? sky2_xmit_frame+0x321/0x5d8
>>>>> [sky2]
>>>>> [ 8673.683058]  [<ffffffffa00371b8>] ? sky2_xmit_frame+0x106/0x5d8
>>>>> [sky2]
>>>>> [ 8673.683061]  [<ffffffff81231de8>] dev_hard_start_xmit+0x21c/0x2b7
>>>>> [ 8673.683065]  [<ffffffff81041746>] ? run_timer_softirq+0x4f/0x1c9
>>>>> [ 8673.683067]  [<ffffffff81240252>] sch_direct_xmit+0x5e/0x154
>>>>> [ 8673.683070]  [<ffffffff81240404>] __qdisc_run+0xbc/0xd5
>>>>> [ 8673.683072]  [<ffffffff8122fb19>] net_tx_action+0xbb/0x10e
>>>>> [ 8673.683075]  [<ffffffff8103dc16>] __do_softirq+0x91/0x11b
>>>>> [ 8673.683078]  [<ffffffff8100be9c>] call_softirq+0x1c/0x28
>>>>> [ 8673.683079]<EOI>    [<ffffffff8100d907>] do_softirq+0x33/0x6b
>>>>> [ 8673.683083]  [<ffffffff8103d71e>] ksoftirqd+0x60/0xd7
>>>>> [ 8673.683085]  [<ffffffff8103d6be>] ? ksoftirqd+0x0/0xd7
>>>>> [ 8673.683088]  [<ffffffff8104aee7>] kthread+0x7a/0x82
>>>>> [ 8673.683090]  [<ffffffff8100bd9a>] child_rip+0xa/0x20
>>>>> [ 8673.683093]  [<ffffffff8104ae6d>] ? kthread+0x0/0x82
>>>>> [ 8673.683095]  [<ffffffff8100bd90>] ? child_rip+0x0/0x20
>>>>>
>>>>> Note that sometimes I get the receiver hang and things continue without
>>>>> the crash:
>>>>>
>>>>> [ 1219.346571] sky2 eth0: receiver hang detected
>>>>> [ 1219.351145] sky2 eth0: disabling interface
>>>>> [ 1219.357389] sky2 eth0: enabling interface
>>>>> [ 1222.572980] sky2 eth0: Link is up at 1000 Mbps, full duplex, flow
>>>>> control both
>>>>>
>>>>> Please CC as I'm not subscribed.
>>>>>
>>>>> Thanks,
>>>>> Berck Nash
>>>>> -- 
>>>>> To unsubscribe from this list
>>>>>            
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe
>>> linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>        
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>      
