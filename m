From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: Re: [hyperv] BUG: unable to handle kernel paging request at
 ffff8801f5bc7cbb (netvsc_select_queue)
Date: Fri, 29 Aug 2014 20:49:27 +0100
Message-ID: <20140829194927.GA20771@sucs.org>
References: <20140829093141.GC11445@sucs.org>
 <9b92bf4b20ea4fe7a6be0072e738da3c@BY2PR0301MB0711.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Daniel Borkmann <dborkman@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <9b92bf4b20ea4fe7a6be0072e738da3c@BY2PR0301MB0711.namprd03.prod.outlook.com>
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

On Fri, Aug 29, 2014 at 05:18:51PM +0000, KY Srinivasan wrote:
> 
> > -----Original Message-----
> > From: Sitsofe Wheeler [mailto:sitsofe@gmail.com]
> > Sent: Friday, August 29, 2014 2:32 AM
> > To: Dexuan Cui
> > Cc: KY Srinivasan; Greg Kroah-Hartman; Haiyang Zhang;
> > devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> > netdev@vger.kernel.org; David Miller; Daniel Borkmann
> > Subject: [hyperv] BUG: unable to handle kernel paging request at
> > ffff8801f5bc7cbb (netvsc_select_queue)
> > 
> > While booting a 10 vcpu system with a post v3.17-rc2 kernel with the
> > "Drivers: hv: vmbus: Eliminate calls to BUG_ON()",  "Drivers: hv: vmbus:
> > Miscellaneous cleanup" patches and debugging/verification config options on
> > I'm seeing the following:
> 
> Could you please try the following patch:
> 
> >From c8a6a5570f9a7f8b9a2b47f165848e5533091e79 Mon Sep 17 00:00:00 2001
> From: K. Y. Srinivasan <kys@microsoft.com>
> Date: Fri, 29 Aug 2014 11:18:18 -0700
> Subject: [PATCH 1/1] Drivers: net: hyperv: Cleanup  netvsc_change_mtu ()

With this issue I'm just booting but one interface has been configured
to have an MTU of 9000. The guest has three interfaces - one for each of
the two real network cards and one private interface.

Here's what I see with your previous patches and the patch from your
email:

[   28.340343] psmouse serio1: trackpoint: IBM TrackPoint firmware: 0x01, buttons: 0/0
[   28.393371] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio1/input/input4
[   29.511276] EXT4-fs (sda1): re-mounted. Opts: (null)
[   29.555201] systemd-udevd[362]: starting version 208
[   30.498472] md: bind<sdc>
[   30.563501] md: personality for level -1 is not loaded!
[   30.673633] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: (null)
[   30.915000] systemd-journald[366]: Received request to flush runtime journal from PID 1
[   32.050485] hv_utils: KVP: user-mode registering done.
[   33.574365] BUG: unable to handle kernel paging request at ffff8801f39ba503
[   33.574588] IP: [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   33.574588] PGD 2db0067 PUD 207dc0067 PMD 207c23067 PTE 80000001f39ba060
[   33.574588] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   33.574588] CPU: 3 PID: 543 Comm: dhclient Not tainted 3.17.0-rc2.x86_64-00096-g9c6196f-dirty #138
[   33.574588] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   33.574588] task: ffff8800ecfce090 ti: ffff8801f9850000 task.ti: ffff8801f9850000
[   33.574588] RIP: 0010:[<ffffffff814e701d>]  [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   33.574588] RSP: 0018:ffff8801f9853cd8  EFLAGS: 00010206
[   33.574588] RAX: 0000000000000000 RBX: ffff8801f7dfc520 RCX: 000000000000ffff
[   33.574588] RDX: ffff8801f39aa4f8 RSI: ffff8801f366d200 RDI: ffff8801f7dfc520
[   33.574588] RBP: ffff8801f9853d00 R08: 0000000000000156 R09: 0000000000000000
[   33.574588] R10: ffff8801f7dfb3d8 R11: 000000000000000a R12: ffff8801f366d200
[   33.574588] R13: 0000000000000000 R14: ffff8801f37eb7b0 R15: ffff8801f366d200
[   33.574588] FS:  00007f19e6182880(0000) GS:ffff880206c60000(0000) knlGS:0000000000000000
[   33.574588] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   33.574588] CR2: ffff8801f39ba503 CR3: 00000001f3671000 CR4: 00000000000406e0
[   33.574588] Stack:
[   33.574588]  ffffffff8167f651 ffff8801f7dfc520 0000000000000156 0000000000000000
[   33.574588]  ffff8801f37eb7b0 ffff8801f9853dc0 ffffffff816833bc ffffffff00000000
[   33.574588]  00000000ffffffff ffff8801f9853d58 ffff8801f9f224c0 0000000000000156
[   33.574588] Call Trace:
[   33.574588]  [<ffffffff8167f651>] ? packet_pick_tx_queue+0x31/0xa0
[   33.574588]  [<ffffffff816833bc>] packet_sendmsg+0xc1c/0xdd0
[   33.574588]  [<ffffffff815b357b>] sock_aio_write+0xfb/0x120
[   33.574588]  [<ffffffff811c262a>] do_sync_write+0x5a/0x80
[   33.574588]  [<ffffffff811c2925>] vfs_write+0xe5/0x1d0
[   33.574588]  [<ffffffff811c2b09>] SyS_write+0x49/0xb0
[   33.574588]  [<ffffffff816a32a9>] system_call_fastpath+0x16/0x1b
[   33.574588] Code: 00 4d 85 d2 0f 84 1c 01 00 00 44 8b 9f 8c 03 00 00 31 c0 41 83 fb 01 0f 86 1b 01 00 00 0f b7 8e b4 00 00 00 48 8b 96 c0 00 00 00 <66> 83 7c 0a 0c 08 0f 85 01 01 00 00 55 48 89 e5 41 55 41 54 53 
[   33.574588] RIP  [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   33.574588]  RSP <ffff8801f9853cd8>
[   33.574588] CR2: ffff8801f39ba503
[   33.574588] ---[ end trace 760148d3316306ec ]---
[   33.574588] BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:41
[   33.574588] in_atomic(): 0, irqs_disabled(): 1, pid: 543, name: dhclient
[   33.574588] INFO: lockdep is turned off.
[   33.574588] irq event stamp: 95826
[   33.574588] hardirqs last  enabled at (95825): [<ffffffff81698cb4>] __slab_alloc+0x50b/0x576
[   33.574588] hardirqs last disabled at (95826): [<ffffffff816a5326>] error_sti+0x5/0x6
[   33.574588] softirqs last  enabled at (95758): [<ffffffff815ba278>] release_sock+0x1b8/0x210
[   33.574588] softirqs last disabled at (95756): [<ffffffff815ba0f4>] release_sock+0x34/0x210
[   35.698953] CPU: 3 PID: 543 Comm: dhclient Tainted: G      D        3.17.0-rc2.x86_64-00096-g9c6196f-dirty #138
[   35.698953] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   35.698953]  0000000000000046 ffff8801f9853950 ffffffff8169a70b ffff8800ecfce090
[   35.698953]  ffff8801f9853968 ffffffff8109ec65 ffff8800eced62d8 ffff8801f9853988
[   35.698953]  ffffffff816a0d44 ffffffff81090f38 ffff8800ecfce090 ffff8801f98539a8
[   35.698953] Call Trace:
[   35.698953]  [<ffffffff8169a70b>] dump_stack+0x4d/0x66
[   35.698953]  [<ffffffff8109ec65>] __might_sleep+0x115/0x120
[   35.698953]  [<ffffffff816a0d44>] down_read+0x24/0x70
[   35.698953]  [<ffffffff81090f38>] ? __validate_process_creds+0xd8/0xf0
[   35.698953]  [<ffffffff8107f9d4>] exit_signals+0x24/0x140
[   35.698953]  [<ffffffff810737d9>] do_exit+0x129/0xa20
[   35.698953]  [<ffffffff810c4bcc>] ? kmsg_dump+0xfc/0x110
[   35.698953]  [<ffffffff810c4af5>] ? kmsg_dump+0x25/0x110
[   35.698953]  [<ffffffff81006348>] oops_end+0xa8/0xc0
[   35.698953]  [<ffffffff81695288>] no_context+0x322/0x36b
[   35.698953]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   35.698953]  [<ffffffff8169549c>] __bad_area_nosemaphore+0x1cb/0x1e8
[   35.698953]  [<ffffffff816954cc>] bad_area_nosemaphore+0x13/0x15
[   35.698953]  [<ffffffff8104040e>] __do_page_fault+0x1ee/0x4f0
[   35.698953]  [<ffffffff8109c9db>] ? try_to_wake_up+0x3eb/0x400
[   35.698953]  [<ffffffff810bd106>] ? lock_release_non_nested+0xc6/0x330
[   35.698953]  [<ffffffff8139c0dd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   35.698953]  [<ffffffff81040762>] do_page_fault+0x22/0x30
[   35.698953]  [<ffffffff816a5108>] page_fault+0x28/0x30
[   35.698953]  [<ffffffff814e701d>] ? netvsc_select_queue+0x3d/0x150
[   35.698953]  [<ffffffff8167f651>] ? packet_pick_tx_queue+0x31/0xa0
[   35.698953]  [<ffffffff816833bc>] packet_sendmsg+0xc1c/0xdd0
[   35.698953]  [<ffffffff815b357b>] sock_aio_write+0xfb/0x120
[   35.698953]  [<ffffffff811c262a>] do_sync_write+0x5a/0x80
[   35.698953]  [<ffffffff811c2925>] vfs_write+0xe5/0x1d0
[   35.698953]  [<ffffffff811c2b09>] SyS_write+0x49/0xb0
[   35.698953]  [<ffffffff816a32a9>] system_call_fastpath+0x16/0x1b
[   35.698953] BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:41
[   35.698953] in_atomic(): 0, irqs_disabled(): 1, pid: 543, name: dhclient
[   35.698953] INFO: lockdep is turned off.
[   35.698953] irq event stamp: 95826
[   35.698953] hardirqs last  enabled at (95825): [<ffffffff81698cb4>] __slab_alloc+0x50b/0x576
[   35.698953] hardirqs last disabled at (95826): [<ffffffff816a5326>] error_sti+0x5/0x6
[   35.698953] softirqs last  enabled at (95758): [<ffffffff815ba278>] release_sock+0x1b8/0x210
[   35.698953] softirqs last disabled at (95756): [<ffffffff815ba0f4>] release_sock+0x34/0x210
[   35.698953] CPU: 3 PID: 543 Comm: dhclient Tainted: G      D        3.17.0-rc2.x86_64-00096-g9c6196f-dirty #138
[   37.503488] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   37.503488]  ffff8800ecfce090 ffff8801f9853940 ffffffff8169a70b ffff8800ecfce090
[   37.503488]  ffff8801f9853958 ffffffff8109ec65 ffff8801f3473a18 ffff8801f9853978
[   37.503488]  ffffffff816a0d44 ffffffff810d5cb1 ffff8800eced5e80 ffff8801f98539a8
[   37.503488] Call Trace:
[   37.503488]  [<ffffffff8169a70b>] dump_stack+0x4d/0x66
[   37.503488]  [<ffffffff8109ec65>] __might_sleep+0x115/0x120
[   37.503488]  [<ffffffff816a0d44>] down_read+0x24/0x70
[   37.503488]  [<ffffffff810d5cb1>] ? hrtimer_try_to_cancel+0xf1/0x100
[   37.503488]  [<ffffffff810ec612>] acct_collect+0x52/0x1c0
[   37.503488]  [<ffffffff81074082>] do_exit+0x9d2/0xa20
[   37.503488]  [<ffffffff810c4bcc>] ? kmsg_dump+0xfc/0x110
[   37.503488]  [<ffffffff810c4af5>] ? kmsg_dump+0x25/0x110
[   37.503488]  [<ffffffff81006348>] oops_end+0xa8/0xc0
[   37.503488]  [<ffffffff81695288>] no_context+0x322/0x36b
[   37.503488]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   37.503488]  [<ffffffff8169549c>] __bad_area_nosemaphore+0x1cb/0x1e8
[   37.503488]  [<ffffffff816954cc>] bad_area_nosemaphore+0x13/0x15
[   37.503488]  [<ffffffff8104040e>] __do_page_fault+0x1ee/0x4f0
[   37.503488]  [<ffffffff8109c9db>] ? try_to_wake_up+0x3eb/0x400
[   37.503488]  [<ffffffff810bd106>] ? lock_release_non_nested+0xc6/0x330
[   37.503488]  [<ffffffff8139c0dd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   37.503488]  [<ffffffff81040762>] do_page_fault+0x22/0x30
[   37.503488]  [<ffffffff816a5108>] page_fault+0x28/0x30
[   37.503488]  [<ffffffff814e701d>] ? netvsc_select_queue+0x3d/0x150
[   37.503488]  [<ffffffff8167f651>] ? packet_pick_tx_queue+0x31/0xa0
[   37.503488]  [<ffffffff816833bc>] packet_sendmsg+0xc1c/0xdd0
[   37.503488]  [<ffffffff815b357b>] sock_aio_write+0xfb/0x120
[   37.503488]  [<ffffffff811c262a>] do_sync_write+0x5a/0x80
[   37.503488]  [<ffffffff811c2925>] vfs_write+0xe5/0x1d0
[   37.503488]  [<ffffffff811c2b09>] SyS_write+0x49/0xb0
[   37.503488]  [<ffffffff816a32a9>] system_call_fastpath+0x16/0x1b
[   37.504231] [sched_delayed] sched: RT throttling activated
[   39.104323] hv_netvsc vmbus_0_15: net device safe to remove
[   39.149816] hv_netvsc: hv_netvsc channel opened successfully
[   40.899617] hv_netvsc vmbus_0_15: Send section size: 6144, Section count:2560
[   40.947265] hv_netvsc vmbus_0_15: Device MAC 00:15:5d:6f:02:a5 link state up

The network interface that stopped working after the above was not the
one set to have an MTU of 9000...

-- 
Sitsofe | http://sucs.org/~sits/
