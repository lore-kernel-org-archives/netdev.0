From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: AppleTalk networking causes kernel panic in 3.12+
Date: Mon, 21 Jul 2014 06:34:56 +0200
Message-ID: <1405917296.10255.102.camel@edumazet-glaptop2.roam.corp.google.com>
References: <3B3368CF-8532-47C8-8F60-62A205274214@ivanx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Ivan Drucker <ivan@ivanx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34045 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaGUEfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 00:35:00 -0400
Received: by mail-wg0-f42.google.com with SMTP id l18so5808834wgh.25
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 21:34:59 -0700 (PDT)
In-Reply-To: <3B3368CF-8532-47C8-8F60-62A205274214@ivanx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-07-20 at 22:18 -0400, Ivan Drucker wrote:
> Hello,
> 
> 
> I've never submitted a kernel bug before, so I hope I'm sending this to the right place. Apologies if not.
> 
> [1.] One-line description:
> Starting in kernel 3.12, executing "atalkd" from Netatalk 2.2.4 will trigger a kernel panic when the AppleTalk networking protocol activates.
> 
> [2.] Full Description:
> AppleTalk causes in kernel panic in kernel 3.12 and later across (at least) i386, amd64, and armhf architectures, including:
> 
> Debian 7.6.0 (kernel 3.14, amd64)
> Debian 7.3.0 (kernel 3.14, i386)
> Fedora 20 (kernel 3.15, i386)
> Ubuntu 14.04 LTS (kernel 3.13, i386)
> Raspbian 2014-06-20 (kernel 3.12, i386)
> 
> The problem does not exist in kernel 3.11 or lower. The following work fine:
> 
> Debian 7.6.0 (kernel 3.2, amd64)
> Debian 7.3.0 (kernel 3.2, i386)
> Fedora 20 (kernel 3.11, i386)
> Ubuntu 13.10 (kernel 3.11, i386)
> Raspbian 2014-01-09 (kernel 3.10, i386)
> 
> [3.] Keywords:
> AppleTalk kernel module; networking; kernel
> 
> [4.] Kernel version (from /proc/version):
> 3.12 (or 3.13, 3.14, 3.15)
> 
> [5.] Output of Oops.. message (if applicable) with symbolic information resolved (see Documentation/oops-tracing.txt):
>   see bottom of email
> 
> [6.] A small shell script or example program which triggers the
>      problem (if possible):
> 
> Here are steps to reproduce on Debian/Ubuntu:
> 
> wget http://downloads.sourceforge.net/project/netatalk/netatalk/2.2.4/netatalk-2.2.4.tar.gz
> tar zxf netatalk-2.2.4.tar.gz
> cd netatalk-2.2.4
> sudo apt-get install libdb-dev
> ./configure --enable-debian --enable-ddp
> make
> sudo make install
> 
> Alternately, on Fedora:
> 
> sudo yum install wget
> wget http://downloads.sourceforge.net/project/netatalk/netatalk/2.2.4/netatalk-2.2.4.tar.gz
> tar zxf netatalk-2.2.4.tar.gz
> cd netatalk-2.2.4
> sudo yum install libdb-devel
> ./configure --enable-redhat-systemd --enable-ddp
> make
> sudo make install
> 
> Once installed:
> sudo /usr/local/sbin/atalkd
> 
> At this point, on kernel 3.11 or lower, it will pause for about 60 seconds while atalkd starts up, and when the prompt returns, the atalkd process will be running. On kernel 3.12 and later, a kernel panic is dumped to the console (see below).
> 
> I haven't tried on Netatalk 2.2.5 because it has problems compiling; and Netatalk 3.0 has removed AppleTalk networking.
> 
> 
> [7.] Environment
> The steps to reproduce can be applied on any clean install of any Linux with a 3.12 kernel or later, as far as I can tell, otherwise independent of environment.
> 
> 
> [X.] Other notes, patches, fixes, workarounds:
> 
> Here is the console output on Debian 7.6.0, kernel 3.12, amd64:
> 
> [   55.856763] NET: Registered protocol family 5
> [   56.969419] ------------[ cut here ]------------
> [   56.972080] kernel BUG at /build/linux-SMWX37/linux-3.12.9/include/linux/skbuff.h:1809!
> [   56.972080] invalid opcode: 0000 [#1] SMP 
> [   56.972080] Modules linked in: appletalk psnap llc nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc loop joydev hid_generic usbhid parport_pc parport ac battery psmouse serio_raw snd_intel8x0 snd_ac97_codec snd_pcm hid evdev processor button thermal_sys snd_page_alloc snd_timer snd soundcore ac97_bus i2c_piix4 i2c_core pcspkr ext4 crc16 mbcache jbd2 sd_mod crc_t10dif crct10dif_common sg sr_mod cdrom ata_generic ohci_pci ahci libahci ata_piix ohci_hcd ehci_pci ehci_hcd libata usbcore usb_common e1000 scsi_mod
> [   56.972080] CPU: 0 PID: 2561 Comm: atalkd Not tainted 3.12-0.bpo.1-amd64 #1 Debian 3.12.9-1~bpo70+1
> [   56.972080] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
> [   56.972080] task: ffff880000027080 ti: ffff88001ee6a000 task.ti: ffff88001ee6a000
> [   56.972080] RIP: 0010:[<ffffffff814bf4ee>]  [<ffffffff814bf4ee>] sock_aio_write.part.17+0x2/0x2
> [   56.972080] RSP: 0018:ffff88001fc03d10  EFLAGS: 00010286
> [   56.972080] RAX: 0000000000000000 RBX: ffff88001b038000 RCX: 000000000000d50c
> [   56.972080] RDX: ffff88001b2b9c00 RSI: 0000000000000300 RDI: ffff88001b038000
> [   56.972080] RBP: ffff88001b256ac0 R08: 0000000000000010 R09: 0000000000000000
> [   56.972080] R10: 000000000000ffff R11: 0000000000000000 R12: 0000000000000000
> [   56.972080] R13: 0000000000000000 R14: 00000000000000ff R15: ffff88001cd02bca
> [   56.972080] FS:  00007f1778b5f700(0000) GS:ffff88001fc00000(0000) knlGS:0000000000000000
> [   56.972080] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   56.972080] CR2: ffffffffff600400 CR3: 000000001bf23000 CR4: 00000000000006f0
> [   56.972080] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   56.972080] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [   56.972080] Stack:
> [   56.972080]  ffffffff813c2198 ffff88001b256ac0 ffff88001b038000 0000000000000006
> [   56.972080]  0000000000000000 00000000000000ff ffffffffa03dcfcb ffffffff00000000
> [   56.972080]  ffff88001fc03e84 ffff88000000001f ffff88001b256ac0 ffff88001cd018c0
> [   56.972080] Call Trace:
> [   56.972080]  <IRQ> 
> [   56.972080]  [<ffffffff813c2198>] ? sock_queue_rcv_skb+0x1d8/0x220
> [   56.972080]  [<ffffffffa03dcfcb>] ? atalk_rcv+0x26b/0x4c0 [appletalk]
> [   56.972080]  [<ffffffffa038d0f6>] ? snap_rcv+0x76/0xd0 [psnap]
> [   56.972080]  [<ffffffffa038d080>] ? find_snap_client+0x80/0x80 [psnap]
> [   56.972080]  [<ffffffffa02c945a>] ? llc_rcv+0x21a/0x380 [llc]
> [   56.972080]  [<ffffffff813d3953>] ? __netif_receive_skb_core+0x643/0x7c0
> [   56.972080]  [<ffffffff813d4321>] ? process_backlog+0xa1/0x170
> [   56.972080]  [<ffffffff813d4e49>] ? net_rx_action+0x119/0x230
> [   56.972080]  [<ffffffff810ad2e9>] ? handle_irq_event_percpu+0xa9/0x210
> [   56.972080]  [<ffffffff810651aa>] ? __do_softirq+0xda/0x280
> [   56.972080]  [<ffffffff814cd05c>] ? call_softirq+0x1c/0x30
> [   56.972080]  <EOI> 
> [   56.972080]  [<ffffffff810166c5>] ? do_softirq+0x65/0xa0
> [   56.972080]  [<ffffffff810650c4>] ? local_bh_enable+0x94/0xa0
> [   56.972080]  [<ffffffff813d675e>] ? dev_queue_xmit+0x1fe/0x4b0
> [   56.972080]  [<ffffffffa02c9633>] ? llc_mac_hdr_init+0x73/0x90 [llc]
> [   56.972080]  [<ffffffffa038d2ba>] ? snap_request+0x4a/0x60 [psnap]
> [   56.972080]  [<ffffffffa03ddd74>] ? atalk_sendmsg+0x4f4/0x660 [appletalk]
> [   56.972080]  [<ffffffff813bd5d2>] ? sock_sendmsg+0xd2/0xf0
> [   56.972080]  [<ffffffff81064246>] ? SyS_time+0x26/0x50
> [   56.972080]  [<ffffffff81019c99>] ? emulate_vsyscall+0x369/0x3d0
> [   56.972080]  [<ffffffff813bdf41>] ? SYSC_sendto+0x121/0x190
> [   56.972080]  [<ffffffff814c17dc>] ? __schedule+0x2cc/0x780
> [   56.972080]  [<ffffffff814cb7b9>] ? system_call_fastpath+0x16/0x1b
> [   56.972080] Code: 4f 06 f6 c1 0f 75 1f 66 83 f9 1f 76 19 31 d2 0f b7 c9 eb 06 02 14 07 48 ff c0 39 c1 7f f6 31 c0 84 d2 48 0f 44 c7 c3 0f 0b 0f 0b <0f> 0b 48 83 ec 28 48 89 c8 48 8b 4f 20 41 89 f0 48 c7 c6 61 f6 
> [   56.972080] RIP  [<ffffffff814bf4ee>] sock_aio_write.part.17+0x2/0x2
> [   56.972080]  RSP <ffff88001fc03d10>
> [   60.001148] ---[ end trace f0b1ef59106eb572 ]---
> [   60.015815] Kernel panic - not syncing: Fatal exception in interrupt
> 
> 
> 
> And here it is on Fedora 20, kernel 3.15, i686:
> 
> [   87.473417] NET: Registered protocol family 5
> [   88.625964] ------------[ cut here ]------------
> [   88.626319] kernel BUG at include/linux/skbuff.h:1948!
> [   88.626319] invalid opcode: 0000 [#1] SMP 
> [   88.626319] Modules linked in: appletalk psnap nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE bnep bluetooth ip6t_REJECT xt_conntrack cfg80211 rfkill ebtable_nat ebtable_broute bridge stp llc ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw snd_intel8x0 snd_ac97_codec ppdev ac97_bus snd_seq snd_seq_device snd_pcm joydev microcode serio_raw snd_timer snd parport_pc parport i2c_piix4 i2c_core e1000 soundcore nfsd auth_rpcgss nfs_acl lockd sunrpc ata_generic pata_acpi
> [   88.626319] CPU: 0 PID: 1173 Comm: atalkd Not tainted 3.15.6-200.fc20.i686 #1
> [   88.626319] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
> [   88.626319] task: ef6d0540 ti: ed008000 task.ti: ed008000
> [   88.626319] EIP: 0060:[<c09ee1f5>] EFLAGS: 00010286 CPU: 0
> [   88.626319] EIP is at skb_orphan.part.23+0x3/0x5
> [   88.626319] EAX: f0aef060 EBX: ef532600 ECX: 00000000 EDX: ef532600
> [   88.626319] ESI: edd493c0 EDI: 00000000 EBP: ee80be78 ESP: ee80be78
> [   88.626319]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> [   88.626319] CR0: 8005003b CR2: b680c4a0 CR3: 2d093000 CR4: 000006d0
> [   88.626319] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> [   88.626319] DR6: fffe0ff0 DR7: 00000400
> [   88.626319] Stack:
> [   88.626319]  ee80be90 c08ec250 00000246 edd493c0 ef532600 00000000 ee80bed0 f0aeca7c
> [   88.626319]  c067f9bd ecead400 eceac800 ee80bed4 c07baa33 000000fe ed29e3c0 edd493c0
> [   88.626319]  ee80bed0 c1e60179 ef681918 edd493c0 ee943800 ef681900 ee80bee8 f13fd20d
> [   88.626319] Call Trace:
> [   88.626319]  [<c08ec250>] sock_queue_rcv_skb+0x110/0x1a0
> [   88.626319]  [<f0aeca7c>] atalk_rcv+0x27c/0x4a0 [appletalk]
> [   88.626319]  [<c067f9bd>] ? blk_run_queue+0x2d/0x40
> [   88.626319]  [<c07baa33>] ? scsi_run_queue+0x113/0x260
> [   88.626319]  [<f13fd20d>] snap_rcv+0x5d/0x9c [psnap]
> [   88.626319]  [<f13fd1b0>] ? unregister_snap_client+0x40/0x40 [psnap]
> [   88.626319]  [<f0a84486>] llc_rcv+0x256/0x320 [llc]
> [   88.626319]  [<c08fded7>] __netif_receive_skb_core+0x487/0x670
> [   88.626319]  [<c08fe0d6>] __netif_receive_skb+0x16/0x60
> [   88.626319]  [<c08febf4>] process_backlog+0x84/0x140
> [   88.626319]  [<c08fe4b8>] net_rx_action+0x118/0x1f0
> [   88.626319]  [<c0451dc3>] __do_softirq+0xd3/0x250
> [   88.626319]  [<c0451cf0>] ? cpu_callback+0x160/0x160
> [   88.626319]  [<c0404e22>] do_softirq_own_stack+0x22/0x30
> [   88.626319]  <IRQ> 
> [   88.626319]  [<c0451fdd>] do_softirq+0x4d/0x60
> [   88.626319]  [<c0452068>] __local_bh_enable_ip+0x78/0x80
> [   88.626319]  [<c0900008>] __dev_queue_xmit+0x208/0x430
> [   88.626319]  [<c091bb40>] ? ether_setup+0x80/0x80
> [   88.626319]  [<f0a845a4>] ? llc_mac_hdr_init+0x54/0x90 [llc]
> [   88.626319]  [<c090023f>] dev_queue_xmit+0xf/0x20
> [   88.626319]  [<f0a8465b>] llc_build_and_send_ui_pkt+0x7b/0x84 [llc]
> [   88.626319]  [<f13fd0d0>] snap_request+0x40/0x50 [psnap]
> [   88.626319]  [<f0aec31b>] atalk_sendmsg+0x43b/0x5a0 [appletalk]
> [   88.626319]  [<c064ab8f>] ? selinux_socket_sendmsg+0x1f/0x30
> [   88.626319]  [<c08e744d>] sock_sendmsg+0x7d/0xb0
> [   88.626319]  [<c08ec37e>] ? sk_prot_alloc+0x9e/0x150
> [   88.626319]  [<c06b2dbb>] ? _copy_from_user+0x3b/0x50
> [   88.626319]  [<c08e7e76>] SYSC_sendto+0xf6/0x130
> [   88.626319]  [<c051f549>] ? get_page_from_freelist+0x389/0x620
> [   88.626319]  [<c08e90d4>] SYSC_socketcall+0x584/0x9c0
> [   88.626319]  [<c04809cb>] ? update_curr+0xdb/0x190
> [   88.626319]  [<c090f102>] ? __rtnl_unlock+0x12/0x20
> [   88.626319]  [<c047e13d>] ? __enqueue_entity+0x6d/0x80
> [   88.626319]  [<c0482681>] ? put_prev_entity+0x61/0x460
> [   88.626319]  [<c0485c89>] ? pick_next_task_fair+0x779/0x9f0
> [   88.626319]  [<c053db61>] ? handle_mm_fault+0x5c1/0xad0
> [   88.626319]  [<c0402058>] ? __switch_to+0xb8/0x360
> [   88.626319]  [<c09ef0fe>] ? __schedule+0x23e/0x6f0
> [   88.626319]  [<c08e95f3>] SyS_socketcall+0x13/0x20
> [   88.626319]  [<c09fa09f>] sysenter_do_call+0x12/0x16
> [   88.626319] Code: 76 17 31 c9 31 d2 39 c2 7d 06 02 0c 13 42 eb f6 31 c0 84 c9 0f 44 c3 eb 02 31 c0 5b 5d c3 55 89 e5 3e 8d 74 26 00 0f 0b 55 89 e5 <0f> 0b 55 89 e5 56 53 83 ec 28 3e 8d 74 26 00 bb c3 a6 bc c0 8b
> [   88.626319] EIP: [<c09ee1f5>] skb_orphan.part.23+0x3/0x5 SS:ESP 0068:ee80be78
> [   92.041215] ---[ end trace 5dbd85ee9d2eb19e ]---
> [   92.042185] Kernel panic - not syncing: Fatal exception in interrupt
> [   92.043174] Kernel Offset: 0x0 from 0xc0400000 (relocation range: 0xc0000000-0xf07effff)
> [   92.043174] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
> 
> Thank you,
> Ivan Drucker
> New York--

Hi Ivan

Problem was solved by following commit : 

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=36beddc272c111689f3042bf3d10a64d8a805f93

Thanks
