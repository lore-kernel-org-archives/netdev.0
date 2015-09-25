From: Steven Schlansker <stevenschlansker@gmail.com>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Fri, 25 Sep 2015 14:37:03 -0700
Message-ID: <38FEC418-9C09-47BC-A9FC-5F1EA28941FC@gmail.com>
References: <C3C03EFC-53E1-45DE-87AF-59C7367BD21E@gmail.com> <20150925043653.GA29111@roeck-us.net> <20150925045853.GA5286@gondor.apana.org.au> <5604DCD2.4090600@roeck-us.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5604DCD2.4090600@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 24, 2015, at 10:34 PM, Guenter Roeck <linux@roeck-us.net> wrote:

> Herbert,
> 
> On 09/24/2015 09:58 PM, Herbert Xu wrote:
>> On Thu, Sep 24, 2015 at 09:36:53PM -0700, Guenter Roeck wrote:
>>> 
>>> http://comments.gmane.org/gmane.linux.network/363085
>>> 
>>> might explain your problem.
>>> 
>>> I thought this was resolved in 4.1, but it looks like the problem still persists
>>> there. At least I have reports from my workplace that 4.1.6 and 4.1.7 are still
>>> affected. I don't know if there have been any relevant changes in 4.2.
>>> 
>>> Copying Herbert and Eric for additional input.
>> 
>> There was a separate bug discovered by Tejun recently.  You need
>> to apply the patches
>> 
>> https://patchwork.ozlabs.org/patch/519245/
>> https://patchwork.ozlabs.org/patch/520824/
>> 
> I assume this is on top of mainline ?
> 
>> There is another follow-up but it shouldn't make any difference
>> in practice.
>> 
> 
> Any idea what may be needed for 4.1 ?
> I am currently trying https://patchwork.ozlabs.org/patch/473041/,
> but I have no idea if that will help with the problem we are seeing there.

Thank you for the patches to try, I'll build a kernel with them early next week
and report back.  It sounds like it may not match my problem exactly so we'll
see.

In the meantime, I also observed the following oops:

[ 1709.620092] kernel tried to execute NX-protected page - exploit attempt? (uid: 0)
[ 1709.624058] BUG: unable to handle kernel paging request at ffffea001dbef3c0
[ 1709.624058] IP: [<ffffea001dbef3c0>] 0xffffea001dbef3c0
[ 1709.624058] PGD 78f7dc067 PUD 78f7db067 PMD 800000078ec001e3 
[ 1709.624058] Oops: 0011 [#1] SMP 
[ 1709.624058] Modules linked in: i2c_piix4(E) btrfs(E) crct10dif_pclmul(E) crc32_pclmul(E) ghash_clmulni_intel(E) aesni_intel(E) aes_x86_64(E) lrw(E) gf128mul(E) glue_helper(E) ablk_helper(E) cryptd(E) floppy(E)
[ 1709.624058] CPU: 4 PID: 19714 Comm: pf_dump Tainted: G            E   4.0.4 #1
[ 1709.624058] Hardware name: Xen HVM domU, BIOS 4.2.amazon 05/06/2015
[ 1709.624058] task: ffff880605a18000 ti: ffff8805f9358000 task.ti: ffff8805f9358000
[ 1709.624058] RIP: 0010:[<ffffea001dbef3c0>]  [<ffffea001dbef3c0>] 0xffffea001dbef3c0
[ 1709.624058] RSP: 0018:ffff8805f935bbc0  EFLAGS: 00010246
[ 1709.624058] RAX: ffffea001dbef3c0 RBX: 0000000000000007 RCX: 0000000000000000
[ 1709.624058] RDX: 0000000000002100 RSI: ffff8805f992f308 RDI: ffff8806622f6b00
[ 1709.624058] RBP: ffff8805f935bc08 R08: 0000000000001ec0 R09: 0000000000002100
[ 1709.624058] R10: 0000000000000000 R11: ffff880771003200 R12: ffff8806622f6b00
[ 1709.624058] R13: 0000000000000002 R14: ffffffff8239e238 R15: ffff8805f992f308
[ 1709.624058] FS:  00007f0735f29700(0000) GS:ffff88078fc80000(0000) knlGS:0000000000000000
[ 1709.624058] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1709.624058] CR2: ffffea001dbef3c0 CR3: 00000005f7e88000 CR4: 00000000001407e0
[ 1709.624058] Stack:
[ 1709.624058]  ffffffff81735ca2 0000000000000000 ffff8805f992f348 ffff88076b491400
[ 1709.624058]  ffff8805f992f000 ffff8806622f6b00 0000000000000ec0 ffff8805f992f308
[ 1709.624058]  ffff88065ffb0000 ffff8805f935bc38 ffffffff8176028a ffff8805f992f000
[ 1709.624058] Call Trace:
[ 1709.624058]  [<ffffffff81735ca2>] ? rtnl_dump_all+0x122/0x1a0
[ 1709.624058]  [<ffffffff8176028a>] netlink_dump+0x11a/0x2d0
[ 1709.624058]  [<ffffffff81760625>] netlink_recvmsg+0x1e5/0x360
[ 1709.624058]  [<ffffffff811b97c9>] ? kmem_cache_free+0x1b9/0x1d0
[ 1709.624058]  [<ffffffff8170b33f>] sock_recvmsg+0x6f/0xa0
[ 1709.624058]  [<ffffffff8170c1a4>] ___sys_recvmsg+0xe4/0x200
[ 1709.624058]  [<ffffffff811f5305>] ? __fget_light+0x25/0x70
[ 1709.624058]  [<ffffffff8170cbe2>] __sys_recvmsg+0x42/0x80
[ 1709.624058]  [<ffffffff81961010>] ? int_check_syscall_exit_work+0x34/0x3d
[ 1709.624058]  [<ffffffff8170cc32>] SyS_recvmsg+0x12/0x20
[ 1709.624058]  [<ffffffff81960dcd>] system_call_fastpath+0x16/0x1b
[ 1709.624058] Code: 00 00 00 ff ff ff ff 01 00 00 00 00 01 10 00 00 00 ad de 00 02 20 00 00 00 ad de 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 <00> 00 00 00 00 ff ff 02 00 00 00 00 00 00 00 00 00 00 00 00 00 
[ 1709.798299] RIP  [<ffffea001dbef3c0>] 0xffffea001dbef3c0
[ 1709.798299]  RSP <ffff8805f935bbc0>
[ 1709.798299] CR2: ffffea001dbef3c0
[ 1709.798299] ---[ end trace 2e069ceceed3d61a ]---

It's so far only been noticed once.  I don't know if it is the same issue, it certainly doesn't always happen when this problem occurs,
but it looks curious all the same...
