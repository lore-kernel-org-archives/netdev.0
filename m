From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: kernel BUG at net/key/af_key.c:LINE!
Date: Tue, 24 Oct 2017 17:10:06 +0200
Message-ID: <CACT4Y+b9+1AAJk5Jxddae5okBXo9oaKu0m8gzbgyEnzGByY1hg@mail.gmail.com>
References: <001a114a958ce46160055c4c4f66@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        syzkaller-bugs@googlegroups.com
To: syzbot
        <bot+413384116f7f7dab7903d54c53fc4af6a4441965@syzkaller.appspotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <001a114a958ce46160055c4c4f66@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2017 at 5:08 PM, syzbot
<bot+413384116f7f7dab7903d54c53fc4af6a4441965@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 02a2b05395dde2f49e7777b67b51a5fbc6606943
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers

This also happened on more recent commits, including net-next
833e0e2f24fd0525090878f71e129a8a4cb8bf78 (Oct 10) with similar
signature:

------------[ cut here ]------------
kernel BUG at net/key/af_key.c:2068!
invalid opcode: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 11011 Comm: syz-executor1 Not tainted 4.14.0-rc4+ #80
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
task: ffff8801d4ecc1c0 task.stack: ffff8801c13f8000
RIP: 0010:pfkey_xfrm_policy2msg+0x209c/0x22b0 net/key/af_key.c:2068
RSP: 0018:ffff8801c13ff4b0 EFLAGS: 00010212
RAX: 0000000000010000 RBX: ffff8801ceaa828c RCX: ffffc90001f3c000
RDX: 0000000000000599 RSI: ffffffff8444c4fc RDI: ffff8801ceaa812c
RBP: ffff8801c13ff588 R08: 0000000000000001 R09: ffff8801d55dbb40
R10: 000000000000001b R11: ffffed003aabb782 R12: ffff8801ceaa8148
R13: ffff8801ceaa8040 R14: 0000000000000008 R15: 0000000000000001
FS:  00007fc611208700(0000) GS:ffff8801db300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020000ff0 CR3: 00000001a13b6000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 dump_sp+0x14f/0x510 net/key/af_key.c:2669
 xfrm_policy_walk+0x2f1/0xa30 net/xfrm/xfrm_policy.c:1015
 pfkey_dump_sp+0x42/0x50 net/key/af_key.c:2692
 pfkey_do_dump+0xaa/0x3f0 net/key/af_key.c:299
 pfkey_spddump+0x1a0/0x210 net/key/af_key.c:2719
 pfkey_process+0x60b/0x720 net/key/af_key.c:2809
 pfkey_sendmsg+0x4d6/0x9f0 net/key/af_key.c:3648
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 sock_write_iter+0x320/0x5e0 net/socket.c:912
 call_write_iter include/linux/fs.h:1770 [inline]
 new_sync_write fs/read_write.c:468 [inline]
 __vfs_write+0x68a/0x970 fs/read_write.c:481
 vfs_write+0x18f/0x510 fs/read_write.c:543
 SYSC_write fs/read_write.c:588 [inline]
 SyS_write+0xef/0x220 fs/read_write.c:580
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x4520a9
RSP: 002b:00007fc611207c08 EFLAGS: 00000216 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000718000 RCX: 00000000004520a9
RDX: 0000000000000010 RSI: 0000000020000ff0 RDI: 0000000000000019
RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000216 R12: 00000000004bf3b0
R13: 00000000ffffffff R14: 0000000000000005 R15: 0000000000000029
Code: ff ff 48 89 95 58 ff ff ff 89 8d 70 ff ff ff e8 fb 70 5e fd 48
8b 95 58 ff ff ff 8b 8d 70 ff ff ff e9 04 e3 ff ff e8 74 4c 29 fd <0f>
0b be 02 00 00 00 4c 89 f7 e8 15 72 5e fd e9 6f e3 ff ff 48
RIP: pfkey_xfrm_policy2msg+0x209c/0x22b0 net/key/af_key.c:2068 RSP:
ffff8801c13ff4b0
---[ end trace 3103e09d7f60a307 ]---



> ------------[ cut here ]------------
> kernel BUG at net/key/af_key.c:2068!
> invalid opcode: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 3024 Comm: syzkaller790413 Not tainted 4.14.0-rc2+ #16
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> task: ffff8801cddc8100 task.stack: ffff8801c0a88000
> RIP: 0010:pfkey_xfrm_policy2msg+0x209c/0x22b0 net/key/af_key.c:2068
> RSP: 0018:ffff8801c0a8f318 EFLAGS: 00010297
> RAX: ffff8801cddc8100 RBX: ffff8801cea778cc RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 000000000000204e RDI: ffff8801cea7776c
> RBP: ffff8801c0a8f3f0 R08: 0000000000000001 R09: ffff8801d0b66dc0
> R10: 000000000000001b R11: ffffed003a16cdd2 R12: ffff8801cea77788
> R13: ffff8801cea77680 R14: 0000000000000008 R15: 0000000000000001
> FS:  0000000000000000(0000) GS:ffff8801db200000(0063) knlGS:00000000ecf1fb40
> CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> CR2: 0000000020002ff0 CR3: 00000001d4b3c000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  dump_sp+0x14f/0x510 net/key/af_key.c:2669
>  xfrm_policy_walk+0x2f1/0xa30 net/xfrm/xfrm_policy.c:1015
>  pfkey_dump_sp+0x42/0x50 net/key/af_key.c:2692
>  pfkey_do_dump+0xaa/0x3f0 net/key/af_key.c:299
>  pfkey_spddump+0x1a0/0x210 net/key/af_key.c:2719
>  pfkey_process+0x60b/0x720 net/key/af_key.c:2809
>  pfkey_sendmsg+0x4d6/0x9f0 net/key/af_key.c:3648
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  sock_write_iter+0x320/0x5e0 net/socket.c:912
>  call_write_iter include/linux/fs.h:1770 [inline]
>  new_sync_write fs/read_write.c:468 [inline]
>  __vfs_write+0x68a/0x970 fs/read_write.c:481
>  vfs_write+0x18f/0x510 fs/read_write.c:543
>  SYSC_write fs/read_write.c:588 [inline]
>  SyS_write+0xef/0x220 fs/read_write.c:580
>  do_syscall_32_irqs_on arch/x86/entry/common.c:329 [inline]
>  do_fast_syscall_32+0x3f2/0xf05 arch/x86/entry/common.c:391
>  entry_SYSENTER_compat+0x51/0x60 arch/x86/entry/entry_64_compat.S:124
> RIP: 0023:0xf7f39c79
> RSP: 002b:00000000ecf1f1ec EFLAGS: 00000297 ORIG_RAX: 0000000000000004
> RAX: ffffffffffffffda RBX: 0000000000000008 RCX: 0000000020002ff0
> RDX: 0000000000000010 RSI: 0000000000000000 RDI: 0000000000000000
> RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
> R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
> Code: ff ff 48 89 95 58 ff ff ff 89 8d 70 ff ff ff e8 ab 90 5f fd 48 8b 95
> 58 ff ff ff 8b 8d 70 ff ff ff e9 04 e3 ff ff e8 54 d2 2a fd <0f> 0b be 02 00
> 00 00 4c 89 f7 e8 c5 91 5f fd e9 6f e3 ff ff 48
> RIP: pfkey_xfrm_policy2msg+0x209c/0x22b0 net/key/af_key.c:2068 RSP:
> ffff8801c0a8f318
> ---[ end trace 5d48d18d4a6d272b ]---
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a114a958ce46160055c4c4f66%40google.com.
> For more options, visit https://groups.google.com/d/optout.
