From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: WARNING in skb_warn_bad_offload
Date: Wed, 1 Nov 2017 21:50:18 +0300
Message-ID: <CACT4Y+ZDRNWj1iRqLvFLjOXJYc2XERWPh+Qa0hNxUgMD1uaeBA@mail.gmail.com>
References: <001a11425c8667f897055cf052ff@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, syzkaller-bugs@googlegroups.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: syzbot
        <bot+abb66e15eb1b298dfe4a13375f18a278d5940e6f@syzkaller.appspotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <001a11425c8667f897055cf052ff@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 1, 2017 at 9:48 PM, syzbot
<bot+abb66e15eb1b298dfe4a13375f18a278d5940e6f@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 720bbe532b7c8f5613b48dea627fc58ed9ace707
> git://git.cmpxchg.org/linux-mmots.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers


This also happens on more recent commits, including linux-next
36ef71cae353f88fd6e095e2aaa3e5953af1685d (Oct 20):

syz0: caps=(0x00000400000058c1, 0x0000000000000000) len=4203
data_len=2810 gso_size=8465 gso_type=3 ip_summed=0
------------[ cut here ]------------
WARNING: CPU: 0 PID: 3473 at net/core/dev.c:2618
skb_warn_bad_offload.cold.139+0x224/0x261 net/core/dev.c:2613
Kernel panic - not syncing: panic_on_warn set ...

CPU: 0 PID: 3473 Comm: a.out Not tainted 4.14.0-rc5-next-20171018 #15
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x1a8/0x272 lib/dump_stack.c:52
 panic+0x21e/0x4b7 kernel/panic.c:183
 __warn.cold.6+0x182/0x187 kernel/panic.c:546
 report_bug+0x232/0x330 lib/bug.c:183
 fixup_bug+0x3f/0x90 arch/x86/kernel/traps.c:177
 do_trap_no_signal arch/x86/kernel/traps.c:211 [inline]
 do_trap+0x132/0x280 arch/x86/kernel/traps.c:260
 do_error_trap+0x11f/0x390 arch/x86/kernel/traps.c:297
 do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:310
 invalid_op+0x18/0x20 arch/x86/entry/entry_64.S:905
RIP: 0010:skb_warn_bad_offload.cold.139+0x224/0x261 net/core/dev.c:2613
RSP: 0018:ffff880064797038 EFLAGS: 00010286
RAX: 000000000000006f RBX: ffff88006365efe8 RCX: 0000000000000000
RDX: 000000000000006f RSI: ffffffff815c88c1 RDI: ffffed000c8f2dfd
RBP: ffff880064797090 R08: ffff8800686f86c0 R09: 0000000000000002
R10: ffff8800686f86c0 R11: 0000000000000000 R12: ffff8800538b1680
R13: 0000000000000000 R14: ffff8800538b1680 R15: 0000000000002111
 __skb_gso_segment+0x69e/0x860 net/core/dev.c:2824
 skb_gso_segment include/linux/netdevice.h:3971 [inline]
 validate_xmit_skb+0x29f/0xca0 net/core/dev.c:3074
 validate_xmit_skb_list+0xb7/0x120 net/core/dev.c:3125
 sch_direct_xmit+0x5b5/0x710 net/sched/sch_generic.c:181
 __dev_xmit_skb net/core/dev.c:3206 [inline]
 __dev_queue_xmit+0x1e41/0x2350 net/core/dev.c:3473
 dev_queue_xmit+0x17/0x20 net/core/dev.c:3538
 packet_snd net/packet/af_packet.c:2956 [inline]
 packet_sendmsg+0x487a/0x64b0 net/packet/af_packet.c:2981
 sock_sendmsg_nosec net/socket.c:632 [inline]
 sock_sendmsg+0xd2/0x120 net/socket.c:642
 ___sys_sendmsg+0x7cc/0x900 net/socket.c:2048
 __sys_sendmsg+0xe6/0x220 net/socket.c:2082
 SYSC_sendmsg net/socket.c:2093 [inline]
 SyS_sendmsg+0x36/0x60 net/socket.c:2089
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x44bab9
RSP: 002b:00000000007eff18 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 0000000020001046 RCX: 000000000044bab9
RDX: 0000000000004010 RSI: 00000000207fcfc8 RDI: 0000000000000004
RBP: 0000000000000086 R08: 850b2da14d2a3706 R09: 0000000000000000
R10: 1b91126b7f398aaa R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000407950 R14: 00000000004079e0 R15: 0000000000000000





> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 2986 at net/core/dev.c:2585
> skb_warn_bad_offload+0x2a9/0x380 net/core/dev.c:2580
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 0 PID: 2986 Comm: syzkaller546001 Not tainted 4.13.0-mm1+ #7
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  panic+0x1e4/0x417 kernel/panic.c:181
>  __warn+0x1c4/0x1d9 kernel/panic.c:542
>  report_bug+0x211/0x2d0 lib/bug.c:183
>  fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:178
>  do_trap_no_signal arch/x86/kernel/traps.c:212 [inline]
>  do_trap+0x260/0x390 arch/x86/kernel/traps.c:261
>  do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:298
>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:311
>  invalid_op+0x18/0x20 arch/x86/entry/entry_64.S:905
> RIP: 0010:skb_warn_bad_offload+0x2a9/0x380 net/core/dev.c:2580
> RSP: 0018:ffff8801ce73f0a0 EFLAGS: 00010282
> RAX: 000000000000006f RBX: ffff8801cd84cde0 RCX: 0000000000000000
> RDX: 000000000000006f RSI: 1ffff10039ce7dd4 RDI: ffffed0039ce7e08
> RBP: ffff8801ce73f0f8 R08: ffff8801ce73e790 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801ce7802c0
> R13: 0000000000000000 R14: ffff8801ce7802c0 R15: 0000000000002111
>  __skb_gso_segment+0x607/0x7f0 net/core/dev.c:2791
>  skb_gso_segment include/linux/netdevice.h:3951 [inline]
>  validate_xmit_skb+0x4ba/0xb20 net/core/dev.c:3041
>  validate_xmit_skb_list+0xb7/0x120 net/core/dev.c:3092
>  sch_direct_xmit+0x3b6/0x6d0 net/sched/sch_generic.c:181
>  __dev_xmit_skb net/core/dev.c:3173 [inline]
>  __dev_queue_xmit+0x15fe/0x1e40 net/core/dev.c:3440
>  dev_queue_xmit+0x17/0x20 net/core/dev.c:3505
>  packet_snd net/packet/af_packet.c:2950 [inline]
>  packet_sendmsg+0x3bbf/0x6030 net/packet/af_packet.c:2975
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  ___sys_sendmsg+0x75b/0x8a0 net/socket.c:2049
>  __sys_sendmsg+0xe5/0x210 net/socket.c:2083
>  SYSC_sendmsg net/socket.c:2094 [inline]
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2090
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
> RIP: 0033:0x445489
> RSP: 002b:00000000007efe68 EFLAGS: 00000217 ORIG_RAX: 000000000000002e
> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000445489
> RDX: 0000000000004010 RSI: 00000000207fcfc8 RDI: 0000000000000004
> RBP: 0000000000000082 R08: 000000000000cdf3 R09: 000000000000cdf3
> R10: 0000000000000004 R11: 0000000000000217 R12: 0000000000402ae0
> R13: 0000000000402b70 R14: 0000000000000000 R15: 0000000000000000
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
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
> Note: all commands must start from beginning of the line.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a11425c8667f897055cf052ff%40google.com.
> For more options, visit https://groups.google.com/d/optout.
