From: Frantisek Hanzlik <franta@hanzlici.cz>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e()
 with tg3 network
Date: Thu, 27 Nov 2008 11:06:58 +0100
Message-ID: <492E7142.3030002@hanzlici.cz>
References: <20081120184310.GB27712@xw6200.broadcom.net> <20081120212637.GB23844@1wt.eu> <20081120215318.GB27907@xw6200.broadcom.net> <20081124132744.GB24851@1wt.eu> <20081124215247.GA29696@1wt.eu> <20081125015223.GA9151@xw6200.broadcom.net> <20081125053128.GA32426@1wt.eu> <20081125175413.GA9808@xw6200.broadcom.net> <20081126211220.GA22374@1wt.eu> <20081126225421.GA8906@xw6200.broadcom.net> <20081127051659.GA26057@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Roger Heflin <rogerheflin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754512AbYK0KIT@vger.kernel.org>
In-Reply-To: <20081127051659.GA26057@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Willy Tarreau wrote:
> On Wed, Nov 26, 2008 at 02:54:21PM -0800, Matt Carlson wrote:
> (...)
>>> I've run a new test on a switch I have here at home (another el-cheapo,
>>> non-manageable 100 Mbps, netgear this time). Unfortunately I cannot
>>> reproduce the problem at all. I have disabled FC on my laptop, it did
>>> not have any effect.
>> Disabling FC should have a positive effect, not a negative one.  It
>> might be the case that the switch does not advertise nor support FC.  If
>> that is true, you might not be able to repro the problem no matter what
>> you did (if your problem is what I think it is).  Can you check your
>> link messages and see if it really is negotiated to off?  (I see the
>> message above, but I don't think that is with the current switch.)
>
> yes the switch does advertuse FC :
>
> willy@wtap:~$ dmesg|grep eth0
> eth0: Tigon3 [partno(BMC5705mA3) rev 3003 PHY(5705)] (PCI:33MHz:32-bit) 10/100/1000Base-T Ethernet 00:0d:9d:91:ef:24
> eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
> eth0: dma_rwctrl[763f0000] dma_mask[64-bit]
> tg3: eth0: Link is up at 100 Mbps, full duplex.
> tg3: eth0: Flow control is on for TX and on for RX.
>
>>> I have disabled auto-neg and manually forced the
>>> speed to 100/Full on my laptop, and could not reproduce the problem
>>> either (though the speed was much lower due to the switch obviously
>>> negociating 100/Half when not seeing my NWay frames).
>> Yes.  If you force the link, both sides must be forced.  The switch
>> rightly assumes HD when bringing the link up.
>
> I know ;-) but not seeing the problem, I started to suspect that the other
> switch was a little bit ill and tried to reproduce some problems I might
> incidently have been encountering on it.
>
> Regards,
> Willy
>
I got same issue two days ago on PCI-X Fiber 1000BASE-SX D-Link Adapter
DGE-550SX/dl2k driver (I report it yesterday). This card work fine in
old DEC Alphaserver 800/Fedora Core 5/kernel 2.6.17. We use it for our
internet connections, which is limited to approx. 50 Mb/sec by ISP,
then I think there should be no bottleneck in LAN card.
We just tried install new i386 based router (Core2Duo E8500/4GB RAM/
4x Realtek 8111C and this D-Link from old Alphaserver, on Fedora 10,
kernel 2.6.27.5). Router is connected to several gigabit backbones
over other ois gigabit cards, then I'm not sure when any crapped internal
machines could overload this DGE-550SX. Card in new router stop working
after several secs/minutes - packed transmitting freeze (what is
interesting, in one case after it sent exactly 8192 packets, and other
cases are some multiples of 8 too) and stop transmit packets.
Only workaround (but for a while) is rmmod + modprobe its dl2k driver.

/var/log/messages contains following messages:

...
Nov 25 19:04:52 ns kernel: Sundance Technology IPG Triple-Speed Ethernet 0000:09:00.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
Nov 25 19:04:52 ns kernel: 0000:09:00.0: D-Link NIC
...
Nov 25 19:05:12 ns kernel: ------------[ cut here ]------------
Nov 25 19:05:12 ns kernel: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xda/0x12d()
Nov 25 19:05:12 ns kernel: NETDEV WATCHDOG: eth1 (Sundance Technology IPG Triple-Speed Ethernet): transmit timed out
Nov 25 19:05:12 ns kernel: Modules linked in: hwmon_vid hwmon nf_nat_ftp nf_conntrack_ftp xt_comment iptable_nat nf_nat cpufreq_ondemand acpi_cpufreq dm_multipath uinput snd_hda_intel 
snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device dl2k snd_pcm_oss snd_mixer_oss snd_pcm ipg snd_timer snd_page_alloc snd_hwdep snd i2c_i801 firewire_ohci i2c_core 
soundcore pcspkr r8169 mii firewire_core crc_itu_t raid456 async_xor async_memcpy async_tx xor raid1 [last unloaded: microcode]
Nov 25 19:05:12 ns kernel: Pid: 0, comm: swapper Not tainted 2.6.27.5-117.fc10.i686 #1
Nov 25 19:05:12 ns kernel: [<c042bb3a>] warn_slowpath+0x4b/0x6c
Nov 25 19:05:12 ns kernel: [<c046fb00>] ? mempool_resize+0x15c/0x183
Nov 25 19:05:12 ns kernel: [<c048ca25>] ? __slab_free+0x63/0x26e
Nov 25 19:05:12 ns kernel: [<c048ce4e>] ? kmem_cache_free+0x71/0xa7
Nov 25 19:05:12 ns kernel: [<c048ca25>] ? __slab_free+0x63/0x26e
Nov 25 19:05:12 ns kernel: [<c050cb98>] ? blk_remove_plug+0x66/0x92
Nov 25 19:05:12 ns kernel: [<c050a19f>] ? elv_queue_empty+0x20/0x22
Nov 25 19:05:12 ns kernel: [<c050d29a>] ? blk_run_queue+0x28/0x2c
Nov 25 19:05:12 ns kernel: [<c059f8c5>] ? scsi_run_queue+0x250/0x27c
Nov 25 19:05:12 ns kernel: [<c0518eb6>] ? kobject_put+0x37/0x3c
Nov 25 19:05:12 ns kernel: [<c051bf6e>] ? strlcpy+0x17/0x49
Nov 25 19:05:12 ns kernel: [<c063e554>] dev_watchdog+0xda/0x12d
Nov 25 19:05:12 ns kernel: [<c05a0cef>] ? scsi_device_unbusy+0x6b/0x70
Nov 25 19:05:12 ns kernel: [<c04341f5>] run_timer_softirq+0x14b/0x1bb
Nov 25 19:05:12 ns kernel: [<c063e47a>] ? dev_watchdog+0x0/0x12d
Nov 25 19:05:12 ns kernel: [<c063e47a>] ? dev_watchdog+0x0/0x12d
Nov 25 19:05:12 ns kernel: [<c043076f>] __do_softirq+0x84/0x109
Nov 25 19:05:12 ns kernel: [<c04306eb>] ? __do_softirq+0x0/0x109
Nov 25 19:05:12 ns kernel: [<c0405eec>] do_softirq+0x77/0xdb
Nov 25 19:05:12 ns kernel: [<c04640bb>] ? handle_fasteoi_irq+0x0/0xc0
Nov 25 19:05:12 ns kernel: [<c04303d6>] irq_exit+0x44/0x83
Nov 25 19:05:12 ns kernel: [<c0405e5e>] do_IRQ+0xe7/0xfe
Nov 25 19:05:12 ns kernel: [<c0404654>] common_interrupt+0x28/0x30
Nov 25 19:05:12 ns kernel: [<c0564b95>] ? acpi_idle_enter_simple+0x162/0x19d
Nov 25 19:05:12 ns kernel: [<c0613efd>] cpuidle_idle_call+0x67/0x97
Nov 25 19:05:12 ns kernel: [<c0402c4d>] cpu_idle+0x101/0x134
Nov 25 19:05:12 ns kernel: [<c06a32de>] start_secondary+0x197/0x19f
Nov 25 19:05:12 ns kernel: =======================
Nov 25 19:05:12 ns kernel: ---[ end trace fd7fa9607e312047 ]---

=====

Nov 25 19:29:33 ns kernel: ------------[ cut here ]------------
Nov 25 19:29:33 ns kernel: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xda/0x12d()
Nov 25 19:29:33 ns kernel: NETDEV WATCHDOG: eth1 (Sundance Technology IPG Triple-Speed Ethernet): transmit timed out
Nov 25 19:29:33 ns kernel: Modules linked in: hwmon_vid hwmon nf_nat_ftp nf_conntrack_ftp xt_comment iptable_nat nf_nat cpufreq_ondemand acpi_cpufreq dm_multipath uinput dl2k i2c_i801 pcspkr 
r8169 ipg mii i2c_core firewire_ohci firewire_core crc_itu_t raid456 async_xor async_memcpy async_tx xor raid1 [last unloaded: microcode]
Nov 25 19:29:33 ns kernel: Pid: 9941, comm: mail Not tainted 2.6.27.5-117.fc10.i686 #1
Nov 25 19:29:33 ns kernel: [<c042bb3a>] warn_slowpath+0x4b/0x6c
Nov 25 19:29:33 ns kernel: [<c046fb00>] ? mempool_resize+0x15c/0x183
Nov 25 19:29:33 ns kernel: [<c04b0b3b>] ? bio_free+0x40/0x44
Nov 25 19:29:33 ns kernel: [<c04b0b4d>] ? bio_fs_destructor+0xe/0x11
Nov 25 19:29:33 ns kernel: [<c04af8a5>] ? bio_put+0x26/0x28
Nov 25 19:29:33 ns kernel: [<c048a971>] ? virt_to_head_page+0x22/0x2e
Nov 25 19:29:33 ns kernel: [<c050c0d4>] ? queue_flag_clear+0x18/0x54
Nov 25 19:29:33 ns kernel: [<c050c17b>] ? __freed_request+0x6b/0x72
Nov 25 19:29:33 ns kernel: [<c0420940>] ? __enqueue_entity+0xe3/0xeb
Nov 25 19:29:33 ns kernel: [<c04223aa>] ? enqueue_entity+0x203/0x20b
Nov 25 19:29:33 ns kernel: [<c051bf6e>] ? strlcpy+0x17/0x49
Nov 25 19:29:33 ns kernel: [<c063e554>] dev_watchdog+0xda/0x12d
Nov 25 19:29:33 ns kernel: [<c0405e5e>] ? do_IRQ+0xe7/0xfe
Nov 25 19:29:33 ns kernel: [<c04341f5>] run_timer_softirq+0x14b/0x1bb
Nov 25 19:29:33 ns kernel: [<c063e47a>] ? dev_watchdog+0x0/0x12d
Nov 25 19:29:33 ns kernel: [<c063e47a>] ? dev_watchdog+0x0/0x12d
Nov 25 19:29:33 ns kernel: [<c043076f>] __do_softirq+0x84/0x109
Nov 25 19:29:33 ns kernel: [<c04306eb>] ? __do_softirq+0x0/0x109
Nov 25 19:29:33 ns kernel: [<c0405eec>] do_softirq+0x77/0xdb
Nov 25 19:29:33 ns kernel: [<c04303d6>] irq_exit+0x44/0x83
Nov 25 19:29:33 ns kernel: [<c0413ee9>] smp_apic_timer_interrupt+0x6e/0x7c
Nov 25 19:29:33 ns kernel: [<c0404759>] apic_timer_interrupt+0x2d/0x34
Nov 25 19:29:33 ns kernel: [<c041007b>] ? speedstep_target+0x23/0x7e
Nov 25 19:29:33 ns kernel: [<c0419e89>] ? native_flush_tlb_single+0x6/0x8
Nov 25 19:29:33 ns kernel: [<c041d37d>] kunmap_atomic+0x67/0xa7
Nov 25 19:29:33 ns kernel: [<c047a368>] follow_page+0x1c5/0x23b
Nov 25 19:29:33 ns kernel: [<c047b98e>] get_user_pages+0x289/0x2fe
Nov 25 19:29:33 ns kernel: [<c0493d9e>] get_arg_page+0x2d/0x80
Nov 25 19:29:33 ns kernel: [<c051dcb9>] ? strnlen_user+0x2f/0x4d
Nov 25 19:29:33 ns kernel: [<c0493eb4>] copy_strings+0xc3/0x160
Nov 25 19:29:33 ns kernel: [<c0495079>] do_execve+0x14e/0x215
Nov 25 19:29:33 ns kernel: [<c04023a3>] sys_execve+0x29/0x50
Nov 25 19:29:33 ns kernel: [<c0403c76>] syscall_call+0x7/0xb
Nov 25 19:29:33 ns kernel: [<c06a007b>] ? init_intel_cacheinfo+0x0/0x421
Nov 25 19:29:33 ns kernel: =======================
Nov 25 19:29:33 ns kernel: ---[ end trace 45c41aa8555c94fa ]---

=====

Nov 25 19:41:00 ns kernel: ------------[ cut here ]------------
Nov 25 19:41:00 ns kernel: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xda/0x12d()
Nov 25 19:41:00 ns kernel: NETDEV WATCHDOG: eth1 (Sundance Technology IPG Triple-Speed Ethernet): transmit timed out
Nov 25 19:41:00 ns kernel: Modules linked in: hwmon_vid hwmon nf_nat_ftp nf_conntrack_ftp xt_comment iptable_nat nf_nat cpufreq_ondemand acpi_cpufreq dm_multipath uinput dl2k ipg 
firewire_ohci firewire_core crc_itu_t pcspkr r8169 mii i2c_i801 i2c_core raid456 async_xor async_memcpy async_tx xor raid1 [last unloaded: microcode]
Nov 25 19:41:00 ns kernel: Pid: 0, comm: swapper Not tainted 2.6.27.5-117.fc10.i686 #1
Nov 25 19:41:00 ns kernel: [<c042bb3a>] warn_slowpath+0x4b/0x6c
Nov 25 19:41:00 ns kernel: [<c0420900>] ? __enqueue_entity+0xa3/0xeb
Nov 25 19:41:00 ns kernel: [<c04223aa>] ? enqueue_entity+0x203/0x20b
Nov 25 19:41:00 ns kernel: [<c04223ed>] ? enqueue_task_fair+0x3b/0x3f
Nov 25 19:41:00 ns kernel: [<c041d92c>] ? resched_task+0x3a/0x6e
Nov 25 19:41:00 ns kernel: [<c06a76b3>] ? _spin_unlock_irqrestore+0x22/0x38
Nov 25 19:41:00 ns kernel: [<c0426237>] ? try_to_wake_up+0x221/0x22b
Nov 25 19:41:00 ns kernel: [<c06a77cc>] ? _spin_lock_irqsave+0x29/0x30
Nov 25 19:41:00 ns kernel: [<c051bf6e>] ? strlcpy+0x17/0x49
Nov 25 19:41:00 ns kernel: [<c063e554>] dev_watchdog+0xda/0x12d
Nov 25 19:41:00 ns kernel: [<c043a716>] ? __queue_work+0x26/0x2b
Nov 25 19:41:00 ns kernel: [<c04341f5>] run_timer_softirq+0x14b/0x1bb
Nov 25 19:41:00 ns kernel: [<c063e47a>] ? dev_watchdog+0x0/0x12d
Nov 25 19:41:00 ns kernel: [<c063e47a>] ? dev_watchdog+0x0/0x12d
Nov 25 19:41:00 ns kernel: [<c043076f>] __do_softirq+0x84/0x109
Nov 25 19:41:00 ns kernel: [<c04306eb>] ? __do_softirq+0x0/0x109
Nov 25 19:41:00 ns kernel: [<c0405eec>] do_softirq+0x77/0xdb
Nov 25 19:41:00 ns kernel: [<c04303d6>] irq_exit+0x44/0x83
Nov 25 19:41:00 ns kernel: [<c0413ee9>] smp_apic_timer_interrupt+0x6e/0x7c
Nov 25 19:41:00 ns kernel: [<c0404759>] apic_timer_interrupt+0x2d/0x34
Nov 25 19:41:00 ns kernel: [<c05649e4>] ? acpi_idle_enter_bm+0x277/0x2c6
Nov 25 19:41:00 ns kernel: [<c0613efd>] cpuidle_idle_call+0x67/0x97
Nov 25 19:41:00 ns kernel: [<c0402c4d>] cpu_idle+0x101/0x134
Nov 25 19:41:00 ns kernel: [<c0697406>] rest_init+0x4e/0x50
Nov 25 19:41:00 ns kernel: =======================
Nov 25 19:41:00 ns kernel: ---[ end trace 9ce93cc9159b5214 ]---

It's there any thing for help with it?

Thx, Franta Hanzlik
