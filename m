From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net: GPF in rt6_get_cookie
Date: Wed, 30 Nov 2016 12:00:07 +0100
Message-ID: <29124960-9002-cfd0-c6b9-8986d7e8c875@stressinduktion.org>
References: <CACT4Y+Y-B_GCDGpcLHt1CtXs3u9MBFD82MSFWTcL_v4Vi3+=HQ@mail.gmail.com>
 <CAAeHK+wvAZByn7-fONWYk1P8fXA9wNdkVLGtXfQsdFb-NSdn+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wvAZByn7-fONWYk1P8fXA9wNdkVLGtXfQsdFb-NSdn+g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On 30.11.2016 11:39, Andrey Konovalov wrote:
> On Sat, Nov 26, 2016 at 5:23 PM, 'Dmitry Vyukov' via syzkaller
> <syzkaller@googlegroups.com> wrote:
>> Hello,
>>
>> I got several GPFs in rt6_get_cookie while running syzkaller:
>>
>> general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Modules linked in:
>> CPU: 2 PID: 10156 Comm: syz-executor Not tainted 4.9.0-rc5+ #54
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> task: ffff880016f40480 task.stack: ffff88000fc00000
>> RIP: 0010:[<ffffffff87a209e8>]  [<     inline     >] rt6_get_cookie
>> include/net/ip6_fib.h:174
>> RIP: 0010:[<ffffffff87a209e8>]  [<ffffffff87a209e8>]
>> sctp_v6_get_dst+0x7c8/0x1960 net/sctp/ipv6.c:340
>> RSP: 0018:ffff88000fc07298  EFLAGS: 00010202
>> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: ffffc900029f5000
>> RDX: 0000000000000015 RSI: 0000000000000001 RDI: 00000000000000a8
>> RBP: ffff88000fc07580 R08: 0000000000000000 R09: 0000000000000001
>> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880066cd0068
>> R13: 1ffff10001f80e92 R14: ffff880066cd0040 R15: ffff88005f2d2808
>> FS:  00007f52c41f7700(0000) GS:ffff88006d000000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000000020016000 CR3: 0000000065dd7000 CR4: 00000000000006e0
>> DR0: 0000000000000400 DR1: 0000000000000400 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>> Stack:
>>  ffffffff87a210f6 ffffffff8701ad45 ffff88006768ec20 ffff88006768ec20
>>  0000000000000000 0000000016f40480 ffff88000fc07450 1ffff1000cd9a017
>>  ffff88006768ec00 ffff880066fc0730 ffff880066cd0068 1ffff10001f80e66
>> Call Trace:
>>  [<ffffffff879a313d>] sctp_transport_route+0xad/0x430 net/sctp/transport.c:279
>>  [<ffffffff8799b106>] sctp_assoc_add_peer+0x5a6/0x13e0 net/sctp/associola.c:641
>>  [<ffffffff879e8911>] sctp_sendmsg+0x1921/0x3bc0 net/sctp/socket.c:1864
>>  [<ffffffff8701ad45>] inet_sendmsg+0x385/0x590 net/ipv4/af_inet.c:734
>>  [<     inline     >] sock_sendmsg_nosec net/socket.c:621
>>  [<ffffffff86a6d54f>] sock_sendmsg+0xcf/0x110 net/socket.c:631
>>  [<ffffffff86a6ede0>] SYSC_sendto+0x660/0x810 net/socket.c:1656
>>  [<ffffffff86a71dd5>] SyS_sendto+0x45/0x60 net/socket.c:1624
>>  [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6
>> Code: 00 00 48 8b 84 24 88 00 00 00 48 8b 58 40 e8 80 76 cc f9 48 8d
>> bb a8 00 00 00 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <80>
>> 3c 02 00 0f 85 56 0f 00 00 48 8b 9b a8 00 00 00 45 31 ed 48
>> RIP  [<     inline     >] rt6_get_cookie include/net/ip6_fib.h:174
>> RIP  [<ffffffff87a209e8>] sctp_v6_get_dst+0x7c8/0x1960 net/sctp/ipv6.c:340
>>  RSP <ffff88000fc07298>
>> ---[ end trace b8d1354fa571700d ]---
>>
>>
>> general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Modules linked in:
>> CPU: 3 PID: 22744 Comm: syz-executor Not tainted 4.9.0-rc5+ #54
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> task: ffff88006b92a840 task.stack: ffff88006a730000
>> RIP: 0010:[<ffffffff87a209e8>]  [<     inline     >] rt6_get_cookie
>> include/net/ip6_fib.h:174
>> RIP: 0010:[<ffffffff87a209e8>]  [<ffffffff87a209e8>]
>> sctp_v6_get_dst+0x7c8/0x1960 net/sctp/ipv6.c:340
>> RSP: 0018:ffff88006a736b88  EFLAGS: 00010202
>> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: ffffc90003c4f000
>> RDX: 0000000000000015 RSI: 0000000000000001 RDI: 00000000000000a8
>> RBP: ffff88006a736e68 R08: 0000000000000000 R09: 0000000000000001
>> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880064cff268
>> R13: 1ffff1000d4e6db0 R14: ffff880064cff240 R15: ffff88006a4b6808
>> FS:  00007f74f4ec9700(0000) GS:ffff88006d100000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 000000002070effc CR3: 000000003bd2f000 CR4: 00000000000006e0
>> DR0: 0000000000000400 DR1: 0000000000000400 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
>> Stack:
>>  ffffffff87a210f6 ffffffff000bbd2d ffff88006c2cd5a0 ffff88006c2cd5a0
>>  0000000000000000 000000006ccb46c0 ffff88006a736d40 1ffff1000c99fe57
>>  ffff88006c2cd500 ffff8800658b1f30 ffff880064cff268 1ffff1000d4e6d84
>> Call Trace:
>>  [<ffffffff879a313d>] sctp_transport_route+0xad/0x430 net/sctp/transport.c:279
>>  [<ffffffff8799b106>] sctp_assoc_add_peer+0x5a6/0x13e0 net/sctp/associola.c:641
>>  [<ffffffff879e4358>] __sctp_connect+0x288/0xc90 net/sctp/socket.c:1178
>>  [<ffffffff879e4f0b>] __sctp_setsockopt_connectx+0x1ab/0x200
>> net/sctp/socket.c:1332
>>  [<     inline     >] sctp_getsockopt_connectx3 net/sctp/socket.c:1417
>>  [<ffffffff879fd2bd>] sctp_getsockopt+0x36ed/0x6800 net/sctp/socket.c:6474
>>  [<ffffffff86a76c0a>] sock_common_getsockopt+0x9a/0xe0 net/core/sock.c:2649
>>  [<     inline     >] SYSC_getsockopt net/socket.c:1788
>>  [<ffffffff86a724d7>] SyS_getsockopt+0x257/0x390 net/socket.c:1770
>>  [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6
>> Code: 00 00 48 8b 84 24 88 00 00 00 48 8b 58 40 e8 80 76 cc f9 48 8d
>> bb a8 00 00 00 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <80>
>> 3c 02 00 0f 85 56 0f 00 00 48 8b 9b a8 00 00 00 45 31 ed 48
>> RIP  [<     inline     >] rt6_get_cookie include/net/ip6_fib.h:174
>> RIP  [<ffffffff87a209e8>] sctp_v6_get_dst+0x7c8/0x1960 net/sctp/ipv6.c:340
>>  RSP <ffff88006a736b88>
>> ---[ end trace f42d1c14cb6d2835 ]---
>>
>> This happened on commit a25f0944ba9b1d8a6813fd6f1a86f1bd59ac25a6 (Nov 13).
>>
>> Unfortunately this is not reproducible.
>>
>> The line is:
>>
>>     return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
>>
>> Can it be a data race? rt->rt6i_node != NULL, but the next moment it
>> is already NULL? That would explain the crash and non-reproducibility
>> (need ThreadSanitizer!).
>>
>> This always happened when called from sctp code, but I don't know if
>> it is relevant or not. It happened only 3 times.
> 
> I'm seeing similar crashes from ipv6 and dccp code, reports below.
> 
> [...]

Thanks for the report.

Do you have a thread running that concurrently mutates the routing table?

Bye,
Hannes
