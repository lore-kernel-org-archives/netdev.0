From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at include/net/netns/generic.h:41
Date: Mon, 2 Apr 2012 13:26:00 -0400
Message-ID: <20120402172600.GA3728@redhat.com>
References: <20120328002346.GB3077@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com
To: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120328002346.GB3077@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[added Trond to cc:]

still seeing this in 3.4rc1

	Dave


On Tue, Mar 27, 2012 at 08:23:46PM -0400, Dave Jones wrote:
 > I started seeing this every boot.. (v3.3-6972-ge22057c)
 > 
 > [   17.103931] ------------[ cut here ]------------
 > [   17.105987] RPC: Registered named UNIX socket transport module.
 > [   17.105989] RPC: Registered udp transport module.
 > [   17.105990] RPC: Registered tcp transport module.
 > [   17.105992] RPC: Registered tcp NFSv4.1 backchannel transport module.
 > [   17.104856] kernel BUG at include/net/netns/generic.h:41!
 > [   17.104856] invalid opcode: 0000 [#1] PREEMPT SMP 
 > [   17.104856] CPU 0 
 > [   17.104856] Modules linked in: sunrpc btrfs zlib_deflate libcrc32c firewire_ohci firewire_core sata_sil crc_itu_t floppy radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core
 > [   17.104856] 
 > [   17.104856] Pid: 416, comm: mount Not tainted 3.3.0+ #19                  /D975XBX
 > [   17.104856] RIP: 0010:[<ffffffffa029068b>]  [<ffffffffa029068b>] rpc_fill_super+0x29b/0x2a0 [sunrpc]
 > [   17.104856] RSP: 0018:ffff8800b52c5cf8  EFLAGS: 00010246
 > [   17.104856] RAX: 0000000000000001 RBX: ffff8800a394dcd0 RCX: 0000000000000000
 > [   17.104856] RDX: ffff8800a4c10000 RSI: ffffffff81c2cd00 RDI: ffff8800a4c10918
 > [   17.104856] RBP: ffff8800b52c5d38 R08: 0000000000000001 R09: 0000000000000000
 > [   17.104856] R10: 0000000000000001 R11: 0000000000000002 R12: 0000000000000000
 > [   17.104856] R13: ffffffff82d0f140 R14: ffff8800ba54c000 R15: 0000000000000000
 > [   17.104856] FS:  00007f1a97593800(0000) GS:ffff8800bf600000(0000) knlGS:0000000000000000
 > [   17.104856] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 > [   17.104856] CR2: 0000003e92478a90 CR3: 00000000a4d22000 CR4: 00000000000007f0
 > [   17.104856] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
 > [   17.104856] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
 > [   17.104856] Process mount (pid: 416, threadinfo ffff8800b52c4000, task ffff8800a4c10000)
 > [   17.104856] Stack:
 > [   17.104856]  ffffffffa02903f0 00000000000000d0 000060ff40002438 ffffffff82d0f140
 > [   17.104856]  0000000000000000 ffffffffa02903f0 ffff8800a394dcd0 0000000000000000
 > [   17.104856]  ffff8800b52c5d88 ffffffff811a9d8c 0000000000000003 ffffffff00000001
 > [   17.104856] Call Trace:
 > [   17.104856]  [<ffffffffa02903f0>] ? rpc_mkpipe_dentry+0x180/0x180 [sunrpc]
 > [   17.104856]  [<ffffffffa02903f0>] ? rpc_mkpipe_dentry+0x180/0x180 [sunrpc]
 > [   17.104856]  [<ffffffff811a9d8c>] mount_ns+0xac/0xe0
 > [   17.104856]  [<ffffffffa028ea39>] rpc_mount+0x29/0x30 [sunrpc]
 > [   17.104856]  [<ffffffff811aaab3>] mount_fs+0x43/0x1b0
 > [   17.104856]  [<ffffffff8115dd80>] ? __alloc_percpu+0x10/0x20
 > [   17.104856]  [<ffffffff811c8af2>] vfs_kern_mount+0x72/0x100
 > [   17.104856]  [<ffffffff811c92d4>] do_kern_mount+0x54/0x110
 > [   17.104856]  [<ffffffff811caa44>] do_mount+0x1a4/0x830
 > [   17.104856]  [<ffffffff8115765b>] ? memdup_user+0x4b/0x90
 > [   17.104856]  [<ffffffff811576fb>] ? strndup_user+0x5b/0x80
 > [   17.104856]  [<ffffffff811cb210>] sys_mount+0x90/0xe0
 > [   17.104856]  [<ffffffff816624d2>] system_call_fastpath+0x16/0x1b
 > [   17.104856] Code: e8 db 7a e6 e0 84 c0 74 c9 48 c7 c7 00 cd c2 81 e8 bb e5 e1 e0 85 c0 0f 85 f4 fd ff ff eb b3 90 41 bf f4 ff ff ff e9 ce fe ff ff <0f> 0b 0f 0b 90 55 48 89 e5 41 54 53 48 83 ec 10 66 66 66 66 90 
 > [   17.104856] RIP  [<ffffffffa029068b>] rpc_fill_super+0x29b/0x2a0 [sunrpc]
 > [   17.104856]  RSP <ffff8800b52c5cf8>
 > [   17.469688] ---[ end trace 74871f164631364c ]---
 > [   17.488286] BUG: sleeping function called from invalid context at kernel/rwsem.c:21
 > [   17.498626] in_atomic(): 0, irqs_disabled(): 0, pid: 416, name: mount
 > [   17.498629] INFO: lockdep is turned off.
 > [   17.498631] Pid: 416, comm: mount Tainted: G      D      3.3.0+ #19
 > [   17.498632] Call Trace:
 > [   17.498639]  [<ffffffff8107d96c>] __might_sleep+0x13c/0x1f0
 > [   17.498644]  [<ffffffff81657c06>] down_read+0x26/0x93
 > [   17.498646]  [<ffffffff81061164>] exit_signals+0x24/0x130
 > [   17.498650]  [<ffffffff8104d3cf>] do_exit+0xbf/0xb60
 > [   17.498652]  [<ffffffff8104a443>] ? kmsg_dump+0x1c3/0x2c0
 > [   17.498654]  [<ffffffff8104a2ff>] ? kmsg_dump+0x7f/0x2c0
 > [   17.498657]  [<ffffffff8165b9d4>] oops_end+0xa4/0xf0
 > [   17.498660]  [<ffffffff81005be8>] die+0x58/0x90
 > [   17.498662]  [<ffffffff8165b2f4>] do_trap+0xc4/0x170
 > [   17.498665]  [<ffffffff81002f35>] ? do_invalid_op+0xa5/0xb0
 > [   17.498667]  [<ffffffff81002f25>] do_invalid_op+0x95/0xb0
 > [   17.498684]  [<ffffffffa029068b>] ? rpc_fill_super+0x29b/0x2a0 [sunrpc]
 > [   17.498686]  [<ffffffff8165e3cd>] ? sub_preempt_count+0x9d/0xd0
 > [   17.498689]  [<ffffffff8131baad>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 > [   17.498692]  [<ffffffff8165ac4d>] ? restore_args+0x30/0x30
 > [   17.498696]  [<ffffffff81663755>] invalid_op+0x15/0x20
 > [   17.498704]  [<ffffffffa029068b>] ? rpc_fill_super+0x29b/0x2a0 [sunrpc]
 > [   17.498713]  [<ffffffffa0290675>] ? rpc_fill_super+0x285/0x2a0 [sunrpc]
 > [   17.498721]  [<ffffffffa02903f0>] ? rpc_mkpipe_dentry+0x180/0x180 [sunrpc]
 > [   17.498731]  [<ffffffffa02903f0>] ? rpc_mkpipe_dentry+0x180/0x180 [sunrpc]
 > [   17.498734]  [<ffffffff811a9d8c>] mount_ns+0xac/0xe0
 > [   17.498743]  [<ffffffffa028ea39>] rpc_mount+0x29/0x30 [sunrpc]
 > [   17.498746]  [<ffffffff811aaab3>] mount_fs+0x43/0x1b0
 > [   17.498750]  [<ffffffff8115dd80>] ? __alloc_percpu+0x10/0x20
 > [   17.498754]  [<ffffffff811c8af2>] vfs_kern_mount+0x72/0x100
 > [   17.498756]  [<ffffffff811c92d4>] do_kern_mount+0x54/0x110
 > [   17.498760]  [<ffffffff811caa44>] do_mount+0x1a4/0x830
 > [   17.498763]  [<ffffffff8115765b>] ? memdup_user+0x4b/0x90
 > [   17.498765]  [<ffffffff811576fb>] ? strndup_user+0x5b/0x80
 > [   17.498769]  [<ffffffff811cb210>] sys_mount+0x90/0xe0
 > [   17.498773]  [<ffffffff816624d2>] system_call_fastpath+0x16/0x1b
 > [   17.775067] systemd[1]: var-lib-nfs-rpc_pipefs.mount mount process exited, code=killed status=11
 > [   17.829617] systemd[1]: Job nfs-idmap.service/start failed with result 'dependency'.
 > [   17.856061] systemd[1]: Unit var-lib-nfs-rpc_pipefs.mount entered failed state.
 > 
---end quoted text---
