From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.24-rc6-mm1
Date: Sun, 30 Dec 2007 16:24:43 -0500
Message-ID: <20071230212443.GA23320@fieldses.org>
References: <20071222233056.d652743e.akpm@linux-foundation.org> <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com> <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com> <20071228150746.42b3bbc0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Torsten Kaiser <just.for.lkml@googlemail.com>,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	netdev@vger.kernel.org, Tom Tucker <tom@opengridcomputing.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40791 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754234AbXL3VYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2007 16:24:50 -0500
Content-Disposition: inline
In-Reply-To: <20071228150746.42b3bbc0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 28, 2007 at 03:07:46PM -0800, Andrew Morton wrote:
> On Fri, 28 Dec 2007 23:53:49 +0100 "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> 
> > On Dec 23, 2007 5:27 PM, Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
> > > On Dec 23, 2007 8:30 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > >
> > > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc6/2.6.24-rc6-mm1/
> > > I have finally given up on using 2.6.24-rc3-mm2 with slub_debug=FZP to
> > > get more information out of the random crashes I had seen with that
> > > version. (Did not crash once with slub_debug, so no new information on
> > > what the cause was)
> > 
> > Murphy: Just after sending that mail the system crashed two times with
> > slub_debug=FZP, but did not show any new informations.
> > No debug output from slub, only this stacktrace: (Its the same I
> > already reported in the 2.6.24-rc3-mm2 thread)
> > 
> > [ 7620.673012] ------------[ cut here ]------------
> > [ 7620.676291] kernel BUG at lib/list_debug.c:33!
> > [ 7620.679440] invalid opcode: 0000 [1] SMP
> > [ 7620.682319] last sysfs file:
> > /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
> > [ 7620.687845] CPU 0
> > [ 7620.689300] Modules linked in: radeon drm nfsd exportfs w83792d
> > ipv6 tuner tea5767 tda8290 tuner_xc2028 tda9887 tuner_simple mt20xx
> > tea5761 tvaudio msp3400 bttv ir_common compat_ioctl32 videobuf_dma_sg
> > videobuf_core btcx_risc tveeprom videodev usbhid v4l2_common
> > v4l1_compat hid i2c_nforce2 sg pata_amd
> > [ 7620.708561] Pid: 5698, comm: nfsv4-svc Not tainted 2.6.24-rc3-mm2 #2
> > [ 7620.713080] RIP: 0010:[<ffffffff803bae54>]  [<ffffffff803bae54>]
> > __list_add+0x54/0x60
> > [ 7620.718667] RSP: 0018:ffff81011bca1dc0  EFLAGS: 00010282
> > [ 7620.722439] RAX: 0000000000000088 RBX: ffff81011c862c48 RCX: 0000000000000002
> > [ 7620.727504] RDX: ffff81011bc82ef0 RSI: 0000000000000001 RDI: ffffffff807590c0
> > [ 7620.732581] RBP: ffff81011bca1dc0 R08: 0000000000000001 R09: 0000000000000000
> > [ 7620.737658] R10: ffff810080058d48 R11: 0000000000000001 R12: ffff81011ed8d1c8
> > [ 7620.742711] R13: ffff81011ed8d200 R14: ffff81011ed8d200 R15: ffff81011cc0e578
> > [ 7620.747806] FS:  00007ffe400116f0(0000) GS:ffffffff807d4000(0000)
> > knlGS:00000000f73558e0
> > [ 7620.753535] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [ 7620.757607] CR2: 00000000017071dc CR3: 00000001188b5000 CR4: 00000000000006e0
> > [ 7620.762677] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > [ 7620.767748] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > [ 7620.772808] Process nfsv4-svc (pid: 5698, threadinfo
> > FFFF81011BCA0000, task FFFF81011BC82EF0)
> > [ 7620.778872] Stack:  ffff81011bca1e00 ffffffff805be26e
> > ffff81011ed8d1d0 ffff81011cc0e578
> > [ 7620.784626]  ffff81011c862c48 ffff81011c8be000 ffff810054a8b060
> > ffff81011cc0e588
> > [ 7620.789913]  ffff81011bca1e10 ffffffff805be367 ffff81011bca1ee0
> > ffffffff805bf0ac
> > [ 7620.795062] Call Trace:
> > [ 7620.796941]  [<ffffffff805be26e>] svc_xprt_enqueue+0x1ae/0x250
> > [ 7620.801087]  [<ffffffff805be367>] svc_xprt_received+0x17/0x20
> > [ 7620.805199]  [<ffffffff805bf0ac>] svc_recv+0x39c/0x840
> > [ 7620.808851]  [<ffffffff805bea3f>] svc_send+0xaf/0xd0
> > [ 7620.812374]  [<ffffffff8022f590>] default_wake_function+0x0/0x10
> > [ 7620.816637]  [<ffffffff803163ea>] nfs_callback_svc+0x7a/0x130
> > [ 7620.820712]  [<ffffffff805cfea2>] trace_hardirqs_on_thunk+0x35/0x3a
> > [ 7620.825174]  [<ffffffff80259f8f>] trace_hardirqs_on+0xbf/0x160
> > [ 7620.829335]  [<ffffffff8020cbc8>] child_rip+0xa/0x12
> > [ 7620.832842]  [<ffffffff8020c2df>] restore_args+0x0/0x30
> > [ 7620.836554]  [<ffffffff80316370>] nfs_callback_svc+0x0/0x130
> > [ 7620.840564]  [<ffffffff8020cbbe>] child_rip+0x0/0x12
> > [ 7620.844102]
> > [ 7620.845168] INFO: lockdep is turned off.
> > [ 7620.847964]
> > [ 7620.847965] Code: 0f 0b eb fe 0f 1f 84 00 00 00 00 00 55 48 8b 16
> > 48 89 e5 e8
> > [ 7620.854334] RIP  [<ffffffff803bae54>] __list_add+0x54/0x60
> > [ 7620.858255]  RSP <ffff81011bca1dc0>
> > [ 7620.860724] Kernel panic - not syncing: Aiee, killing interrupt handler!
> > 
> 
> That looks like a sunrpc bug.  git-nfsd has bene mucking around in there a
> bit.

Can you still reproduce this?  Tom thought there was a chance the
following could fix it.

--b.

From:	Tom Tucker <tom@opengridcomputing.com>
Date:	Sun, 30 Dec 2007 10:07:17 -0600

Bruce/Aime:

Here is what I believe to be the fix for the crashes/svc_xprt BUG_ON
that people are seeing. It would be great if those who have seen this
problem could apply this patch and see if it resolves their problem. 

The common code calls svc_xprt_received on behalf of the transport.
Since the provider was calling it as well, this resulted in clearing the
busy bit/resetting xpt_pool when the BUSY bit wasn't held. 

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4628881..4d39db1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1272,7 +1272,6 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 
 	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
 		svc_xprt_set_local(&svsk->sk_xprt, newsin, newlen);
-		svc_xprt_received(&svsk->sk_xprt);
 		return (struct svc_xprt *)svsk;
 	}
 

-
