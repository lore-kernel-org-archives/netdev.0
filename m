From: Sitsofe Wheeler <sitsofe@gmail.com>
Subject: [hyperv] BUG: unable to handle kernel paging request at
 ffff8801f5bc7cbb (netvsc_select_queue)
Date: Fri, 29 Aug 2014 10:31:41 +0100
Message-ID: <20140829093141.GC11445@sucs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
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

While booting a 10 vcpu system with a post v3.17-rc2 kernel with the
"Drivers: hv: vmbus: Eliminate calls to BUG_ON()",  "Drivers: hv: vmbus:
Miscellaneous cleanup" patches and debugging/verification config options
on I'm seeing the following:

[   31.570860] EXT4-fs (sdb1): mounted filesystem with ordered data mode. Opts: (null)
[   31.799558] systemd-journald[367]: Received request to flush runtime journal from PID 1
[   32.679811] hv_utils: KVP: user-mode registering done.
[   39.826001] hv_netvsc vmbus_0_15: net device safe to remove
[   39.868109] hv_netvsc: hv_netvsc channel opened successfully
[   41.585834] hv_netvsc vmbus_0_15: Send section size: 6144, Section count:2560
[   41.644187] hv_netvsc vmbus_0_15: Device MAC 00:15:5d:6f:02:a5 link state up
[   43.174058] BUG: unable to handle kernel paging request at ffff8801f5bc7cbb
[   43.174956] IP: [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   43.174956] PGD 2db0067 PUD 207dc0067 PMD 207c12067 PTE 80000001f5bc7060
[   43.174956] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   43.174956] CPU: 7 PID: 640 Comm: arping Not tainted 3.17.0-rc2.x86_64-00096-g9c6196f #137
[   43.174956] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   43.174956] task: ffff8800ebc56090 ti: ffff8800ecf04000 task.ti: ffff8800ecf04000
[   43.174956] RIP: 0010:[<ffffffff814e701d>]  [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   43.174956] RSP: 0018:ffff8800ecf07c60  EFLAGS: 00010206
[   43.174956] RAX: 0000000000000000 RBX: ffff8800f13f0000 RCX: 000000000000ffff
[   43.174956] RDX: ffff8801f5bb7cb0 RSI: ffff8800ecf47a80 RDI: ffff8800f13f0000
[   43.174956] RBP: ffff8800ecf07c88 R08: 000000000000002a R09: 0000000000000000
[   43.174956] R10: ffff8801f99b2290 R11: 000000000000000a R12: ffff8800ecf47a80
[   43.174956] R13: 0000000000000000 R14: ffff8800ecfb1bd8 R15: ffff8800ecf47a80
[   43.174956] FS:  00007f69fdf31740(0000) GS:ffff880206ce0000(0000) knlGS:0000000000000000
[   43.174956] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   43.174956] CR2: ffff8801f5bc7cbb CR3: 00000000ecfc9000 CR4: 00000000000406e0
[   43.174956] Stack:
[   43.174956]  ffffffff8167f651 ffff8800f13f0000 000000000000001c 0000000000000000
[   43.174956]  ffff8800ecfb1bd8 ffff8800ecf07d48 ffffffff816833bc ffff8800ebc567d0
[   43.174956]  0000000000000000 ffff8800ecf07d68 0000000000000046 000000000000001c
[   43.174956] Call Trace:
[   43.174956]  [<ffffffff8167f651>] ? packet_pick_tx_queue+0x31/0xa0
[   43.174956]  [<ffffffff816833bc>] packet_sendmsg+0xc1c/0xdd0
[   43.174956]  [<ffffffff810bd106>] ? lock_release_non_nested+0xc6/0x330
[   43.174956]  [<ffffffff815b4368>] sock_sendmsg+0x88/0xb0
[   43.174956]  [<ffffffff81185443>] ? might_fault+0xa3/0xb0
[   43.174956]  [<ffffffff811853fa>] ? might_fault+0x5a/0xb0
[   43.174956]  [<ffffffff815b449e>] SYSC_sendto+0x10e/0x150
[   43.174956]  [<ffffffff811853fa>] ? might_fault+0x5a/0xb0
[   43.174956]  [<ffffffff816a32d5>] ? sysret_check+0x22/0x5d
[   43.174956]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   43.174956]  [<ffffffff8139c09e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   43.174956]  [<ffffffff815b547e>] SyS_sendto+0xe/0x10
[   43.174956]  [<ffffffff816a32a9>] system_call_fastpath+0x16/0x1b
[   43.174956] Code: 00 4d 85 d2 0f 84 1c 01 00 00 44 8b 9f 8c 03 00 00 31 c0 41 83 fb 01 0f 86 1b 01 00 00 0f b7 8e b4 00 00 00 48 8b 96 c0 00 00 00 <66> 83 7c 0a 0c 08 0f 85 01 01 00 00 55 48 89 e5 41 55 41 54 53 
[   43.174956] RIP  [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   43.174956]  RSP <ffff8800ecf07c60>
[   43.174956] CR2: ffff8801f5bc7cbb
[   43.174956] ---[ end trace d476efa8244dbdc1 ]---
[   43.174956] BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:41
[   43.174956] in_atomic(): 0, irqs_disabled(): 1, pid: 640, name: arping
[   43.174956] INFO: lockdep is turned off.
[   43.174956] irq event stamp: 5710
[   43.174956] hardirqs last  enabled at (5709): [<ffffffff81698cb4>] __slab_alloc+0x50b/0x576
[   43.174956] hardirqs last disabled at (5710): [<ffffffff816a5326>] error_sti+0x5/0x6
[   43.174956] softirqs last  enabled at (5662): [<ffffffff815cedb0>] __dev_queue_xmit+0x5b0/0x690
[   43.174956] softirqs last disabled at (5628): [<ffffffff815ce858>] __dev_queue_xmit+0x58/0x690
[   43.174956] CPU: 7 PID: 640 Comm: arping Tainted: G      D        3.17.0-rc2.x86_64-00096-g9c6196f #137
[   43.174956] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   43.174956]  0000000000000046 ffff8800ecf078e0 ffffffff8169a70b ffff8800ebc56090
[   43.174956]  ffff8800ecf078f8 ffffffff8109ec65 ffff8801f35eacd8 ffff8800ecf07918
[   43.174956]  ffffffff816a0d44 ffffffff81090f38 ffff8800ebc56090 ffff8800ecf07938
[   43.174956] Call Trace:
[   43.174956]  [<ffffffff8169a70b>] dump_stack+0x4d/0x66
[   43.174956]  [<ffffffff8109ec65>] __might_sleep+0x115/0x120
[   43.174956]  [<ffffffff816a0d44>] down_read+0x24/0x70
[   43.174956]  [<ffffffff81090f38>] ? __validate_process_creds+0xd8/0xf0
[   43.174956]  [<ffffffff8107f9d4>] exit_signals+0x24/0x140
[   43.174956]  [<ffffffff810737d9>] do_exit+0x129/0xa20
[   43.174956]  [<ffffffff810c4bcc>] ? kmsg_dump+0xfc/0x110
[   43.174956]  [<ffffffff810c4af5>] ? kmsg_dump+0x25/0x110
[   43.174956]  [<ffffffff81006348>] oops_end+0xa8/0xc0
[   43.174956]  [<ffffffff81695288>] no_context+0x322/0x36b
[   43.174956]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   43.174956]  [<ffffffff8169549c>] __bad_area_nosemaphore+0x1cb/0x1e8
[   43.174956]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   43.174956]  [<ffffffff816954cc>] bad_area_nosemaphore+0x13/0x15
[   43.174956]  [<ffffffff8104040e>] __do_page_fault+0x1ee/0x4f0
[   43.174956]  [<ffffffff815bcd6e>] ? __alloc_skb+0x4e/0x240
[   43.174956]  [<ffffffff810bd106>] ? lock_release_non_nested+0xc6/0x330
[   43.174956]  [<ffffffff8139c0dd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   43.174956]  [<ffffffff81040762>] do_page_fault+0x22/0x30
[   43.174956]  [<ffffffff816a5108>] page_fault+0x28/0x30
[   43.174956]  [<ffffffff814e701d>] ? netvsc_select_queue+0x3d/0x150
[   43.174956]  [<ffffffff8167f651>] ? packet_pick_tx_queue+0x31/0xa0
[   43.174956]  [<ffffffff816833bc>] packet_sendmsg+0xc1c/0xdd0
[   43.174956]  [<ffffffff810bd106>] ? lock_release_non_nested+0xc6/0x330
[   43.174956]  [<ffffffff815b4368>] sock_sendmsg+0x88/0xb0
[   43.174956]  [<ffffffff81185443>] ? might_fault+0xa3/0xb0
[   43.174956]  [<ffffffff811853fa>] ? might_fault+0x5a/0xb0
[   43.174956]  [<ffffffff815b449e>] SYSC_sendto+0x10e/0x150
[   43.174956]  [<ffffffff811853fa>] ? might_fault+0x5a/0xb0
[   43.174956]  [<ffffffff816a32d5>] ? sysret_check+0x22/0x5d
[   43.174956]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   43.174956]  [<ffffffff8139c09e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   43.174956]  [<ffffffff815b547e>] SyS_sendto+0xe/0x10
[   43.174956]  [<ffffffff816a32a9>] system_call_fastpath+0x16/0x1b
[   43.174956] BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:41
[   43.174956] in_atomic(): 0, irqs_disabled(): 1, pid: 640, name: arping
[   43.174956] INFO: lockdep is turned off.
[   43.174956] irq event stamp: 5710
[   43.174956] hardirqs last  enabled at (5709): [<ffffffff81698cb4>] __slab_alloc+0x50b/0x576
[   43.174956] hardirqs last disabled at (5710): [<ffffffff816a5326>] error_sti+0x5/0x6
[   43.174956] softirqs last  enabled at (5662): [<ffffffff815cedb0>] __dev_queue_xmit+0x5b0/0x690
[   43.174956] softirqs last disabled at (5628): [<ffffffff815ce858>] __dev_queue_xmit+0x58/0x690
[   43.174956] CPU: 7 PID: 640 Comm: arping Tainted: G      D        3.17.0-rc2.x86_64-00096-g9c6196f #137
[   43.174956] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   43.174956]  ffff8800ebc56090 ffff8800ecf078d0 ffffffff8169a70b ffff8800ebc56090
[   43.174956]  ffff8800ecf078e8 ffffffff8109ec65 ffff8801f3afba18 ffff8800ecf07908
[   43.174956]  ffffffff816a0d44 ffffffff810d5cb1 ffff8801f35ea880 ffff8800ecf07938
[   43.174956] Call Trace:
[   43.174956]  [<ffffffff8169a70b>] dump_stack+0x4d/0x66
[   43.174956]  [<ffffffff8109ec65>] __might_sleep+0x115/0x120
[   43.174956]  [<ffffffff816a0d44>] down_read+0x24/0x70
[   43.174956]  [<ffffffff810d5cb1>] ? hrtimer_try_to_cancel+0xf1/0x100
[   43.174956]  [<ffffffff810ec612>] acct_collect+0x52/0x1c0
[   43.174956]  [<ffffffff81074082>] do_exit+0x9d2/0xa20
[   43.174956]  [<ffffffff810c4bcc>] ? kmsg_dump+0xfc/0x110
[   43.174956]  [<ffffffff810c4af5>] ? kmsg_dump+0x25/0x110
[   43.174956]  [<ffffffff81006348>] oops_end+0xa8/0xc0
[   43.174956]  [<ffffffff81695288>] no_context+0x322/0x36b
[   43.174956]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   43.174956]  [<ffffffff8169549c>] __bad_area_nosemaphore+0x1cb/0x1e8
[   43.174956]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   43.174956]  [<ffffffff816954cc>] bad_area_nosemaphore+0x13/0x15
[   43.174956]  [<ffffffff8104040e>] __do_page_fault+0x1ee/0x4f0
[   43.174956]  [<ffffffff815bcd6e>] ? __alloc_skb+0x4e/0x240
[   43.174956]  [<ffffffff810bd106>] ? lock_release_non_nested+0xc6/0x330
[   43.174956]  [<ffffffff8139c0dd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   43.174956]  [<ffffffff81040762>] do_page_fault+0x22/0x30
[   43.174956]  [<ffffffff816a5108>] page_fault+0x28/0x30
[   43.174956]  [<ffffffff814e701d>] ? netvsc_select_queue+0x3d/0x150
[   43.174956]  [<ffffffff8167f651>] ? packet_pick_tx_queue+0x31/0xa0
[   43.174956]  [<ffffffff816833bc>] packet_sendmsg+0xc1c/0xdd0
[   43.174956]  [<ffffffff810bd106>] ? lock_release_non_nested+0xc6/0x330
[   43.174956]  [<ffffffff815b4368>] sock_sendmsg+0x88/0xb0
[   43.174956]  [<ffffffff81185443>] ? might_fault+0xa3/0xb0
[   43.174956]  [<ffffffff811853fa>] ? might_fault+0x5a/0xb0
[   48.347217]  [<ffffffff815b449e>] SYSC_sendto+0x10e/0x150
[   48.347217]  [<ffffffff811853fa>] ? might_fault+0x5a/0xb0
[   48.347217]  [<ffffffff816a32d5>] ? sysret_check+0x22/0x5d
[   48.347217]  [<ffffffff810b97fd>] ? trace_hardirqs_on_caller+0x17d/0x210
[   48.347217]  [<ffffffff8139c09e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   48.347217]  [<ffffffff815b547e>] SyS_sendto+0xe/0x10
[   48.347217]  [<ffffffff816a32a9>] system_call_fastpath+0x16/0x1b
[   48.663676] BUG: unable to handle kernel paging request at ffff8800ee453a23
[   48.708188] IP:
[   48.708188]  [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   48.708188] PGD 2db0067 
[   48.708188] PUD 2075be067 
[   48.708188] PMD 20744b067 
[   48.708188] PTE 80000000ee453060

[   48.708188] Oops: 0000 [#2] 
[   48.708188] SMP 
[   48.708188] DEBUG_PAGEALLOC

[   48.708188] CPU: 7 PID: 609 Comm: dhclient Tainted: G      D        3.17.0-rc2.x86_64-00096-g9c6196f #137
[   48.708188] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   48.708188] task: ffff8801f9946090 ti: ffff8800ee468000 task.ti: ffff8800ee468000
[   48.708188] RIP: 0010:[<ffffffff814e701d>] 
[   48.708188]  [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   48.708188] RSP: 0018:ffff8800ee46bcd8  EFLAGS: 00010206
[   48.708188] RAX: 0000000000000000 RBX: ffff8800f13f0000 RCX: 000000000000ffff
[   48.708188] RDX: ffff8800ee443a18 RSI: ffff8800ecf446c0 RDI: ffff8800f13f0000
[   48.708188] RBP: ffff8800ee46bd00 R08: 0000000000000156 R09: 0000000000000000
[   48.708188] R10: ffff8801f99b2290 R11: 000000000000000a R12: ffff8800ecf446c0
[   48.708188] R13: 0000000000000000 R14: ffff8800ecfb0948 R15: ffff8800ecf446c0
[   48.708188] FS:  00007f5b90b22880(0000) GS:ffff880206ce0000(0000) knlGS:0000000000000000
[   48.708188] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   48.708188] CR2: ffff8800ee453a23 CR3: 00000000ec783000 CR4: 00000000000406e0
[   48.708188] Stack:
[   48.708188]  ffffffff8167f651
[   48.708188]  ffff8800f13f0000
[   48.708188]  0000000000000156
[   48.708188]  0000000000000000

[   48.708188]  ffff8800ecfb0948
[   48.708188]  ffff8800ee46bdc0
[   48.708188]  ffffffff816833bc
[   48.708188]  ffffffff00000000

[   48.708188]  00000000ffffffff
[   48.708188]  ffff8800ee46bd58
[   48.708188]  ffff8800f3354440
[   48.708188]  0000000000000156

[   48.708188] Call Trace:

[   48.708188]  [<ffffffff8167f651>] ? packet_pick_tx_queue+0x31/0xa0
[   48.708188]  [<ffffffff816833bc>] packet_sendmsg+0xc1c/0xdd0
[   48.708188]  [<ffffffff815b357b>] sock_aio_write+0xfb/0x120
[   48.708188]  [<ffffffff811c262a>] do_sync_write+0x5a/0x80
[   48.708188]  [<ffffffff811c2925>] vfs_write+0xe5/0x1d0
[   48.708188]  [<ffffffff811c2b09>] SyS_write+0x49/0xb0
[   48.708188]  [<ffffffff816a32a9>] system_call_fastpath+0x16/0x1b
[   48.708188] Code: 00 4d 85 d2 0f 84 1c 01 00 00 44 8b 9f 8c 03 00 00 31 c0 41 83 fb 01 0f 86 1b 01 00 00 0f b7 8e b4 00 00 00 48 8b 96 c0 00 00 00 <66> 83 7c 0a 0c 08 0f 85 01 01 00 00 55 48 89 e5 41 55 41 54 53 
[   48.708188] RIP  [<ffffffff814e701d>] netvsc_select_queue+0x3d/0x150
[   48.708188]  RSP <ffff8800ee46bcd8>
[   48.708188] CR2: ffff8800ee453a23
[   48.708188] ---[ end trace d476efa8244dbdc2 ]---
[   48.708188] BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:41
[   48.708188] in_atomic(): 0, irqs_disabled(): 1, pid: 609, name: dhclient
[   48.708188] INFO: lockdep is turned off.
[   48.708188] irq event stamp: 97752
[   48.708188] hardirqs last  enabled at (97751): [<ffffffff816a263d>] _raw_spin_unlock_irqrestore+0x4d/0x70
[   48.708188] hardirqs last disabled at (97752): [<ffffffff816a251d>] _raw_spin_lock_irq+0x1d/0x60
[   48.708188] softirqs last  enabled at (97356): [<ffffffff810753f8>] __do_softirq+0x278/0x320
[   48.708188] softirqs last disabled at (97341): [<ffffffff81075768>] irq_exit+0x58/0xc0
[   48.708188] CPU: 7 PID: 609 Comm: dhclient Tainted: G      D        3.17.0-rc2.x86_64-00096-g9c6196f #137
[   48.708188] Hardware name: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090006  05/23/2012
[   48.708188]  0000000000000046 ffff8800ee46b950 ffffffff8169a70b ffff8801f9946090
[   48.708188]  ffff8800ee46b968 ffffffff8109ec65 ffff8801f35e9898 ffff8800ee46b988
[   48.708188]  ffffffff816a0d44 ffffffff81090f38 ffff8801f9946090 ffff8800ee46b9a8
[   48.708188] Call Trace:
[   48.708188]  [<ffffffff8169a70b>] dump_stack+0x4d/0x66
[   48.708188]  [<ffffffff8109ec65>] __might_sleep+0x115/0x120
[   48.708188]  [<ffffffff816a0d44>] down_read+0x24/0x70
[   48.708188]  [<ffffffff81090f38>] ? __validate_process_creds+0xd8/0xf0
[   48.708188]  [<ffffffff8107f9d4>] exit_signals+0x24/0x140
[   48.708188]  [<ffffffff810737d9>] do_exit+0x129/0xa20
[   48.708188]  [<ffffffff810c4bcc>] ? kmsg_dump+0xfc/0x110
[   48.708188]  [<ffffffff810c4af5>] ? kmsg_dump+0x25/0x110
[   48.708188]  [<ffffffff81006348>] oops_end+0xa8/0xc0
[   48.708188]  [<ffffffff81695288>] no_context+0x322/0x36b
[   48.708188]  [<ffffffff8169549c>] __bad_area_nosemaphore+0x1cb/0x1e8
[   48.708188]  [<ffffffff816954cc>] bad_area_nosemaphore+0x13/0x15
[   48.708188]  [<ffffffff8104040e>] __do_page_fault+0x1ee/0x4f0
[   48.708188]  [<ffffffff815bcd6e>] ? __alloc_skb+0x4e/0x240
[   48.708188]  [<ffffffff811a990e>] ? __kmalloc_node_track_caller+0x15e/0x2f0
[   48.708188]  [<ffffffff810b9b0d>] ? trace_hardirqs_off+0xd/0x10
[   48.708188]  [<ffffffff8139c0dd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[   48.708188]  [<ffffffff81040762>] do_page_fault+0x22/0x30
[   48.708188]  [<ffffffff816a5108>] page_fault+0x28/0x30
[   48.708188]  [<ffffffff814e701d>] ? netvsc_select_queue+0x3d/0x150
[   48.708188]  [<ffffffff8167f651>] ? packet_pick_tx_queue+0x31/0xa0
[   48.708188]  [<ffffffff816833bc>] packet_sendmsg+0xc1c/0xdd0
[   48.708188]  [<ffffffff815b357b>] sock_aio_write+0xfb/0x120
[   48.708188]  [<ffffffff811c262a>] do_sync_write+0x5a/0x80
[   48.708188]  [<ffffffff811c2925>] vfs_write+0xe5/0x1d0
[   48.708188]  [<ffffffff811c2b09>] SyS_write+0x49/0xb0
[   48.708188]  [<ffffffff816a32a9>] system_call_fastpath+0x16/0x1b

In https://lkml.org/lkml/2014/8/19/133 (Re: BUG: unable to handle kernel
paging request at ffff8801f3febe63 (netvsc_select_queue)) there is the
following:

On Tue, Aug 19, 2014 at 10:57:30AM +0200, Daniel Borkmann wrote:
>
> Hmm, I am not really familiar with hyper-v, but it seems 5b54dac856cb
> ("hyperv: Add support for virtual Receive Side Scaling (vRSS)") has
> been introduced after 0fd5d57ba345 ("packet: check for
> ndo_select_queue during queue selection").
> 
> arping seems to send a raw packet (AF_PACKET) via normal
> packet_sendmsg() out and when doing the queue selection in
> packet_pick_tx_queue(), we discover that the device has
> ndo_select_queue implemented, so we respect that and call into it. In
> netvsc_select_queue(), the fallback of __packet_pick_tx_queue() is not
> being invoked here.
> 
> Given that the next log message is "hv_netvsc vmbus_0_15: net device
> safe to remove" ... could it be that your back pointer to the device
> context (the actual struct hv_device) is already invalid when you try
> to get hv_get_drvdata(hdev) as it's sort of decoupled from
> netdev_priv(ndev) ? (Just a wild guess ...)

So I'm guessing this is the same issue.

-- 
Sitsofe | http://sucs.org/~sits/
