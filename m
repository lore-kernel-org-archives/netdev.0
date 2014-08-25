From: KY Srinivasan <kys@microsoft.com>
Subject: RE: BUG: unable to handle kernel paging request at ffff8801f3febe63
 (netvsc_select_queue)
Date: Mon, 25 Aug 2014 19:41:43 +0000
Message-ID: <10da7a98829d40859ab418ab4d2d9491@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <20140819081517.GA22083@sucs.org> <53F3117A.4040304@redhat.com>
 <20140819114053.GA12160@sucs.org> <20140825184759.GB17681@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Daniel Borkmann <dborkman@redhat.com>,
 Jesper Dangaard Brouer <brouer@redhat.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Sitsofe Wheeler <sitsofe@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140825184759.GB17681@sucs.org>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> Sent: Monday, August 25, 2014 11:48 AM
> To: KY Srinivasan
> Cc: Daniel Borkmann; David Miller; Haiyang Zhang;
> devel@linuxdriverproject.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Jesper Dangaard Brouer; Greg Kroah-Hartman
> Subject: Re: BUG: unable to handle kernel paging request at
> ffff8801f3febe63 (netvsc_select_queue)
> 
> On Tue, Aug 19, 2014 at 12:40:53PM +0100, Sitsofe Wheeler wrote:
> > On Tue, Aug 19, 2014 at 10:57:30AM +0200, Daniel Borkmann wrote:
> > > On 08/19/2014 10:15 AM, Sitsofe Wheeler wrote:
> > > >After a variety of issues on Hyper-V (host is running Windows 2012
> > > >R2) I updated to the latest kernel (3.17-rc1
> > > >7d1311b93e58ed55f3a31cc8f94c4b8fe988a2b9), turned on a bunch of
> > > >kernel validation options and booted which has resulted in a BUG
> > > >being triggered (IP claims to be at netvsc_select_queue), at least
> > > >one of the network cards not working and a bunch of oopses.
> > > >
> > > >Guest is a customised Fedora 20 cloud image. Partial dmesg output
> > > >is
> > > >below:
> > > >
> > > >[   16.064298] input: TPPS/2 IBM TrackPoint as
> /devices/platform/i8042/serio1/input/input4
> > > >[   19.292370] BUG: unable to handle kernel paging request at
> ffff8801f3febe63
> > > >[   19.293258] IP: [<ffffffff814e69ad>] netvsc_select_queue+0x3d/0x150
> > > >[   19.293258] PGD 2db1067 PUD 207dc0067 PMD 207c20067 PTE
> 80000001f3feb060
> > > >[   19.293258] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> > > >[   19.293258] CPU: 8 PID: 568 Comm: arping Not tainted 3.17.0-
> rc1.x86_64 #121
> > > >[   19.293258] Hardware name: Microsoft Corporation Virtual
> Machine/Virtual Machine, BIOS 090006  05/23/2012
> > > >[   19.293258] task: ffff8800f29326a0 ti: ffff8801f940c000 task.ti:
> ffff8801f940c000
> > > >[   19.293258] RIP: 0010:[<ffffffff814e69ad>]  [<ffffffff814e69ad>]
> netvsc_select_queue+0x3d/0x150
> > > >[   19.293258] RSP: 0018:ffff8801f940fc60  EFLAGS: 00010206
> > > >[   19.293258] RAX: 0000000000000000 RBX: ffff8800f13e5680 RCX:
> 000000000000ffff
> > > >[   19.293258] RDX: ffff8801f3fdbe58 RSI: ffff8801f39b8d80 RDI:
> ffff8800f13e5680
> > > >[   19.293258] RBP: ffff8801f940fc88 R08: 000000000000002a R09:
> 0000000000000000
> > > >[   19.293258] R10: ffff8800f13e4520 R11: 000000000000000a R12:
> ffff8801f39b8d80
> > > >[   19.293258] R13: 0000000000000000 R14: ffff8801f9bf1290 R15:
> ffff8801f39b8d80
> > > >[   19.293258] FS:  00007f777b980740(0000) GS:ffff880206d00000(0000)
> knlGS:0000000000000000
> > > >[   19.293258] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > >[   19.293258] CR2: ffff8801f3febe63 CR3: 00000001f3aed000 CR4:
> 00000000000406e0
> >
> > > Hmm, I am not really familiar with hyper-v, but it seems 5b54dac856cb
> ("hyperv:
> > > Add support for virtual Receive Side Scaling (vRSS)") has been
> > > introduced after
> > > 0fd5d57ba345 ("packet: check for ndo_select_queue during queue
> selection").
> > >
> > > arping seems to send a raw packet (AF_PACKET) via normal
> > > packet_sendmsg() out and when doing the queue selection in
> > > packet_pick_tx_queue(), we discover that the device has
> > > ndo_select_queue implemented, so we respect that and call into it.
> > > In netvsc_select_queue(), the fallback of __packet_pick_tx_queue() is
> not being invoked here.
> > >
> > > Given that the next log message is "hv_netvsc vmbus_0_15: net device
> > > safe to remove" ... could it be that your back pointer to the device
> > > context (the actual struct hv_device) is already invalid when you
> > > try to get hv_get_drvdata(hdev) as it's sort of decoupled from
> > > netdev_priv(ndev) ? (Just a wild guess ...)
> >
> > Thanks for investigating! After setting DEBUG_PAGEALLOC=n I'm now
> > getting a GPF with an IP of rndis_filter_open:
> >
> > [   28.255083] EXT4-fs (sdb1): mounted filesystem with ordered data mode.
> Opts: (null)
> > [   28.531276] systemd-journald[366]: Received request to flush runtime
> journal from PID 1
> > [   29.401494] hv_utils: KVP: user-mode registering done.
> > [   34.628072] hv_netvsc vmbus_0_15: net device safe to remove
> > [   34.676573] hv_netvsc: hv_netvsc channel opened successfully
> > [   34.860292] hv_netvsc vmbus_0_15 eth1: unable to establish send
> buffer's gpadl
> > [   34.948983] hv_netvsc vmbus_0_15 eth1: unable to connect to NetVSP - 4
> > [   35.073575] general protection fault: 0000 [#1] SMP
> > [   35.097981] CPU: 8 PID: 678 Comm: ip Not tainted 3.17.0-rc1.x86_64 #124
> > [   35.097981] Hardware name: Microsoft Corporation Virtual
> Machine/Virtual Machine, BIOS 090006  05/23/2012
> > [   35.097981] task: ffff8801f49f1350 ti: ffff8801f8f10000 task.ti:
> ffff8801f8f10000
> > [   35.263681] RIP: 0010:[<ffffffff814e9fef>]  [<ffffffff814e9fef>]
> rndis_filter_open+0x1f/0x60
> > [   35.263681] RSP: 0018:ffff8801f8f13780  EFLAGS: 00010246
> > [   35.263681] RAX: 0000000000000000 RBX: 6b6b6b6b6b6b6b6b RCX:
> 0000000000000006
> > [   35.263681] RDX: 0000000000000006 RSI: ffff8801f49f1a90 RDI:
> ffff8801fbb8d480
> > [   35.263681] RBP: ffff8801f8f13788 R08: 0000000000000000 R09:
> 0000000000000000
> > [   35.263681] R10: 0000000000000001 R11: 0000000000000001 R12:
> ffff8801fbb8d480
> > [   35.263681] R13: 0000000000000000 R14: 0000000000000000 R15:
> 0000000000000001
> > [   35.263681] FS:  00007ff9ce3aa740(0000) GS:ffff880207d00000(0000)
> knlGS:0000000000000000
> > [   35.263681] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [   35.263681] CR2: 00007fff85779b10 CR3: 00000001f4244000 CR4:
> 00000000000406e0
> > [   35.263681] Stack:
> > [   35.263681]  ffff8800f17d8000 ffff8801f8f137b0 ffffffff814e6505
> ffff8800f17d8000
> > [   35.263681]  ffffffff8188f980 0000000000000000 ffff8801f8f137d8
> ffffffff815d0978
> > [   35.263681]  ffff8800f17d8000 ffff8800f17d8000 0000000000001003
> ffff8801f8f13810
> > [   35.263681] Call Trace:
> > [   35.263681]  [<ffffffff814e6505>] netvsc_open+0x25/0xb0
> > [   35.263681]  [<ffffffff815d0978>] __dev_open+0x98/0x110
> > [   35.263681]  [<ffffffff815d0c79>] __dev_change_flags+0xb9/0x160
> > [   35.263681]  [<ffffffff815d0d49>] dev_change_flags+0x29/0x60
> > [   35.263681]  [<ffffffff815e1415>] do_setlink+0x2d5/0xa60
> > [   35.263681]  [<ffffffff811a4ac1>] ? deactivate_slab+0x1c1/0x500
> > [   35.263681]  [<ffffffff815e23ad>] rtnl_newlink+0x49d/0x760
> > [   35.263681]  [<ffffffff815e202f>] ? rtnl_newlink+0x11f/0x760
> > [   35.263681]  [<ffffffff815bc800>] ? __alloc_skb+0x70/0x240
> > [   35.263681]  [<ffffffff81010a0b>] ? save_stack_trace+0x2b/0x50
> > [   35.263681]  [<ffffffff815de8c1>] rtnetlink_rcv_msg+0x221/0x260
> > [   35.263681]  [<ffffffff810b980d>] ? trace_hardirqs_on+0xd/0x10
> > [   35.263681]  [<ffffffff815de67b>] ? rtnetlink_rcv+0x1b/0x40
> > [   35.263681]  [<ffffffff815de6a0>] ? rtnetlink_rcv+0x40/0x40
> > [   35.263681]  [<ffffffff815fc4b5>] netlink_rcv_skb+0x65/0xb0
> > [   35.263681]  [<ffffffff815de68a>] rtnetlink_rcv+0x2a/0x40
> > [   35.263681]  [<ffffffff815fa5ec>] netlink_unicast+0xcc/0x1a0
> > [   35.263681]  [<ffffffff815fb3ee>] netlink_sendmsg+0x6de/0x750
> > [   35.263681]  [<ffffffff815b3dd8>] sock_sendmsg+0x88/0xb0
> > [   35.263681]  [<ffffffff81184e9a>] ? might_fault+0x5a/0xb0
> > [   35.263681]  [<ffffffff81184ee3>] ? might_fault+0xa3/0xb0
> > [   35.263681]  [<ffffffff81184e9a>] ? might_fault+0x5a/0xb0
> > [   35.263681]  [<ffffffff815c26cd>] ? verify_iovec+0x7d/0xf0
> > [   35.263681]  [<ffffffff815b41e6>] ___sys_sendmsg+0x296/0x2b0
> > [   35.263681]  [<ffffffff8118356d>] ? handle_mm_fault+0x69d/0x12a0
> > [   35.263681]  [<ffffffff810403e3>] ? __do_page_fault+0x1c3/0x4f0
> > [   35.263681]  [<ffffffff810b6a5f>] ? up_read+0x1f/0x40
> > [   35.263681]  [<ffffffff8104064c>] ? __do_page_fault+0x42c/0x4f0
> > [   35.263681]  [<ffffffff811e1f15>] ? mntput_no_expire+0x65/0x170
> > [   35.263681]  [<ffffffff811e1eb5>] ? mntput_no_expire+0x5/0x170
> > [   35.263681]  [<ffffffff811e27c5>] ? mntput+0x35/0x40
> > [   35.263681]  [<ffffffff811c3022>] ? __fput+0x1b2/0x1d0
> > [   35.263681]  [<ffffffff815b5172>] __sys_sendmsg+0x42/0x70
> > [   35.263681]  [<ffffffff815b51ae>] SyS_sendmsg+0xe/0x10
> > [   35.263681]  [<ffffffff816a2d29>] system_call_fastpath+0x16/0x1b
> > [   35.263681] Code: 41 5e 41 5f 5d c3 66 0f 1f 44 00 00 66 66 66 66 90 48 8b 87
> 20 01 00 00 48 85 c0 74 2f 55 48 89 e5 53 48 8b 98 40 02 00 00 31 c0 <83> 7b 08
> 02 75 2b be 0d 00 00 00 48 89 df e8 9e f9 ff ff 85 c0
> > [   35.263681] RIP  [<ffffffff814e9fef>] rndis_filter_open+0x1f/0x60
> > [   35.263681]  RSP <ffff8801f8f13780>
> > [   35.264682] ---[ end trace 91f7878e7e46f8d5 ]---
> 
> K. Y: Are the above on your radar? Only Daniel has investigated the original
> BUG and there's been no follow up on the GPF...

I will look at this as well.

K. Y
> 
> --
> Sitsofe | http://sucs.org/~sits/
