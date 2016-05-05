From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5 core/en oops in 4.6-rc6+
Date: Thu, 5 May 2016 19:42:04 +0300
Message-ID: <CALzJLG9_PLzU=Qwvv=_3aEd0KQr1c9rZyfcrfuLPo8wF=F_B0A@mail.gmail.com>
References: <56df9c0a-39dd-6e07-9466-23195dc60860@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33895 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbcEEQmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 12:42:24 -0400
Received: by mail-yw0-f195.google.com with SMTP id i22so12179435ywc.1
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 09:42:23 -0700 (PDT)
In-Reply-To: <56df9c0a-39dd-6e07-9466-23195dc60860@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 5, 2016 at 7:00 PM, Doug Ledford <dledford@redhat.com> wrote:
> Just had this pop up during testing, happened very soon after bootup:
>
> [   47.235925] BUG: unable to handle kernel NULL pointer dereference at
> 00000000000001e8
> [   47.245057] IP: [<ffffffffc0328b9c>] mlx5e_sq_xmit+0x1c/0xd80 [mlx5_core]
> [   47.252822] PGD 0
> [   47.255218] Oops: 0000 [#1] SMP
> [   47.259070] Modules linked in: sch_mqprio bridge 8021q garp mrp stp
> llc ib_iser libiscsi scsi_transport_iscsi ib_srp scsi_transport_srp
> ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_sa
> ib_mad x86_pkg_temp_thermal coretd
> [   47.352984] CPU: 18 PID: 1358 Comm: NetworkManager Not tainted
> 4.6.0-rc6-00004-g7199787 #102
> [   47.362460] Hardware name: Dell Inc. PowerEdge R430/03XKDV, BIOS
> 1.6.2 01/08/2016
> [   47.370869] task: ffff88103369d000 ti: ffff88103751c000 task.ti:
> ffff88103751c000
> [   47.379263] RIP: 0010:[<ffffffffc0328b9c>]  [<ffffffffc0328b9c>]
> mlx5e_sq_xmit+0x1c/0xd80 [mlx5_core]
> [   47.389627] RSP: 0018:ffff88103751f7d0  EFLAGS: 00010282
> [   47.395574] RAX: ffff880fe6f51d00 RBX: 0000000000000000 RCX:
> 0000000000000081
> [   47.403571] RDX: ffff880ff1dc3000 RSI: ffff880fe6f51d00 RDI:
> 0000000000000000
> [   47.411561] RBP: ffff88103751f828 R08: 0000000000020c80 R09:
> ffffffff81871e04
> [   47.419563] R10: ffffea003f9bd400 R11: ffff88100116de00 R12:
> 000000000000003e
> [   47.427566] R13: ffff880fe6f51d00 R14: ffff8810240d0090 R15:
> ffff8810240d0068
> [   47.435557] FS:  00007fd79b882dc0(0000) GS:ffff88103ee40000(0000)
> knlGS:0000000000000000
> [   47.444625] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   47.451062] CR2: 00000000000001e8 CR3: 0000001cf86c5000 CR4:
> 00000000001406e0
> [   47.459053] Stack:
> [   47.461306]  ffffffff81875480 ffff880fe6f50c00 ffff881d02f9b800
> ffff88103751f838
> [   47.469647]  ffffffff81a08415 ffff88103751f818 ffff880fe6f51d00
> 000000000000003e
> [   47.477964]  ffff881d02f9bd00 ffff8810240d0090 ffff8810240d0068
> ffff88103751f838
> [   47.486279] Call Trace:
> [   47.489019]  [<ffffffff81875480>] ? consume_skb+0x80/0x150
> [   47.495178]  [<ffffffff81a08415>] ? packet_rcv+0x65/0x6d0
> [   47.501244]  [<ffffffffc03299ae>] mlx5e_xmit+0x2e/0x40 [mlx5_core]
> [   47.508169]  [<ffffffff818959d4>] dev_hard_start_xmit+0x384/0x650
> [   47.515007]  [<ffffffff818951bb>] ? validate_xmit_skb.isra.80+0x4b/0x4e0
> [   47.522516]  [<ffffffff818d036f>] sch_direct_xmit+0x19f/0x360
> [   47.528963]  [<ffffffff81896565>] __dev_queue_xmit+0x6e5/0xaa0
> [   47.535502]  [<ffffffff81875480>] ? consume_skb+0x80/0x150
> [   47.542723]  [<ffffffff81896958>] dev_queue_xmit+0x18/0x30
> [   47.549856]  [<ffffffffc08d1d54>]
> vlan_dev_hard_start_xmit+0x104/0x210 [8021q]
> [   47.558933]  [<ffffffff818959d4>] dev_hard_start_xmit+0x384/0x650
> [   47.566738]  [<ffffffff8189675a>] __dev_queue_xmit+0x8da/0xaa0
> [   47.574246]  [<ffffffff81896958>] dev_queue_xmit+0x18/0x30
> [   47.581349]  [<ffffffff818a2d07>] neigh_connected_output+0x107/0x170
> [   47.589433]  [<ffffffff819a3e9f>] ip6_finish_output2+0x23f/0x720
> [   47.597128]  [<ffffffff81430f32>] ? selinux_ipv6_postroute+0x22/0x30
> [   47.605207]  [<ffffffff819a666b>] ip6_finish_output+0x13b/0x1e0
> [   47.612809]  [<ffffffff819a6777>] ip6_output+0x67/0x1c0
> [   47.619619]  [<ffffffff819a6530>] ? ip6_fragment+0xd80/0xd80
> [   47.626903]  [<ffffffff819fb80d>] ip6_local_out+0x4d/0x60
> [   47.633884]  [<ffffffff819a703b>] ip6_send_skb+0x2b/0xb0
> [   47.640773]  [<ffffffff819a713d>] ip6_push_pending_frames+0x7d/0x90
> [   47.648710]  [<ffffffff819d533d>] rawv6_sendmsg+0xd2d/0x1210
> [   47.655938]  [<ffffffff8128f70a>] ? do_wp_page+0x3ba/0x910
> [   47.662944]  [<ffffffff8142a970>] ? sock_has_perm+0x80/0xb0
> [   47.670020]  [<ffffffff8194f2c7>] inet_sendmsg+0x97/0xf0
> [   47.676778]  [<ffffffff818673f8>] sock_sendmsg+0x58/0x90
> [   47.683505]  [<ffffffff81868148>] SYSC_sendto+0x138/0x1b0
> [   47.690302]  [<ffffffff8109d5a8>] ? __do_page_fault+0x338/0x9d0
> [   47.697656]  [<ffffffff8116b131>] ? ktime_get_with_offset+0x71/0x130
> [   47.705481]  [<ffffffff81163ee7>] ? posix_get_boottime+0x37/0x60
> [   47.712904]  [<ffffffff81868b36>] SyS_sendto+0x16/0x20
> [   47.719346]  [<ffffffff81a336b2>] entry_SYSCALL_64_fastpath+0x1a/0xa4
> [   47.727230] Code: 05 a9 9f 03 00 01 66 31 47 48 5d c3 0f 1f 00 0f 1f
> 44 00 00 55 48 89 e5 41 57 41 56 41 55 49 89 f5 41 54 53 48 89 fb 48 83
> ec 30 <0f> b7 87 e8 01 00 00 0f b6 8f ea 01 00 00 45 8b 95 80 00 00 00
> [   47.750336] RIP  [<ffffffffc0328b9c>] mlx5e_sq_xmit+0x1c/0xd80
> [mlx5_core]
> [   47.758755]  RSP <ffff88103751f7d0>
> [   47.763368] CR2: 00000000000001e8
> [   47.767779] ---[ end trace 35565b04ca44e521 ]---
>
> It appears to be intermittent as this machine has booted this kernel
> multiple times without hitting this.  Network setup includes both vlan
> and non-vlan interfaces.  If you need more info from me, please include
> me on the Cc: as I don't follow netdev@
>

Hi Doug,

did you by change configure  TC queues for the netdev ? i.e. dev->num_tc > 1
if not i would be happy to get more info in you network configuration.
