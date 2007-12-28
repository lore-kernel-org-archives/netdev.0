From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc6-mm1
Date: Fri, 28 Dec 2007 15:07:46 -0800
Message-ID: <20071228150746.42b3bbc0.akpm@linux-foundation.org>
References: <20071222233056.d652743e.akpm@linux-foundation.org>
	<64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com>
	<64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org
To: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41193 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752670AbXL1XI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Dec 2007 18:08:56 -0500
In-Reply-To: <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Dec 2007 23:53:49 +0100 "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:

> On Dec 23, 2007 5:27 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> > On Dec 23, 2007 8:30 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc6/2.6.24-rc6-mm1/
> > I have finally given up on using 2.6.24-rc3-mm2 with slub_debug=FZP to
> > get more information out of the random crashes I had seen with that
> > version. (Did not crash once with slub_debug, so no new information on
> > what the cause was)
> 
> Murphy: Just after sending that mail the system crashed two times with
> slub_debug=FZP, but did not show any new informations.
> No debug output from slub, only this stacktrace: (Its the same I
> already reported in the 2.6.24-rc3-mm2 thread)
> 
> [ 7620.673012] ------------[ cut here ]------------
> [ 7620.676291] kernel BUG at lib/list_debug.c:33!
> [ 7620.679440] invalid opcode: 0000 [1] SMP
> [ 7620.682319] last sysfs file:
> /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
> [ 7620.687845] CPU 0
> [ 7620.689300] Modules linked in: radeon drm nfsd exportfs w83792d
> ipv6 tuner tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx
> tea5761 tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
> videobuf_core btcx_risc tveeprom videodev usbhid v4l2_common
> v4l1_compat hid i2c_nforce2 sg pata_amd
> [ 7620.708561] Pid: 5698, comm: nfsv4-svc Not tainted 2.6.24-rc3-mm2 #2
> [ 7620.713080] RIP: 0010:[<ffffffff803bae54>]  [<ffffffff803bae54>]
> __list_add+0x54/0x60
> [ 7620.718667] RSP: 0018:ffff81011bca1dc0  EFLAGS: 00010282
> [ 7620.722439] RAX: 0000000000000088 RBX: ffff81011c862c48 RCX: 0000000000000002
> [ 7620.727504] RDX: ffff81011bc82ef0 RSI: 0000000000000001 RDI: ffffffff807590c0
> [ 7620.732581] RBP: ffff81011bca1dc0 R08: 0000000000000001 R09: 0000000000000000
> [ 7620.737658] R10: ffff810080058d48 R11: 0000000000000001 R12: ffff81011ed8d1c8
> [ 7620.742711] R13: ffff81011ed8d200 R14: ffff81011ed8d200 R15: ffff81011cc0e578
> [ 7620.747806] FS:  00007ffe400116f0(0000) GS:ffffffff807d4000(0000)
> knlGS:00000000f73558e0
> [ 7620.753535] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 7620.757607] CR2: 00000000017071dc CR3: 00000001188b5000 CR4: 00000000000006e0
> [ 7620.762677] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 7620.767748] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [ 7620.772808] Process nfsv4-svc (pid: 5698, threadinfo
> FFFF81011BCA0000, task FFFF81011BC82EF0)
> [ 7620.778872] Stack:  ffff81011bca1e00 ffffffff805be26e
> ffff81011ed8d1d0 ffff81011cc0e578
> [ 7620.784626]  ffff81011c862c48 ffff81011c8be000 ffff810054a8b060
> ffff81011cc0e588
> [ 7620.789913]  ffff81011bca1e10 ffffffff805be367 ffff81011bca1ee0
> ffffffff805bf0ac
> [ 7620.795062] Call Trace:
> [ 7620.796941]  [<ffffffff805be26e>] svc_xprt_enqueue+0x1ae/0x250
> [ 7620.801087]  [<ffffffff805be367>] svc_xprt_received+0x17/0x20
> [ 7620.805199]  [<ffffffff805bf0ac>] svc_recv+0x39c/0x840
> [ 7620.808851]  [<ffffffff805bea3f>] svc_send+0xaf/0xd0
> [ 7620.812374]  [<ffffffff8022f590>] default_wake_function+0x0/0x10
> [ 7620.816637]  [<ffffffff803163ea>] nfs_callback_svc+0x7a/0x130
> [ 7620.820712]  [<ffffffff805cfea2>] trace_hardirqs_on_thunk+0x35/0x3a
> [ 7620.825174]  [<ffffffff80259f8f>] trace_hardirqs_on+0xbf/0x160
> [ 7620.829335]  [<ffffffff8020cbc8>] child_rip+0xa/0x12
> [ 7620.832842]  [<ffffffff8020c2df>] restore_args+0x0/0x30
> [ 7620.836554]  [<ffffffff80316370>] nfs_callback_svc+0x0/0x130
> [ 7620.840564]  [<ffffffff8020cbbe>] child_rip+0x0/0x12
> [ 7620.844102]
> [ 7620.845168] INFO: lockdep is turned off.
> [ 7620.847964]
> [ 7620.847965] Code: 0f 0b eb fe 0f 1f 84 00 00 00 00 00 55 48 8b 16
> 48 89 e5 e8
> [ 7620.854334] RIP  [<ffffffff803bae54>] __list_add+0x54/0x60
> [ 7620.858255]  RSP <ffff81011bca1dc0>
> [ 7620.860724] Kernel panic - not syncing: Aiee, killing interrupt handler!
> 

That looks like a sunrpc bug.  git-nfsd has bene mucking around in there a
bit.

> 
> The cause, why I am resending this: I just got a crash with
> 2.6.24-rc6-mm1, again looking network related:
> 
> [93436.933356] WARNING: at include/net/dst.h:165 dst_release()
> [93436.936685] Pid: 8079, comm: konqueror Not tainted 2.6.24-rc6-mm1 #11
> [93436.939292]
> [93436.939293] Call Trace:
> [93436.939304]  [<ffffffff80531d2d>] skb_release_all+0xdd/0x110
> [93436.939307]  [<ffffffff80531311>] __kfree_skb+0x11/0xa0
> [93436.939309]  [<ffffffff805313b7>] kfree_skb+0x17/0x30
> [93436.939312]  [<ffffffff805a0b48>] unix_release_sock+0x128/0x250
> [93436.939315]  [<ffffffff805a0c91>] unix_release+0x21/0x30
> [93436.939318]  [<ffffffff8052b144>] sock_release+0x24/0x90
> [93436.939320]  [<ffffffff8052b656>] sock_close+0x26/0x50
> [93436.939324]  [<ffffffff8029f921>] __fput+0xc1/0x230
> [93436.939327]  [<ffffffff8029fe46>] fput+0x16/0x20
> [93436.939329]  [<ffffffff8029c576>] filp_close+0x56/0x90
> [93436.939331]  [<ffffffff8029de46>] sys_close+0xa6/0x110
> [93436.939335]  [<ffffffff8020b57b>] system_call_after_swapgs+0x7b/0x80
> [93436.939337]
> [93436.947241] general protection fault: 0000 [1] SMP
> [93436.947243] last sysfs file:
> /sys/devices/pci0000:00/0000:00:0f.0/0000:01:00.1/irq
> [93436.947245] CPU 1
> [93436.947246] Modules linked in: radeon drm nfsd exportfs w83792d
> ipv6 tuner tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx
> tea5761 tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
> videobuf_core btcx_risc tveeprom usbhid videodev v4l2_common hid
> v4l1_compat pata_amd sg i2c_nforce2
> [93436.947257] Pid: 8079, comm: konqueror Not tainted 2.6.24-rc6-mm1 #11
> [93436.947259] RIP: 0010:[<ffffffff80531438>]  [<ffffffff80531438>]
> skb_drop_list+0x18/0x30
> [93436.947262] RSP: 0018:ffff810005f4fda8  EFLAGS: 00010286
> [93436.947263] RAX: ab1ed5ca5b74e7de RBX: ab1ed5ca5b74e7de RCX: 000000000000d135
> [93436.947265] RDX: ffff81011d089a80 RSI: 0000000000000001 RDI: ffff81011d089a88
> [93436.947266] RBP: ffff810005f4fdb8 R08: 0000000000000001 R09: 0000000000000006
> [93436.947268] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8100de02c500
> [93436.947269] R13: ffff81011c188a00 R14: 0000000000000001 R15: ffff81011c189198
> [93436.947271] FS:  00007fb5bde0d700(0000) GS:ffff81007ff22000(0000)
> knlGS:0000000000000000
> [93436.947273] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [93436.947274] CR2: 00007fb5bdd76000 CR3: 00000000664d5000 CR4: 00000000000006e0
> [93436.947276] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [93436.947277] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [93436.947279] Process konqueror (pid: 8079, threadinfo
> ffff810005f4e000, task ffff8100a1dec000)
> [93436.947281] Stack:  ffff810005f4fdd8 ffff810116c86140
> ffff810005f4fdd8 ffffffff805314ae
> [93436.947284]  ffff810116c86140 ffff8100de02c500 ffff810005f4fdf8
> ffffffff80531cf0
> [93436.947286]  ffff8100de02c500 ffff81011c188b48 ffff810005f4fe18
> ffffffff80531311
> [93436.947288] Call Trace:
> [93436.947290]  [<ffffffff805314ae>] skb_release_data+0x5e/0xa0
> [93436.947293]  [<ffffffff80531cf0>] skb_release_all+0xa0/0x110
> [93436.947295]  [<ffffffff80531311>] __kfree_skb+0x11/0xa0
> [93436.947297]  [<ffffffff805313b7>] kfree_skb+0x17/0x30
> [93436.947299]  [<ffffffff805a0b48>] unix_release_sock+0x128/0x250
> [93436.947302]  [<ffffffff805a0c91>] unix_release+0x21/0x30
> [93436.947304]  [<ffffffff8052b144>] sock_release+0x24/0x90
> [93436.947307]  [<ffffffff8052b656>] sock_close+0x26/0x50
> [93436.947309]  [<ffffffff8029f921>] __fput+0xc1/0x230
> [93436.947312]  [<ffffffff8029fe46>] fput+0x16/0x20
> [93436.947314]  [<ffffffff8029c576>] filp_close+0x56/0x90
> [93436.947316]  [<ffffffff8029de46>] sys_close+0xa6/0x110
> [93436.947319]  [<ffffffff8020b57b>] system_call_after_swapgs+0x7b/0x80
> [93436.947322]
> [93436.947322]
> [93436.947323] Code: 48 8b 18 48 89 c7 e8 5d ff ff ff 48 85 db 75 ed
> 48 83 c4 08
> [93436.947328] RIP  [<ffffffff80531438>] skb_drop_list+0x18/0x30
> [93436.947330]  RSP <ffff810005f4fda8>
> [93436.947332] ---[ end trace befb7cc3528ab3b1 ]---

Yes, that looks more networking-related.

> Don't know in what direction I should look.
> I also can't easily reproduce this, it happened after several hours of
> watching a wmv stream with mplayer...
> 
> Torsten
