From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] rhashtable:
 rhashtable_remove() must unlink in both tbl and future_tbl
Date: Fri, 30 Jan 2015 16:37:59 +0800
Message-ID: <54CB42E7.9070401@windriver.com>
References: <54BCBA35.2080103@windriver.com>
	<20150119125928.GB7672@casper.infradead.org>
	<54BDC30D.5000606@windriver.com>
	<20150120165826.GK20315@casper.infradead.org>
	<54BF65C2.9010404@windriver.com>
	<20150121115607.GB12570@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, davem@davemloft.net,
	Netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20150121115607.GB12570@casper.infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01/21/2015 07:56 PM, Thomas Graf wrote:
> On 01/21/15 at 04:39pm, Ying Xue wrote:
>> Your below changes are reasonable for me. But after I applied the patch,
>> my reported two issues still happened :( And failure logs are completely
>> same before.
> 
> Correct. The patch fixes the panic that you reported as well:
> 

Sorry, it sounds like the similar issue still exists even if I applied
the patch. Please see the following panic log:

[  139.214445] BUG: unable to handle kernel paging request at
ffffffffffffff74
[  139.215116] IP: [<ffffffff81390b3b>] memcmp+0xb/0x50
[  139.215612] PGD 1c12067 PUD 1c14067 PMD 0
[  139.216013] Oops: 0000 [#1] SMP
[  139.216013] Modules linked in: tipc
[  139.216013] CPU: 1 PID: 739 Comm: bind2 Not tainted 3.19.0-rc6+ #181
[  139.216013] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  139.216013] task: ffff8800131e4220 ti: ffff880015fe0000 task.ti:
ffff880015fe0000
[  139.216013] RIP: 0010:[<ffffffff81390b3b>]  [<ffffffff81390b3b>]
memcmp+0xb/0x50
[  139.216013] RSP: 0018:ffff880015fe3cd8  EFLAGS: 00010202
[  139.216013] RAX: 0000000000000000 RBX: ffff880015209090 RCX:
0000000000000031
[  139.216013] RDX: 0000000000000004 RSI: ffff88001333ae7c RDI:
ffffffffffffff74
[  139.216013] RBP: ffff880015fe3cd8 R08: 00000000f2a43829 R09:
ffff88001333ae7c
[  139.216013] R10: 0000000000000003 R11: 0000000000000001 R12:
ffffffff8139d6b0
[  139.216013] R13: ffff880015fe3dd8 R14: 0000000000000000 R15:
ffff880014440000
[  139.216013] FS:  0000000000000000(0000) GS:ffff880017c40000(0063)
knlGS:00000000f75e1900
[  139.216013] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  139.216013] CR2: ffffffffffffff74 CR3: 000000001521e000 CR4:
00000000000006e0
[  139.216013] Stack:
[  139.216013]  ffff880015fe3ce8 ffffffff8139d6c8 ffff880015fe3d58
ffffffff8139d8ae
[  139.216013]  ffffffff8139d810 ffffc9000032bab8 0000000000000001
ffff880014440000
[  139.216013]  ffff880014440000 0000033110522000 ffff880015fe3d58
ffff880015209090
[  139.216013] Call Trace:
[  139.216013]  [<ffffffff8139d6c8>] rhashtable_compare+0x18/0x20
[  139.216013]  [<ffffffff8139d8ae>] rhashtable_lookup_compare+0x9e/0x130
[  139.216013]  [<ffffffff8139d810>] ? lockdep_rht_mutex_is_held+0x30/0x30
[  139.216013]  [<ffffffff8139da5d>]
rhashtable_lookup_compare_insert+0xed/0x180
[  139.216013]  [<ffffffff8139d9a6>] ?
rhashtable_lookup_compare_insert+0x36/0x180
[  139.216013]  [<ffffffffa00162b2>] ? tipc_sk_create+0xa2/0x340 [tipc]
[  139.216013]  [<ffffffff8139d6b0>] ? rhashtable_destroy+0x70/0x70
[  139.216013]  [<ffffffff8139db22>] rhashtable_lookup_insert+0x32/0x40
[  139.216013]  [<ffffffffa00163fc>] tipc_sk_create+0x1ec/0x340 [tipc]
[  139.216013]  [<ffffffffa00162b2>] ? tipc_sk_create+0xa2/0x340 [tipc]
[  139.216013]  [<ffffffff81615cb0>] __sock_create+0x170/0x270
[  139.216013]  [<ffffffff81615bff>] ? __sock_create+0xbf/0x270
[  139.216013]  [<ffffffff81615e10>] sock_create+0x30/0x40
[  139.216013]  [<ffffffff81616b86>] SyS_socket+0x36/0xb0
[  139.216013]  [<ffffffff8118500f>] ? might_fault+0xaf/0xc0
[  139.216013]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  139.216013]  [<ffffffff816520eb>] compat_SyS_socketcall+0x6b/0x200
[  139.216013]  [<ffffffff81768bf3>] sysenter_dispatch+0x7/0x1f
[  139.216013]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  139.216013] Code: 31 c0 c6 06 01 5d c3 66 0f 1f 84 00 00 00 00 00 31
c0 c6 06 00 5d c3 66 0f 1f 84 00 00 00 00 00 55 31 c0 48 85 d2 48 89 e5
74 2f <0f> b6 07 0f b6 0e 29 c8 75 25 48 83 ea 01 31 c9 eb 18 0f 1f 00
[  139.216013] RIP  [<ffffffff81390b3b>] memcmp+0xb/0x50
[  139.216013]  RSP <ffff880015fe3cd8>
[  139.216013] CR2: ffffffffffffff74
[  139.216013] ---[ end trace 09b553c3efa31348 ]---
[  139.216013] Kernel panic - not syncing: Fatal exception in interrupt
[  139.216013] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation
range: 0xffffffff80000000-0xffffffff9fffffff)
[  139.216013] ---[ end Kernel panic - not syncing: Fatal exception in
interrupt

Regards,
Ying

> [   17.033416] BUG: unable to handle kernel paging request at
> ffffffffffffff77
> [   17.034009] IP: [<ffffffffa0019b8c>] jhash+0xec/0x160 [tipc]
> [...]
> [   17.034009] Call Trace:
> [   17.034009]  [<ffffffff813b38e9>] head_hashfn+0x29/0x50
> [   17.034009]  [<ffffffff813b475b>] rhashtable_expand+0x37b/0x680
> [   17.034009]  [<ffffffff813b4b38>] rht_deferred_worker+0xd8/0xe0
> [   17.034009]  [<ffffffff81074d10>] process_one_work+0x200/0x800
> [   17.034009]  [<ffffffff81074c71>] ? process_one_work+0x161/0x800
> [   17.034009]  [<ffffffff81074c71>] ? process_one_work+0x161/0x800
> [   17.034009]  [<ffffffff8107533c>] process_scheduled_works+0x2c/0x40
> [   17.034009]  [<ffffffff810758d3>] worker_thread+0x253/0x4b0
> [   17.034009]  [<ffffffff81075680>] ? rescuer_thread+0x330/0x330
> [   17.034009]  [<ffffffff8107bb6f>] kthread+0xef/0x110
> [   17.034009]  [<ffffffff8107ba80>] ? flush_kthread_work+0x170/0x170
> [   17.034009]  [<ffffffff81a44a2c>] ret_from_fork+0x7c/0xb0
> [   17.034009]  [<ffffffff8107ba80>] ? flush_kthread_work+0x170/0x170
> 
> 
> 
> 


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
