From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: seeing crash on running ltp proc01
Date: Wed, 16 Nov 2011 12:16:22 -0800
Message-ID: <20111116121622.3369cf62.akpm@linux-foundation.org>
References: <1321431477.4212.7.camel@madhuri-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Mihai Maruseac <mihai.maruseac@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: madhuri appana <madhuria@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321431477.4212.7.camel@madhuri-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(cc's added)

On Wed, 16 Nov 2011 13:47:57 +0530
madhuri appana <madhuria@linux.vnet.ibm.com> wrote:

> Hi All,
> 
> I am seeing crash on running ltp proc01 syscall on kvm guest using
> latest qemu1.0 rc0 and latest linus kernel.
> 
> Here is the crash report:
> 
> [  256.805661] The scan_unevictable_pages sysctl/node-interface has been
> disabled for lack of a legitimate use case.  If you have one, please
> send an email to linux-mm@kvack.org.
> [  256.820968] process `proc01' is using deprecated sysctl (syscall)
> net.ipv6.neigh.default.retrans_time; Use
> net.ipv6.neigh.default.retrans_time_ms instead.
> [  837.127321] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000010
> [  837.127980] IP: [<ffffffff8157690c>] dev_from_new_bucket+0xb/0x79
> [  837.128053] PGD 3a89d067 PUD 3ad09067 PMD 0 
> [  837.128053] Oops: 0000 [#1] SMP 
> [  837.128053] CPU 2 
> [  837.128053] Modules linked in:
> [  837.128053] 
> [  837.128053] Pid: 9933, comm: proc01 Not tainted 3.1.0+ #3 Bochs Bochs
> [  837.128053] RIP: 0010:[<ffffffff8157690c>]  [<ffffffff8157690c>]
> dev_from_new_bucket+0xb/0x79
> [  837.128053] RSP: 0018:ffff880039885e18  EFLAGS: 00010246
> [  837.128053] RAX: ffffffff818df330 RBX: 0000000000000400 RCX:
> 0000000000000000
> [  837.128053] RDX: ffff880039885e70 RSI: 0000000000000000 RDI:
> ffff88003c427600
> [  837.128053] RBP: ffff880039885e18 R08: 0000000000000010 R09:
> ffff88003c427600
> [  837.128053] R10: ffffffff81c1f610 R11: ffffffff81576fa2 R12:
> ffff88003a4e6140
> [  837.128053] R13: ffff88003c427600 R14: 0000000000000001 R15:
> 0000000000000000
> [  837.128053] FS:  00007f0c56deb7c0(0000) GS:ffff88003f100000(0000)
> knlGS:0000000000000000
> [  837.128053] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  837.128053] CR2: 0000000000000010 CR3: 00000000398a4000 CR4:
> 00000000000006e0
> [  837.128053] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [  837.128053] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [  837.128053] Process proc01 (pid: 9933, threadinfo ffff880039884000,
> task ffff88003a91e6d0)
> [  837.128053] Stack:
> [  837.128053]  ffff880039885e28 ffffffff815769db ffff880039885ea8
> ffffffff8111f614
> [  837.128053]  0000000000000000 ffff880039885e70 ffff88003c427638
> 0000000000000246
> [  837.128053]  ffff880039885f58 00000000006243a0 ffffffff8111f463
> 0000000000000001
> [  837.128053] Call Trace:
> [  837.128053]  [<ffffffff815769db>] dev_seq_next+0x61/0x63
> [  837.128053]  [<ffffffff8111f614>] seq_read+0x1b1/0x369
> [  837.128053]  [<ffffffff8111f463>] ? seq_lseek+0xd4/0xd4
> [  837.128053]  [<ffffffff8111f463>] ? seq_lseek+0xd4/0xd4
> [  837.128053]  [<ffffffff81150a5c>] proc_reg_read+0x90/0xaf
> [  837.128053]  [<ffffffff8110519c>] vfs_read+0xa2/0xde
> [  837.128053]  [<ffffffff81099ec1>] ? trace_hardirqs_on_caller
> +0x11e/0x155
> [  837.128053]  [<ffffffff81105291>] sys_read+0x45/0x6c
> [  837.128053]  [<ffffffff81685bbb>] system_call_fastpath+0x16/0x1b
> [  837.128053] Code: 42 08 c9 c3 55 83 ff 27 b8 ea ff ff ff 48 89 e5 77
> 0c 89 ff 31 c0 48 89 34 fd 00 8e 63 82 c9 c3 4c 8b 87 d0 00 00 00 55 48
> 89 e5 
> [  837.128053]  8b 10 c1 ea 18 4c 8b 8f d0 00 00 00 31 c9 41 8b 01 89 c6
> 41 
> [  837.128053] RIP  [<ffffffff8157690c>] dev_from_new_bucket+0xb/0x79
> [  837.128053]  RSP <ffff880039885e18>
> [  837.128053] CR2: 0000000000000010
> [  837.148037] ---[ end trace 9639850acd813c5b ]---
> [root@qemu-img-64 bin]
> 
> Thanks,
> Madhuri
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
