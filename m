From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: xt_nat_init: BUG: unable to handle kernel NULL pointer
 dereference at 00000000000000e0
Date: Thu, 13 Sep 2012 11:33:43 +0200
Message-ID: <1347528823.13103.1427.camel@edumazet-glaptop>
References: <20120913091629.GA28022@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	networking <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Netfilter Development Maili..." <netfilter-devel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120913091629.GA28022@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-13 at 17:16 +0800, Fengguang Wu wrote:
> Hi Patrick,
> 
> This happens in today's linux-next tree and is pretty reproducible.
> Bisection has been started.
> 
> [    1.834544] nf_conntrack version 0.5.0 (1786 buckets, 7144 max)
> [    1.835406] ctnetlink v0.93: registering with nfnetlink.
> [    1.836202] BUG: unable to handle kernel NULL pointer dereference at 00000000000000e0
> [    1.837539] IP: [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70
> [    1.838493] PGD 0 
> [    1.838983] Oops: 0002 [#1] PREEMPT SMP 
> [    1.839786] CPU 0 
> [    1.840050] Pid: 1, comm: swapper/0 Not tainted 3.6.0-rc5-07686-gdbf978b #58 Bochs Bochs
> [    1.840172] RIP: 0010:[<ffffffff81a19123>]  [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70
> [    1.840172] RSP: 0018:ffff88000d845e40  EFLAGS: 00010202
> [    1.840172] RAX: 0000000000000246 RBX: 00000000000000e0 RCX: ffff88000d848000
> [    1.840172] RDX: 0000000000000000 RSI: 0000000000000175 RDI: ffffffff81e6bc88
> [    1.840172] RBP: ffff88000d845e50 R08: ffffffff821bd170 R09: 0000000000000000
> [    1.840172] R10: 0000000000000000 R11: dead000000200200 R12: 00000000ffffffff
> [    1.840172] R13: 0000000000000004 R14: ffffffff821c1ce0 R15: 0000000000000000
> [    1.840172] FS:  0000000000000000(0000) GS:ffff88000de00000(0000) knlGS:0000000000000000
> [    1.840172] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [    1.840172] CR2: 00000000000000e0 CR3: 000000000200b000 CR4: 00000000000006f0
> [    1.840172] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [    1.840172] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [    1.840172] Process swapper/0 (pid: 1, threadinfo ffff88000d844000, task ffff88000d848000)
> [    1.840172] Stack:
> [    1.840172]  00000000000000e0 ffffffff821c1ce0 ffff88000d845e80 ffffffff8187c204
> [    1.840172]  0000000000000000 ffffffff820f7ea0 0000000000000000 ffffffff821c1ce0
> [    1.840172]  ffff88000d845ec0 ffffffff8187c334 ffff88000d845eb0 0000000000000000
> [    1.840172] Call Trace:
> [    1.840172]  [<ffffffff8187c204>] xt_register_target+0x34/0x70
> [    1.840172]  [<ffffffff8187c334>] xt_register_targets+0x34/0x70
> [    1.840172]  [<ffffffff8221f336>] ? nf_nat_init+0x12c/0x12c
> [    1.840172]  [<ffffffff8221f34b>] xt_nat_init+0x15/0x17
> [    1.840172]  [<ffffffff821dcc3e>] do_one_initcall+0x7a/0x134
> [    1.840172]  [<ffffffff821dcdfb>] kernel_init+0x103/0x187
> [    1.864014]  [<ffffffff821dc615>] ? do_early_param+0x8d/0x8d
> [    1.864014]  [<ffffffff81a1dc44>] kernel_thread_helper+0x4/0x10
> [    1.864014]  [<ffffffff821dccf8>] ? do_one_initcall+0x134/0x134
> [    1.864014]  [<ffffffff81a1dc40>] ? gs_change+0x13/0x13
> [    1.864014] Code: 8b 65 f8 c9 c3 0f 1f 00 55 31 d2 be 75 01 00 00 48 89 e5 41 54 41 bc ff ff ff ff 53 48 89 fb 48 c7 c7 88 bc e6 81 e8 dd 73 6e ff <f0> 44 0f c1 23 41 83 ec 01 31 d2 48 c7 c7 c8 b7 13 82 41 c1 ec 
> [    1.864014] RIP  [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70
> [    1.864014]  RSP <ffff88000d845e40>
> [    1.864014] CR2: 00000000000000e0
> 
> Thanks,
> Fengguang

Wasnt it already solved ?

http://1984.lsi.us.es/git/nf-next/commit/?id=00545bec9412d130c77f72a08d6c8b6ad21d4a1

Just have to wait that netfilter fixes are pushed upstream

Thanks



