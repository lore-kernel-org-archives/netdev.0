From: Josh Hunt <johunt@akamai.com>
Subject: panic on boot with latest net-next
Date: Fri, 06 Feb 2015 15:02:14 -0600
Message-ID: <54D52BD6.2080109@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:25042 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752987AbbBFVCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 16:02:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm hitting the following crash on boot with the latest net-next 
(2ca292d968ef20cb04f31192d1f626bd8d782960):

[   14.550948] BUG: unable to handle kernel paging request at 
fffffffffffffef0
[   14.558955] IP: [<ffffffff815657fa>] netlink_compare+0xa/0x30
[   14.565258] PGD 191f067 PUD 1921067 PMD 0
[   14.570118] Oops: 0000 [#1] SMP
[   14.573997] Modules linked in: ext4 jbd2 crc16 raid10 raid456 
async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx 
raid1 raid0 linear md_mod dm_mod ahci libahci mpt2sas scsi_transport_sas 
raid_class libata
[   14.597480] CPU: 0 PID: 1828 Comm: udevd Not tainted 3.19.0-rc7+ #7
[   14.604226] Hardware name: CIARA TECHNOLOGIES 1X8-X6 SSD 16G 
10GE/S5530WG2NR-LE-2T-AKA, BIOS 7.008 14/04/2014
[   14.614973] task: ffff88040a63e6d0 ti: ffff88040d340000 task.ti: 
ffff88040d340000
[   14.623304] RIP: 0010:[<ffffffff815657fa>]  [<ffffffff815657fa>] 
netlink_compare+0xa/0x30
[   14.632421] RSP: 0018:ffff88040d343db0  EFLAGS: 00010246
[   14.638188] RAX: 0000000000000000 RBX: ffff88040d2b5158 RCX: 
00000000c74f856c
[   14.645783] RDX: 0000000000000724 RSI: ffff88040d343e10 RDI: 
fffffffffffffc50
[   14.653378] RBP: ffff88040d343df8 R08: 00000000e684c87d R09: 
ffff88040d343e24
[   14.660972] R10: 00007fffed830500 R11: 0000000000000202 R12: 
ffffffff815657f0
[   14.668564] R13: ffff88040d343e10 R14: ffff88040a5d9040 R15: 
0000000000000000
[   14.676161] FS:  00007fb45823a7c0(0000) GS:ffff88041fc00000(0000) 
knlGS:0000000000000000
[   14.685094] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   14.691304] CR2: fffffffffffffef0 CR3: 000000040a241000 CR4: 
00000000001407f0
[   14.698898] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[   14.706492] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[   14.714086] Stack:
[   14.716555]  ffffffff8135a254 0000000000000009 ffff88040a5d9040 
ffff88040d343e08
[   14.725179]  0000000000000724 ffff88040d2b5158 ffffffff819c3a80 
00000000ffffefff
[   14.733804]  ffff88040cc66000 ffff88040d343e58 ffffffff8156781e 
ffff88040d343e18
[   14.742428] Call Trace:
[   14.745351]  [<ffffffff8135a254>] ?
rhashtable_lookup_compare+0x74/0xc0
[   14.752425]  [<ffffffff8156781e>] netlink_autobind.isra.26+0x9e/0xd0
[   14.759240]  [<ffffffff81567f4f>] netlink_bind+0xcf/0x250
[   14.765103]  [<ffffffff815219e4>] SyS_bind+0xb4/0xd0
[   14.770530]  [<ffffffff81011170>] ? syscall_trace_enter_phase1+0xf0/0x150
[   14.777778]  [<ffffffff81616bfd>] ? int_check_syscall_exit_work+0x34/0x3d
[   14.785026]  [<ffffffff816169d2>] system_call_fastpath+0x12/0x17
[   14.791495] Code: ff 93 88 02 00 00 f0 ff 83 d8 00 00 00 48 83 c4 08 
5b 5d c3 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 
56 08 <39> 97 a0 02 00 00 55 48 89 e5 74 0a 5d c3 0f 1f 84 00 00 00 00
[   14.818000] RIP  [<ffffffff815657fa>] netlink_compare+0xa/0x30
[   14.824391]  RSP <ffff88040d343db0>
[   14.828340] CR2: fffffffffffffef0
[   14.832115] ---[ end trace 2c31c5b4adad18c3 ]---
[   14.979678] Kernel panic - not syncing: Fatal exception
[   14.985392] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation 
range: 0xffffffff80000000-0xffffffff9fffffff)
[   15.138889] Rebooting in 30 seconds..


(gdb) list *(netlink_compare+0xa)
0xffffffff815657fa is in netlink_compare (net/netlink/af_netlink.c:982).
977	static bool netlink_compare(void *ptr, void *arg)
978	{
979		struct netlink_compare_arg *x = arg;
980		struct sock *sk = ptr;
981	
982		return nlk_sk(sk)->portid == x->portid &&
983		       net_eq(sock_net(sk), x->net);
984	}
985	
986	static struct sock *__netlink_lookup(struct netlink_table *table, 
u32 portid,

I assumed this was rhashtable-related and so sending to Thomas and 
Herbert, but if not please let me know and I get it to the right person.

I'm happy to test any patches you may have to resolve this. Also, let me 
know if you need my config file to reproduce.

Thanks
Josh
