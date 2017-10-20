From: Eric Dumazet <edumazet@google.com>
Subject: Re: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Thu, 19 Oct 2017 22:34:54 -0700
Message-ID: <CANn89iKj45+zqMt7XqPkCG+8PQwhzjHUBZ0vu-REvZWs1HuqOw@mail.gmail.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <CANn89iJgoiY_ky4F_1iE_o6moZXp5e6OcNZZe=B8F-OhWJx8nQ@mail.gmail.com> <FF5A6DF1-0E5F-4C7E-A31B-06ED33366039@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: linux-arm-kernel@lists.infradead.org,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Wei Wei <dotweiba@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FF5A6DF1-0E5F-4C7E-A31B-06ED33366039@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 19, 2017 at 8:13 PM, Wei Wei <dotweiba@gmail.com> wrote:
> Sry. Here it is.
>
> Unable to handle kernel paging request at virtual address ffff80005bfb81e=
d
> Mem abort info:
> Exception class =3D DABT (current EL), IL =3D 32 bits
> SET =3D 0, FnV =3D 0
> EA =3D 0, S1PTW =3D 0
> Data abort info:
> ISV =3D 0, ISS =3D 0x00000033
> CM =3D 0, WnR =3D 0
> swapper pgtable: 4k pages, 48-bit VAs, pgd =3D ffff20000b366000
> [ffff80005bfb81ed] *pgd=3D00000000beff7003, *pud=3D00e8000080000711
> Internal error: Oops: 96000021 [#1] PREEMPT SMP
> Modules linked in:
> CPU: 3 PID: 4725 Comm: syz-executor0 Not tainted 4.14.0-rc3 #3
> Hardware name: linux,dummy-virt (DT)
> task: ffff800074409e00 task.stack: ffff800033db0000
> PC is at __skb_clone (/./arch/arm64/include/asm/atomic_ll_sc.h:113 (discr=
iminator 4) /net/core/skbuff.c:873 (discriminator 4))
> LR is at __skb_clone (/net/core/skbuff.c:861 (discriminator 4))
> pc : lr : pstate: 10000145
>
> sp : ffff800033db33d0
> x29: ffff800033db33d0 x28: ffff2000098ac378
> x27: ffff100006a860e1 x26: 1ffff000067b66b6
> x25: ffff8000743340a0 x24: ffff800035430708
> x23: ffff80005bfb80c9 x22: ffff800035430710
> x21: 0000000000000380 x20: ffff800035430640
> x19: ffff8000354312c0 x18: 0000000000000000
> x17: 00000000004af000 x16: ffff20000845e8c8
> x15: 000000001e518060 x14: 0000ffffd8316070
> x13: 0000ffffd8316090 x12: ffffffffffffffff
> x11: 1ffff00006a8626f x10: ffff100006a8626f
> x9 : dfff200000000000 x8 : 0082009000900608
> x7 : 0000000000000000 x6 : ffff800035431380
> x5 : ffff100006a86270 x4 : 0000000000000000
> x3 : 1ffff00006a86273 x2 : 0000000000000000
> x1 : 0000000000000100 x0 : ffff80005bfb81ed
> Process syz-executor0 (pid: 4725, stack limit =3D 0xffff800033db0000)
> Call trace:
> Exception stack(0xffff800033db3290 to 0xffff800033db33d0)
> 3280:                                   ffff80005bfb81ed 0000000000000100
> 32a0: 0000000000000000 1ffff00006a86273 0000000000000000 ffff100006a86270
> 32c0: ffff800035431380 0000000000000000 0082009000900608 dfff200000000000
> 32e0: ffff100006a8626f 1ffff00006a8626f ffffffffffffffff 0000ffffd8316090
> 3300: 0000ffffd8316070 000000001e518060 ffff20000845e8c8 00000000004af000
> 3320: 0000000000000000 ffff8000354312c0 ffff800035430640 0000000000000380
> 3340: ffff800035430710 ffff80005bfb80c9 ffff800035430708 ffff8000743340a0
> 3360: 1ffff000067b66b6 ffff100006a860e1 ffff2000098ac378 ffff800033db33d0
> 3380: ffff200009705cfc ffff800033db33d0 ffff200009705f50 0000000010000145
> 33a0: ffff8000354312c0 ffff800035430640 0001000000000000 ffff800074334000
> 33c0: ffff800033db33d0 ffff200009705f50
> __skb_clone (/./arch/arm64/include/asm/atomic_ll_sc.h:113 (discriminator =
4) /net/core/skbuff.c:873 (discriminator 4))
> skb_clone (/net/core/skbuff.c:1286)
> arp_rcv (/./include/linux/skbuff.h:1518 /net/ipv4/arp.c:946)
> __netif_receive_skb_core (/net/core/dev.c:1859 /net/core/dev.c:1874 /net/=
core/dev.c:4416)
> __netif_receive_skb (/net/core/dev.c:4466)
> netif_receive_skb_internal (/net/core/dev.c:4539)
> netif_receive_skb (/net/core/dev.c:4564)
> tun_get_user (/./include/linux/bottom_half.h:31 /drivers/net/tun.c:1219 /=
drivers/net/tun.c:1553)
> tun_chr_write_iter (/drivers/net/tun.c:1579)
> do_iter_readv_writev (/./include/linux/fs.h:1770 /fs/read_write.c:673)
> do_iter_write (/fs/read_write.c:952)
> vfs_writev (/fs/read_write.c:997)
> do_writev (/fs/read_write.c:1032)
> SyS_writev (/fs/read_write.c:1102)
> Exception stack(0xffff800033db3ec0 to 0xffff800033db4000)
> 3ec0: 0000000000000015 0000ffff829985e0 0000000000000001 0000ffff8299851c
> 3ee0: 0000ffff82999068 0000ffff82998f60 0000ffff82999650 0000000000000000
> 3f00: 0000000000000042 0000000000000036 0000000000406608 0000ffff82998400
> 3f20: 0000ffff82998f60 0000ffffd8316090 0000ffffd8316070 000000001e518060
> 3f40: 0000000000000000 00000000004af000 0000000000000000 0000000000000036
> 3f60: 0000000020004fca 0000000020000000 000000000046ccf0 0000000000000530
> 3f80: 000000000046cce8 00000000004ade98 0000000000000000 00000000395fa6f0
> 3fa0: 0000ffff82998f60 0000ffff82998560 0000000000431448 0000ffff82998520
> 3fc0: 000000000043145c 0000000080000000 0000000000000015 0000000000000042
> 3fe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> el0_svc_naked (/arch/arm64/kernel/entry.S:853)
> Code: f9406680 8b010000 91009000 f9800011 (885f7c01)
> All code
> =3D=3D=3D=3D=3D=3D=3D=3D
>    0:   80 66 40 f9             andb   $0xf9,0x40(%rsi)
>    4:   00 00                   add    %al,(%rax)
>    6:   01 8b 00 90 00 91       add    %ecx,-0x6eff7000(%rbx)
>    c:   11 00                   adc    %eax,(%rax)
>    e:   80 f9 01                cmp    $0x1,%cl
>   11:   7c 5f                   jl     0x72
>   13:*  88 00                   mov    %al,(%rax)               <-- trapp=
ing instruction
>   15:   00 00                   add    %al,(%rax)
>         ...
>
> Code starting with the faulting instruction
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>    0:   01 7c 5f 88             add    %edi,-0x78(%rdi,%rbx,2)
>    4:   00 00                   add    %al,(%rax)
>         ...
> =E2=80=94[ end trace 261e7ac1458ccc0a ]---
>

I thought it was happening on arm64 ?

This is x86_64 disassembly :/

Thanks.

> Thanks,
> Wei
>
>> On 19 Oct 2017, at 10:53 PM, Eric Dumazet <edumazet@google.com> wrote:
>>
>> On Thu, Oct 19, 2017 at 7:16 PM, Wei Wei <dotweiba@gmail.com> wrote:
>>> Hi all,
>>>
>>> I have fuzzed v4.14-rc3 using syzkaller and found a bug similar to that=
 one [1].
>>> But the call trace isn=E2=80=99t the same. The atomic_inc() might handl=
e a corrupted
>>> skb_buff.
>>>
>>> The logs and config have been uploaded to my github repo [2].
>>>
>>> [1] https://lkml.org/lkml/2017/10/2/216
>>> [2] https://github.com/dotweiba/skb_clone_atomic_inc_bug
>>>
>>> Thanks,
>>> Wei
>>>
>>> Unable to handle kernel paging request at virtual address ffff80005bfb8=
1ed
>>> Mem abort info:
>>>   Exception class =3D DABT (current EL), IL =3D 32 bits
>>>   SET =3D 0, FnV =3D 0
>>>   EA =3D 0, S1PTW =3D 0
>>> Data abort info:
>>>   ISV =3D 0, ISS =3D 0x00000033
>>>   CM =3D 0, WnR =3D 0
>>> swapper pgtable: 4k pages, 48-bit VAs, pgd =3D ffff20000b366000
>>> [ffff80005bfb81ed] *pgd=3D00000000beff7003, *pud=3D00e8000080000711
>>> Internal error: Oops: 96000021 [#1] PREEMPT SMP
>>> Modules linked in:
>>> CPU: 3 PID: 4725 Comm: syz-executor0 Not tainted 4.14.0-rc3 #3
>>> Hardware name: linux,dummy-virt (DT)
>>> task: ffff800074409e00 task.stack: ffff800033db0000
>>> PC is at __skb_clone+0x430/0x5b0
>>> LR is at __skb_clone+0x1dc/0x5b0
>>> pc : [<ffff200009705f50>] lr : [<ffff200009705cfc>] pstate: 10000145
>>> sp : ffff800033db33d0
>>> x29: ffff800033db33d0 x28: ffff2000098ac378
>>> x27: ffff100006a860e1 x26: 1ffff000067b66b6
>>> x25: ffff8000743340a0 x24: ffff800035430708
>>> x23: ffff80005bfb80c9 x22: ffff800035430710
>>> x21: 0000000000000380 x20: ffff800035430640
>>> x19: ffff8000354312c0 x18: 0000000000000000
>>> x17: 00000000004af000 x16: ffff20000845e8c8
>>> x15: 000000001e518060 x14: 0000ffffd8316070
>>> x13: 0000ffffd8316090 x12: ffffffffffffffff
>>> x11: 1ffff00006a8626f x10: ffff100006a8626f
>>> x9 : dfff200000000000 x8 : 0082009000900608
>>> x7 : 0000000000000000 x6 : ffff800035431380
>>> x5 : ffff100006a86270 x4 : 0000000000000000
>>> x3 : 1ffff00006a86273 x2 : 0000000000000000
>>> x1 : 0000000000000100 x0 : ffff80005bfb81ed
>>> Process syz-executor0 (pid: 4725, stack limit =3D 0xffff800033db0000)
>>> Call trace:
>>> Exception stack(0xffff800033db3290 to 0xffff800033db33d0)
>>> 3280:                                   ffff80005bfb81ed 00000000000001=
00
>>> 32a0: 0000000000000000 1ffff00006a86273 0000000000000000 ffff100006a862=
70
>>> 32c0: ffff800035431380 0000000000000000 0082009000900608 dfff2000000000=
00
>>> 32e0: ffff100006a8626f 1ffff00006a8626f ffffffffffffffff 0000ffffd83160=
90
>>> 3300: 0000ffffd8316070 000000001e518060 ffff20000845e8c8 00000000004af0=
00
>>> 3320: 0000000000000000 ffff8000354312c0 ffff800035430640 00000000000003=
80
>>> 3340: ffff800035430710 ffff80005bfb80c9 ffff800035430708 ffff8000743340=
a0
>>> 3360: 1ffff000067b66b6 ffff100006a860e1 ffff2000098ac378 ffff800033db33=
d0
>>> 3380: ffff200009705cfc ffff800033db33d0 ffff200009705f50 00000000100001=
45
>>> 33a0: ffff8000354312c0 ffff800035430640 0001000000000000 ffff8000743340=
00
>>> 33c0: ffff800033db33d0 ffff200009705f50
>>> [<ffff200009705f50>] __skb_clone+0x430/0x5b0
>>> [<ffff20000971520c>] skb_clone+0x164/0x2c8
>>> [<ffff2000098ac498>] arp_rcv+0x120/0x488
>>> [<ffff200009741878>] __netif_receive_skb_core+0x11e8/0x18c8
>>> [<ffff2000097479b0>] __netif_receive_skb+0x30/0x198
>>> [<ffff200009751fd8>] netif_receive_skb_internal+0x98/0x370
>>> [<ffff2000097522cc>] netif_receive_skb+0x1c/0x28
>>> [<ffff2000090730e0>] tun_get_user+0x12f0/0x2e40
>>> [<ffff200009074ddc>] tun_chr_write_iter+0xbc/0x140
>>> [<ffff200008457284>] do_iter_readv_writev+0x2d4/0x468
>>> [<ffff20000845a5a0>] do_iter_write+0x148/0x498
>>> [<ffff20000845aac0>] vfs_writev+0x118/0x250
>>> [<ffff20000845acbc>] do_writev+0xc4/0x1e8
>>> [<ffff20000845e8fc>] SyS_writev+0x34/0x48
>>> Exception stack(0xffff800033db3ec0 to 0xffff800033db4000)
>>> 3ec0: 0000000000000015 0000ffff829985e0 0000000000000001 0000ffff829985=
1c
>>> 3ee0: 0000ffff82999068 0000ffff82998f60 0000ffff82999650 00000000000000=
00
>>> 3f00: 0000000000000042 0000000000000036 0000000000406608 0000ffff829984=
00
>>> 3f20: 0000ffff82998f60 0000ffffd8316090 0000ffffd8316070 000000001e5180=
60
>>> 3f40: 0000000000000000 00000000004af000 0000000000000000 00000000000000=
36
>>> 3f60: 0000000020004fca 0000000020000000 000000000046ccf0 00000000000005=
30
>>> 3f80: 000000000046cce8 00000000004ade98 0000000000000000 00000000395fa6=
f0
>>> 3fa0: 0000ffff82998f60 0000ffff82998560 0000000000431448 0000ffff829985=
20
>>> 3fc0: 000000000043145c 0000000080000000 0000000000000015 00000000000000=
42
>>> 3fe0: 0000000000000000 0000000000000000 0000000000000000 00000000000000=
00
>>> [<ffff200008083ef0>] el0_svc_naked+0x24/0x28
>>> Code: f9406680 8b010000 91009000 f9800011 (885f7c01)
>>> ---[ end trace 261e7ac1458ccc0a ]---
>>
>> Please provide proper file:line information in this trace.
>>
>> You can use scripts/decode_stacktrace.sh
>>
>> Thanks.
>
