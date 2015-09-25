From: Steven Schlansker <stevenschlansker@gmail.com>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Fri, 25 Sep 2015 14:54:51 -0700
Message-ID: <8E01F660-938C-4A4F-9932-6DFDA83518E0@gmail.com>
References: <C3C03EFC-53E1-45DE-87AF-59C7367BD21E@gmail.com> <20150925043653.GA29111@roeck-us.net> <20150925045853.GA5286@gondor.apana.org.au> <5604DCD2.4090600@roeck-us.net> <38FEC418-9C09-47BC-A9FC-5F1EA28941FC@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34213 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbbIYVyt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 17:54:49 -0400
In-Reply-To: <38FEC418-9C09-47BC-A9FC-5F1EA28941FC@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 25, 2015, at 2:37 PM, Steven Schlansker <stevenschlansker@gmail.com> wrote:

> 
> On Sep 24, 2015, at 10:34 PM, Guenter Roeck <linux@roeck-us.net> wrote:
> 
>> Herbert,
>> 
>> On 09/24/2015 09:58 PM, Herbert Xu wrote:
>>> On Thu, Sep 24, 2015 at 09:36:53PM -0700, Guenter Roeck wrote:
>>>> 
>>>> http://comments.gmane.org/gmane.linux.network/363085
>>>> 
>>>> might explain your problem.
>>>> 
>>>> I thought this was resolved in 4.1, but it looks like the problem still persists
>>>> there. At least I have reports from my workplace that 4.1.6 and 4.1.7 are still
>>>> affected. I don't know if there have been any relevant changes in 4.2.
>>>> 
>>>> Copying Herbert and Eric for additional input.
>>> 
>>> There was a separate bug discovered by Tejun recently.  You need
>>> to apply the patches
>>> 
>>> https://patchwork.ozlabs.org/patch/519245/
>>> https://patchwork.ozlabs.org/patch/520824/
>>> 
>> I assume this is on top of mainline ?
>> 
>>> There is another follow-up but it shouldn't make any difference
>>> in practice.
>>> 
>> 
>> Any idea what may be needed for 4.1 ?
>> I am currently trying https://patchwork.ozlabs.org/patch/473041/,
>> but I have no idea if that will help with the problem we are seeing there.
> 
> Thank you for the patches to try, I'll build a kernel with them early next week
> and report back.  It sounds like it may not match my problem exactly so we'll
> see.
Huh, when it rains, it pours... now I have a legit panic too!

[ 1675.228701] BUG: unable to handle kernel paging request at fffffffffffffe70
[ 1675.232058] IP: [<ffffffff8175dcea>] netlink_compare+0xa/0x30
[ 1675.232058] PGD 2015067 PUD 2017067 PMD 0 
[ 1675.232058] Oops: 0000 [#1] SMP 
[ 1675.232058] Modules linked in: i2c_piix4(E) btrfs(E) crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) aesni_intel(E) aes_x86_64(E) lrw(E) gf128mul(E) glue_helper(E) ablk_helper(E) cryptd(E) floppy(E)
[ 1675.232058] CPU: 2 PID: 11152 Comm: pf_dump Tainted: G            E   4.0.4 #1
[ 1675.232058] Hardware name: Xen HVM domU, BIOS 4.2.amazon 05/06/2015
[ 1675.232058] task: ffff880150fa6480 ti: ffff880150fb4000 task.ti: ffff880150fb4000
[ 1675.232058] RIP: 0010:[<ffffffff8175dcea>]  [<ffffffff8175dcea>] netlink_compare+0xa/0x30
[ 1675.232058] RSP: 0018:ffff880150fb7d10  EFLAGS: 00010246
[ 1675.232058] RAX: 0000000000000000 RBX: 00000000023e503b RCX: 000000000561f992
[ 1675.232058] RDX: 00000000fffc27e4 RSI: ffff880150fb7db8 RDI: fffffffffffffbb8
[ 1675.232058] RBP: ffff880150fb7d58 R08: ffff8805a82f5ab8 R09: 000000000000000c
[ 1675.232058] R10: 0000000000000000 R11: 0000000000000202 R12: 0000000000000000
[ 1675.232058] R13: ffffffff8175dce0 R14: ffff88008b37e800 R15: ffff88076db40000
[ 1675.232058] FS:  00007feec2440700(0000) GS:ffff88078fc40000(0000) knlGS:0000000000000000
[ 1675.232058] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1675.232058] CR2: fffffffffffffe70 CR3: 000000053bd17000 CR4: 00000000001407e0
[ 1675.232058] Stack:
[ 1675.232058]  ffffffff81434dae ffff88076d864400 ffff880150fb7db8 ffff8801559ee8b8
[ 1675.232058]  ffff88076db40000 ffff8805a82f5c48 ffff88008b37e800 ffff88076d864400
[ 1675.232058]  0000000000000000 ffff880150fb7da8 ffffffff81435476 ffff880150fb7db8
[ 1675.232058] Call Trace:
[ 1675.232058]  [<ffffffff81434dae>] ? rhashtable_lookup_compare+0x5e/0xb0
[ 1675.232058]  [<ffffffff81435476>] rhashtable_lookup_compare_insert+0x66/0xc0
[ 1675.232058]  [<ffffffff8175eb63>] netlink_insert+0x83/0xe0
[ 1675.232058]  [<ffffffff8175f11d>] netlink_autobind.isra.34+0xad/0xd0
[ 1675.232058]  [<ffffffff817614b1>] netlink_bind+0x1b1/0x240
[ 1675.232058]  [<ffffffff8170b8b8>] SYSC_bind+0xb8/0xf0
[ 1675.232058]  [<ffffffff81110784>] ? __audit_syscall_entry+0xb4/0x110
[ 1675.232058]  [<ffffffff81022e2c>] ? do_audit_syscall_entry+0x6c/0x70
[ 1675.232058]  [<ffffffff81024553>] ? syscall_trace_enter_phase1+0x123/0x180
[ 1675.232058]  [<ffffffff810248b6>] ? syscall_trace_leave+0xc6/0x120
[ 1675.232058]  [<ffffffff811f5a35>] ? fd_install+0x25/0x30
[ 1675.232058]  [<ffffffff8170c5de>] SyS_bind+0xe/0x10
[ 1675.232058]  [<ffffffff81960dcd>] system_call_fastpath+0x16/0x1b
[ 1675.232058] Code: 00 8b 77 08 39 77 14 8d 4e 01 41 0f 44 c9 41 39 c8 89 4f 08 74 09 48 8b 08 83 3c 11 04 74 e2 5d c3 0f 1f 44 00 00 31 c0 8b 56 08 <39> 97 b8 02 00 00 55 48 89 e5 74 0a 5d c3 0f 1f 84 00 00 00 00 
[ 1675.232058] RIP  [<ffffffff8175dcea>] netlink_compare+0xa/0x30
[ 1675.232058]  RSP <ffff880150fb7d10>
[ 1675.232058] CR2: fffffffffffffe70
[ 1675.232058] ---[ end trace 963ff50a058120d0 ]---
[ 1675.232058] Kernel panic - not syncing: Fatal exception in interrupt
[ 1675.232058] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
