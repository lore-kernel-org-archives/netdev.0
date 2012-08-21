From: Xiaochun Lu <xiaoclu@gmail.com>
Subject: Re: skb_under_panic bug
Date: Tue, 21 Aug 2012 13:50:45 -0700
Message-ID: <CAOdseAP+OgrToqzcqJdPUS4CvkJ44kTLK1WkS7fK-N=0+A7t4w@mail.gmail.com>
References: <Ac0nvPrxz/W8V4hkSDWyavGtykw1lA==>
	<2A35EA60C3C77D438915767F458D65684817FFC9@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:58196 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758559Ab2HUUuq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 16:50:46 -0400
Received: by pbbrr13 with SMTP id rr13so455447pbb.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 13:50:45 -0700 (PDT)
In-Reply-To: <2A35EA60C3C77D438915767F458D65684817FFC9@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jeff:

Have you resolved this one.  I see similar issue.  But my kernel is
based on 3.0.36. here is the trace:

Aug 20 20:50:51 Ericsson kernel: skb_under_panic:
text:ffffffff8133ea84 len:112 put:14 head:ffff8806187e0a00
data:ffff8806187e09f4 tail:0x64 end:0x80 dev:ethSw0.1
Aug 20 20:50:54 Ericsson kernel: ------------[ cut here ]------------
Aug 20 20:50:54 Ericsson kernel: Kernel BUG at ffffffff8131b73a
[verbose debug info unavailable]
Aug 20 20:50:54 Ericsson kernel: invalid opcode: 0000 [#1] PREEMPT SMP
Aug 20 20:50:54 Ericsson kernel: CPU 0
Aug 20 20:50:54 Ericsson kernel: Modules linked in: cls_u32 sch_htb
uio_pch_smb ixgbe mdio bonding 8021q iflc uio_spanky_shiba uio_phalanx
uio rbn_pci_hotswap msr fuse tipc sctp crc32c libcrc32c rbn_nf_ipacl
rbn_nf_tcp rbn_nf_ips rbn_ctx_kmod ipv6 rbn_ext_ip_so af_isis
af_rbn_netlink af_ipc xcrp rbn_platform loop rbn_swrp_wd igb
Aug 20 20:50:54 Ericsson kernel:
Aug 20 20:50:54 Ericsson kernel: Pid: 3616, comm: pad Not tainted
3.0.36-869-g241f2ae #2 Ericsson Smart Service Router/SWRP
Aug 20 20:50:54 Ericsson kernel: RIP: 0010:[<ffffffff8131b73a>]
[<ffffffff8131b73a>] skb_push+0x7a/0x80
Aug 20 20:50:54 Ericsson kernel: RSP: 0000:ffff88060a1f9a18  EFLAGS: 00010292
Aug 20 20:50:54 Ericsson kernel: RAX: 0000000000000088 RBX:
0000000000000800 RCX: 0000000000000000
Aug 20 20:50:54 Ericsson kernel: RDX: ffff88060a1f8010 RSI:
0000000000000000 RDI: 0000000000000001
Aug 20 20:50:54 Ericsson kernel: RBP: 0000000000000000 R08:
ffff88060a1f8000 R09: 0000000000000000
Aug 20 20:50:54 Ericsson kernel: R10: 0000000000000002 R11:
0000000000000000 R12: ffff8805ea421398
Aug 20 20:50:54 Ericsson kernel: R13: 0000000000000062 R14:
ffff880619089000 R15: ffff88061a814dd8
Aug 20 20:50:54 Ericsson kernel: FS:  0000000000000000(0000)
GS:ffff88063fc00000(0063) knlGS:00000000578d0b90
Aug 20 20:50:54 Ericsson kernel: CS:  0010 DS: 002b ES: 002b CR0:
000000008005003b
Aug 20 20:50:54 Ericsson kernel: CR2: 00002aaaaaae4000 CR3:
00000006162ab000 CR4: 00000000000006f0
Aug 20 20:50:54 Ericsson kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Aug 20 20:50:54 Ericsson kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Aug 20 20:50:54 Ericsson kernel: Process pad (pid: 3616, threadinfo
ffff88060a1f8000, task ffff88061abfbd40)
Aug 20 20:50:54 Ericsson kernel: Stack:
Aug 20 20:50:54 Ericsson kernel:  0000000000000064 0000000000000080
ffff880619089000 ffffffff8133ea84
Aug 20 20:50:54 Ericsson kernel:  000000000000017e ffff8805ea421300
ffff8805ea421390 ffff8805ea56d040
Aug 20 20:50:54 Ericsson kernel:  ffff8805ea421398 ffffffff8133088e
ffff880619089000 000000000000017a
Aug 20 20:50:54 Ericsson kernel: Call Trace:
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff8133ea84>] ? eth_header+0x34/0xe0
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff8133088e>] ?
neigh_resolve_output+0x10e/0x320
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff81357ae1>] ?
ip_finish_output+0x1f1/0x400
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff81356c39>] ? ip_send_skb+0x9/0x60
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff8137a525>] ?
udp_send_skb+0x125/0x3c0
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff8137cd0a>] ? udp_sendmsg+0x73a/0x870
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff810ecde0>] ? __pollwait+0x120/0x120
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff81356210>] ?
ip_append_page+0x5e0/0x5e0
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff81312b50>] ?
sock_sendmsg+0x110/0x130
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff813128a7>] ?
sock_recvmsg+0x127/0x140
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff813ed091>] ?
_raw_spin_unlock_irq+0x11/0x40
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff810358bc>] ?
finish_task_switch+0x5c/0xd0
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff8111dd9a>] ?
compat_core_sys_select+0x2ba/0x2d0
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff810dbbdf>] ? fget_light+0xbf/0x100
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff813132c8>] ? sys_sendto+0x138/0x1a0
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff81031449>] ? get_parent_ip+0x9/0x20
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff81036297>] ?
sub_preempt_count+0x87/0xc0
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff813eb4c3>] ?
preempt_schedule_irq+0x43/0x60
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff813ed846>] ? retint_kernel+0x26/0x30
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff81060b5b>] ? ktime_get_ts+0x6b/0xd0
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff8133def5>] ?
compat_sys_socketcall+0x175/0x250
Aug 20 20:50:54 Ericsson kernel:  [<ffffffff813eef03>] ? ia32_do_call+0x13/0x13
Aug 20 20:50:54 Ericsson kernel: Code: 8b 57 68 48 89 44 24 10 8b 87
e8 00 00 00 48 89 44 24 08 31 c0 8b bf e4 00 00 00 48 89 3c 24 48 c7
c7 50 61 4d 81 e8 c2 eb 0c 00 <0f> 0b eb fe 66 90 48 83 ec 18 89 f1 44
8b 57 6c 4c 8b 87 f0 00
Aug 20 20:50:54 Ericsson kernel: RIP  [<ffffffff8131b73a>] skb_push+0x7a/0x80
Aug 20 20:50:54 Ericsson kernel:  RSP <ffff88060a1f9a18>
Aug 20 20:50:54 Ericsson kernel: ---[ end trace 3856d31346ddf680 ]---


Thanks

Shawn Lu


On Tue, May 1, 2012 at 10:08 AM, Pieper, Jeffrey E
<jeffrey.e.pieper@intel.com> wrote:
> I've seen the following stack trace several times recently, and was wondering if anyone else has ran into this. This occurs during bi-directional TCP/UDP traffic (netperf) on multiple platforms/devices. Whatever is occurring also seems to invoke hdparm.  I'm running 3.4.0-rc4 (recent net-next pull) with CONFIG_PREEMPT=y:
>
> skb_under_panic: text:ffffffff8130d538 len:120 put:14 head:ffff880128c89800 data:ffff880128c897f4 tail:0x6c end:0xc0 dev:eth0
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:145!
> invalid opcode: 0000 [#1] PREEMPT SMP
> CPU 4
> Modules linked in: nfsd lockd exportfs sunrpc e1000e [last unloaded: scsi_wait_scan]
>
> Pid: 5030, comm: netperf Not tainted 3.4.0-rc2-net-next-e1000e-queue_20120423 #2                  /DQ57TM
> RIP: 0010:[<ffffffff812ef1b4>]  [<ffffffff812ef1b4>] skb_push+0x72/0x7b
> RSP: 0018:ffff8801283459d8  EFLAGS: 00010292
> RAX: 0000000000000084 RBX: ffff880127ffc000 RCX: 00000000fffffff3
> RDX: 00000000000000d6 RSI: 0000000000000046 RDI: ffffffff8162375a
> RBP: ffff8801283459f8 R08: 0000000000008d0a R09: ffff88012f019000
> R10: 0000000000000001 R11: 0000000000000078 R12: ffff880128ff6ca0
> R13: 0000000000000800 R14: 0000000000000212 R15: ffff880128ff6c98
> FS:  00007fc4c3feb700(0000) GS:ffff88012fc80000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: ffffffffff600400 CR3: 0000000127e81000 CR4: 00000000000007e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process netperf (pid: 5030, threadinfo ffff880128344000, task ffff8801279859d0)
> Stack:
> 000000000000006c 00000000000000c0 ffff880127ffc000 ffff880128ff6ca0
> ffff880128345a38 ffffffff8130d538 ffff88010000006a 0000000000000000
> ffffffff81300cd5 ffff88011dfad9c0 ffff880128ff6c00 ffff880127ffc000
> Call Trace:
> [<ffffffff8130d538>] eth_header+0x28/0xb4
> [<ffffffff81300cd5>] ? neigh_resolve_output+0x14d/0x19a
> [<ffffffff81300cd7>] neigh_resolve_output+0x14f/0x19a
> [<ffffffff8131c35a>] ip_finish_output+0x22f/0x271
> [<ffffffff8131c3d9>] ip_output+0x3d/0x3f
> [<ffffffff81319dd4>] ip_local_out+0x62/0x64
> [<ffffffff81319ddf>] ip_send_skb+0x9/0x2c
> [<ffffffff81337a85>] udp_send_skb+0x250/0x2aa
> [<ffffffff81338fa2>] udp_sendmsg+0x4e3/0x6f8
> [<ffffffff8131b345>] ? ip_append_page+0x4b2/0x4b2
> [<ffffffff813a442b>] ? preempt_schedule_irq+0x3c/0x51
> [<ffffffff81049998>] ? __dequeue_entity+0x2e/0x33
> [<ffffffff8133f654>] inet_sendmsg+0x93/0x9c
> [<ffffffff812e741d>] sock_sendmsg+0xbb/0xd4
> [<ffffffff81049998>] ? __dequeue_entity+0x2e/0x33
> [<ffffffff81049998>] ? __dequeue_entity+0x2e/0x33
> [<ffffffff813a442b>] ? preempt_schedule_irq+0x3c/0x51
> [<ffffffff813a5516>] ? retint_kernel+0x26/0x30
> [<ffffffff812e748f>] ? sockfd_lookup_light+0x1b/0x54
> [<ffffffff812e7b3f>] sys_sendto+0xfa/0x122
> [<ffffffff813a442b>] ? preempt_schedule_irq+0x3c/0x51
> [<ffffffff813a97a2>] system_call_fastpath+0x16/0x1b
> Code: 8b 57 68 48 89 44 24 10 8b 87 b0 00 00 00 48 89 44 24 08 31 c0 8b bf ac 00 00 00 48 89 3c 24 48 c7 c7 b7 6d 4c 81 e8 26 37 0b 00 <0f> 0b eb fe 4c 89 c8 c9 c3 55 89 f1 48 89 e5 48 83 ec 20 4c 8b
> RIP  [<ffffffff812ef1b4>] skb_push+0x72/0x7b
> RSP <ffff8801283459d8>
> ---[ end trace 35a690c4aebb4bd0 ]---
> hdparm: sending ioctl 330 to a partition!
> hdparm: sending ioctl 330 to a partition!
> hdparm: sending ioctl 330 to a partition!
> hdparm: sending ioctl 330 to a partition!
>
> Thanks in advance,
>
> Jeff Pieper
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
