From: Dave Jones <davej@redhat.com>
Subject: __pskb_pull_tail oops from 2.6.35
Date: Tue, 27 Sep 2011 16:03:28 -0400
Message-ID: <20110927200328.GA22678@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752329Ab1I0UDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Sep 2011 16:03:31 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8RK3U8K008418
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 16:03:30 -0400
Received: from gelk.kernelslacker.org (ovpn-113-90.phx2.redhat.com [10.3.113.90])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8RK3TVg024221
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 16:03:30 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.4) with ESMTP id p8RK3STs026885
	for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 16:03:28 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id p8RK3SwV026884
	for netdev@vger.kernel.org; Tue, 27 Sep 2011 16:03:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user just reported this on a fairly old kernel (running the latest -longterm patch).
I had a look through net/core/skbuff.c since 2.6.35, and didn't see anything obvious.
Does this look familiar to anyone ? 

	Dave

 > I disabled the nvidia kernel module, booted into run level 3, and kicked off an
 > fsck of the ext3 partition on the XL2000. It panic'ed pretty quickly and this
 > was the result:
 > 
 > # crash /var/crash/2011-09-27-20\:04/vmcore /usr/lib/debug/lib/modules/`uname -r`/vmlinux
 > 
 > crash 5.0.6-2.fc14
 > Copyright (C) 2002-2010  Red Hat, Inc.
 > Copyright (C) 2004, 2005, 2006  IBM Corporation
 > Copyright (C) 1999-2006  Hewlett-Packard Co
 > Copyright (C) 2005, 2006  Fujitsu Limited
 > Copyright (C) 2006, 2007  VA Linux Systems Japan K.K.
 > Copyright (C) 2005  NEC Corporation
 > Copyright (C) 1999, 2002, 2007  Silicon Graphics, Inc.
 > Copyright (C) 1999, 2000, 2001, 2002  Mission Critical Linux, Inc.
 > This program is free software, covered by the GNU General Public License,
 > and you are welcome to change it and/or distribute copies of it under
 > certain conditions.  Enter "help copying" to see the conditions.
 > This program has absolutely no warranty.  Enter "help warranty" for details.
 > 
 > GNU gdb (GDB) 7.0
 > Copyright (C) 2009 Free Software Foundation, Inc.
 > License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
 > This is free software: you are free to change and redistribute it.
 > There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
 > and "show warranty" for details.
 > This GDB was configured as "x86_64-unknown-linux-gnu"...
 > 
 >       KERNEL: /usr/lib/debug/lib/modules/2.6.35.14-96.fc14.x86_64/vmlinux
 >     DUMPFILE: /var/crash/2011-09-27-20:04/vmcore
 >         CPUS: 4
 >         DATE: Tue Sep 27 20:02:02 2011
 >       UPTIME: 00:04:22
 > LOAD AVERAGE: 1.80, 0.87, 0.35
 >        TASKS: 312
 >     NODENAME: mythtv.xxx.xxx.xxx
 >      RELEASE: 2.6.35.14-96.fc14.x86_64
 >      VERSION: #1 SMP Thu Sep 1 11:59:56 UTC 2011
 >      MACHINE: x86_64  (2809 Mhz)
 >       MEMORY: 4 GB
 >        PANIC: "[  262.575493] Oops: 0000 [#1] SMP " (check log for details)
 >          PID: 0
 >      COMMAND: "swapper"
 >         TASK: ffffffff81a4a020  (1 of 4)  [THREAD_INFO: ffffffff81a00000]
 >          CPU: 0
 >        STATE: TASK_RUNNING (PANIC)
 > 
 > crash> bt
 > PID: 0      TASK: ffffffff81a4a020  CPU: 0   COMMAND: "swapper"
 >  #0 [ffff88000a203ba8] __pskb_pull_tail at ffffffff813b8e02
 >  #1 [ffff88000a203bf8] dev_queue_xmit at ffffffff813c2e46
 >  #2 [ffff88000a203c38] ip_finish_output2 at ffffffff813f557c
 >  #3 [ffff88000a203c68] ip_finish_output at ffffffff813f5621
 >  #4 [ffff88000a203c88] ip_output at ffffffff813f5e48
 >  #5 [ffff88000a203ca8] ip_forward_finish at ffffffff813f35dd
 >  #6 [ffff88000a203cc8] ip_forward at ffffffff813f38ba
 >  #7 [ffff88000a203d08] ip_rcv_finish at ffffffff813f2171
 >  #8 [ffff88000a203d48] NF_HOOK.clone.8 at ffffffff813f2412
 >  #9 [ffff88000a203d78] ip_rcv at ffffffff813f27a1
 > #10 [ffff88000a203da8] __netif_receive_skb at ffffffff813bf812
 > #11 [ffff88000a203e08] process_backlog at ffffffff813c1064
 > #12 [ffff88000a203e68] net_rx_action at ffffffff813c11e6
 > #13 [ffff88000a203ec8] __do_softirq at ffffffff81053db9
 > #14 [ffff88000a203f38] call_softirq at ffffffff8100ab9c
 > #15 [ffff88000a203f50] do_softirq at ffffffff8100c2f8
 > #16 [ffff88000a203f70] irq_exit at ffffffff81053f45
 > #17 [ffff88000a203f80] do_IRQ at ffffffff814715c5
 > --- <IRQ stack> ---
 > #18 [ffffffff81a01db8] ret_from_intr at ffffffff8146bad3
 >     [exception RIP: intel_idle+273]
 >     RIP: ffffffff81265bfc  RSP: ffffffff81a01e68  RFLAGS: 00000206
 >     RAX: 0000000000000000  RBX: ffffffff81a01ec8  RCX: 00000000000000bb
 >     RDX: 00000000000000bb  RSI: 0000000000000000  RDI: 00000000000003e8
 >     RBP: ffffffff8146bace   R8: 0000000000000000   R9: 00000000000002b3
 >     R10: 0000003d2d072cee  R11: 0000000000000000  R12: 0000000000000000
 >     R13: ffffffff81a01df8  R14: ffffffff8146ea81  R15: ffffffff81a01df8
 >     ORIG_RAX: ffffffffffffff86  CS: 0010  SS: 0018
 > #19 [ffffffff81a01ed0] cpuidle_idle_call at ffffffff813955b5
 > #20 [ffffffff81a01ef0] cpu_idle at ffffffff8100830b
 > 
 > # tail -64 /var/crash/2011-09-27-20\:04/dmesg 
 > <1>[  262.574738] BUG: unable to handle kernel NULL pointer dereference at (null)
 > <1>[  262.574991] IP: [<ffffffff810dca57>] put_page+0x10/0x7c
 > <4>[  262.575213] PGD 10fd81067 PUD 10fe18067 PMD 0 
 > <0>[  262.575493] Oops: 0000 [#1] SMP 
 > <0>[  262.575736] last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
 > <4>[  262.576067] CPU 0 
 > <4>[  262.576106] Modules linked in: nfsd lockd nfs_acl auth_rpcgss exportfs
 > coretemp sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf nf_nat_irc
 > nf_conntrack_irc nf_nat_ftp nf_conntrack_ftp xt_limit ipt_LOG iptable_mangle
 > ipt_MASQUERADE iptable_nat nf_nat ip6t_REJECT nf_conntrack_ipv6 ip6table_filter
 > ip6_tables ipv6 jfs uinput dvb_pll cx22702 cx88_dvb cx88_vp3054_i2c
 > videobuf_dvb rc_hauppauge_new mt2060 snd_hda_codec_via ir_lirc_codec cx8800
 > dvb_usb_dib0700 cx8802 lirc_dev cx88xx snd_hda_intel dib7000p dib0090 dib7000m
 > dib0070 ir_sony_decoder snd_hda_codec dvb_usb ir_jvc_decoder dib8000
 > ir_rc6_decoder dib9000 ir_rc5_decoder dvb_core ir_nec_decoder dib3000mc rc_core
 > snd_hwdep dibx000_common snd_seq snd_seq_device i2c_algo_bit tveeprom
 > v4l2_common videodev microcode snd_pcm v4l2_compat_ioctl32 snd_timer sundance
 > videobuf_dma_sg snd shpchp btcx_risc videobuf_core soundcore snd_page_alloc
 > iTCO_wdt iTCO_vendor_support i2c_i801 i2c_core r8169 mii asus_atk0110 joydev
 > raid1 usb_storage [last unloaded: scsi_wait_scan]
 > <4>[  262.581273] 
 > <4>[  262.581450] Pid: 0, comm: swapper Tainted: G          I 2.6.35.14-96.fc14.x86_64 #1 P7H55/System Product Name
 > <4>[  262.581785] RIP: 0010:[<ffffffff810dca57>]  [<ffffffff810dca57>] put_page+0x10/0x7c
 > <4>[  262.582147] RSP: 0018:ffff88000a203b80  EFLAGS: 00010246
 > <4>[  262.582332] RAX: 0000000000000030 RBX: ffff88012115fd00 RCX: ffff880120859670
 > <4>[  262.582519] RDX: ffff880120859640 RSI: 1506b29c96c716b9 RDI: 0000000000000000
 > <4>[  262.582707] RBP: ffff88000a203ba0 R08: ffff880127f2da58 R09: ffff880120859042
 > <4>[  262.582895] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
 > <4>[  262.583083] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
 > <4>[  262.583272] FS:  0000000000000000(0000) GS:ffff88000a200000(0000) knlGS:0000000000000000
 > <4>[  262.583601] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 > <4>[  262.583786] CR2: 0000000000000000 CR3: 000000010fd65000 CR4: 00000000000006f0
 > <4>[  262.583974] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 > <4>[  262.584162] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 > <4>[  262.584351] Process swapper (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a4a020)
 > <0>[  262.584679] Stack:
 > <4>[  262.584855]  ffff88012115fd00 0000000000000000 0000000000000000 0000000000000000
 > <4>[  262.585140] <0> ffff88000a203bf0 ffffffff813b8e02 0000001400000000 0000000000000030
 > <4>[  262.585631] <0> 9b07280a0002bb01 ffff88012115fd00 ffff88012a538000 ffff8800b7851800
 > <0>[  262.586289] Call Trace:
 > <0>[  262.586466]  <IRQ> 
 > <4>[  262.586679]  [<ffffffff813b8e02>] __pskb_pull_tail+0x1e1/0x293
 > <4>[  262.586867]  [<ffffffff813c2e46>] dev_queue_xmit+0x70/0x3ce
 > <4>[  262.587057]  [<ffffffff813f55bc>] ? ip_finish_output+0x0/0x6a
 > <4>[  262.587245]  [<ffffffff813f557c>] ip_finish_output2+0x1d6/0x216
 > <4>[  262.587468]  [<ffffffff813f5621>] ip_finish_output+0x65/0x6a
 > <4>[  262.587654]  [<ffffffff813f5e48>] ip_output+0x91/0x96
 > <4>[  262.587841]  [<ffffffff813f35dd>] ip_forward_finish+0x49/0x4d
 > <4>[  262.588028]  [<ffffffff813f38ba>] ip_forward+0x2d9/0x347
 > <4>[  262.588215]  [<ffffffff813f2171>] ip_rcv_finish+0x324/0x34a
 > <4>[  262.588402]  [<ffffffff813f1e4d>] ? ip_rcv_finish+0x0/0x34a
 > <4>[  262.588588]  [<ffffffff813f2412>] NF_HOOK.clone.8+0x51/0x58
 > <4>[  262.588775]  [<ffffffff813f27a1>] ip_rcv+0x21e/0x24d
 > <4>[  262.588962]  [<ffffffff813bf812>] __netif_receive_skb+0x3ed/0x412
 > <4>[  262.589151]  [<ffffffff813c1064>] process_backlog+0x87/0x15d
 > <4>[  262.589338]  [<ffffffff813c11e6>] net_rx_action+0xac/0x1bb
 > <4>[  262.589527]  [<ffffffff81053db9>] __do_softirq+0xf0/0x1bf
 > <4>[  262.589715]  [<ffffffff81023795>] ? apic_write+0x16/0x18
 > <4>[  262.589902]  [<ffffffff8101054b>] ? native_sched_clock+0x35/0x37
 > <4>[  262.590090]  [<ffffffff8100ab9c>] call_softirq+0x1c/0x30
 > <4>[  262.590276]  [<ffffffff8100c2f8>] do_softirq+0x46/0x82
 > <4>[  262.590462]  [<ffffffff81053f45>] irq_exit+0x49/0x8b
 > <4>[  262.590647]  [<ffffffff814715c5>] do_IRQ+0x9d/0xb4
 > <4>[  262.590835]  [<ffffffff8146bad3>] ret_from_intr+0x0/0x11
 > <0>[  262.591018]  <EOI> 
 > <4>[  262.591233]  [<ffffffff81265bfc>] ? intel_idle+0x111/0x139
 > <4>[  262.591419]  [<ffffffff81265bdb>] ? intel_idle+0xf0/0x139
 > <4>[  262.591607]  [<ffffffff813955b5>] cpuidle_idle_call+0x8b/0xe9
 > <4>[  262.591795]  [<ffffffff8100830b>] cpu_idle+0xaa/0xcc
 > <4>[  262.591982]  [<ffffffff81453186>] rest_init+0x8a/0x8c
 > <4>[  262.592169]  [<ffffffff81ba1c49>] start_kernel+0x40b/0x416
 > <4>[  262.592357]  [<ffffffff81ba12c6>] x86_64_start_reservations+0xb1/0xb5
 > <4>[  262.592546]  [<ffffffff81ba13c2>] x86_64_start_kernel+0xf8/0x107
 > <0>[  262.592731] Code: c1 e8 35 48 c1 ea 37 83 e0 03 48 69 c0 00 07 00 00 48 03 04 d5 70 0e b8 81 c9 c3 55 48 89 e5 41 56 41 55 41 54 53 0f 1f 44 00 00 <48> f7 07 00 c0 00 00 48 89 fb 74 07 e8 3f fe ff ff eb 50 e8 c5 
 > <1>[  262.595307] RIP  [<ffffffff810dca57>] put_page+0x10/0x7c
 > <4>[  262.595524]  RSP <ffff88000a203b80>
 > <0>[  262.595703] CR2: 0000000000000000
