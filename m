From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: OOPS, bug in geth.c ?
Date: Mon, 18 Dec 2006 16:00:06 +0100
Message-ID: <F6AD7E21CDF4E145A44F61F43EE6D939BA72B5@tmnt04.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
content-class: urn:content-classes:message
To: "Timur Tabi" <timur@freescale.com>,
	<netdev@vger.kernel.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Someone just looped the ethernet in the lab and this 
happend in my 2.6.19-rc5 when booting. After 180 seconds the
system tried to restart but that resulted in another OOPS and so on.

 Jocke

NETDEV WATCHDOG: eth0: transmit timed out
Badness in free_irq at kernel/irq/manage.c:353
Call Trace:
[C038B860] [C000860C] show_stack+0x48/0x194 (unreliable)
[C038B890] [C000E0D0] program_check_exception+0x344/0x594
[C038B8D0] [C000F764] ret_from_except_full+0x0/0x4c
--- Exception: 700 at free_irq+0x20/0x110
    LR = ucc_geth_stop+0x94/0x104
[C038B990] [C0021514] tasklet_action+0x78/0xe4 (unreliable)
[C038B9B0] [C011BE9C] ucc_geth_stop+0x94/0x104
[C038B9D0] [C011D834] ucc_geth_timeout+0x5c/0x8c
[C038B9E0] [C0163670] dev_watchdog+0xa0/0x108
[C038BA00] [C002513C] run_timer_softirq+0xe8/0x1b8
[C038BA40] [C0021184] __do_softirq+0x80/0xe4
[C038BA70] [C00057D4] do_softirq+0x58/0x60
[C038BA80] [C0021230] irq_exit+0x48/0x58
[C038BA90] [C000572C] do_IRQ+0x84/0xd4
[C038BAA0] [C000F7B0] ret_from_except+0x0/0x14
--- Exception: 501 at jffs2_scan_medium+0xae4/0xf90
    LR = jffs2_scan_medium+0x190/0xf90
[C038BBE0] [C00D6148] jffs2_do_mount_fs+0x1b4/0x6f8
[C038BC10] [C00D80C4] jffs2_do_fill_super+0xc0/0x224
[C038BC30] [C00D8870] jffs2_get_sb_mtd+0xe0/0x168
[C038BC70] [C00D8AB0] jffs2_get_sb+0x140/0x1e8
[C038BD00] [C005C7C4] vfs_kern_mount+0x5c/0xbc
[C038BD20] [C005C860] do_kern_mount+0x3c/0x60
[C038BD40] [C0073978] do_mount+0x39c/0x68c
[C038BEC0] [C0074004] sys_mount+0x98/0xe8
[C038BEF0] [C01F8880] do_mount_root+0x2c/0xc4
[C038BF10] [C01F89DC] mount_block_root+0xc4/0x24c
[C038BF60] [C01F8E90] prepare_namespace+0xec/0x1b4
[C038BF80] [C0003B30] init+0x260/0x2f0
[C038BFF0] [C000FF48] kernel_thread+0x44/0x60
Badness in free_irq at kernel/irq/manage.c:353
Call Trace:
[C038B860] [C000860C] show_stack+0x48/0x194 (unreliable)
[C038B890] [C000E0D0] program_check_exception+0x344/0x594
[C038B8D0] [C000F764] ret_from_except_full+0x0/0x4c
--- Exception: 700 at free_irq+0x20/0x110
    LR = ucc_geth_stop+0xb4/0x104
[C038B990] [C003AFD0] free_irq+0xc0/0x110 (unreliable)
[C038B9B0] [C011BEBC] ucc_geth_stop+0xb4/0x104
[C038B9D0] [C011D834] ucc_geth_timeout+0x5c/0x8c
[C038B9E0] [C0163670] dev_watchdog+0xa0/0x108
[C038BA00] [C002513C] run_timer_softirq+0xe8/0x1b8
[C038BA40] [C0021184] __do_softirq+0x80/0xe4
[C038BA70] [C00057D4] do_softirq+0x58/0x60
[C038BA80] [C0021230] irq_exit+0x48/0x58
[C038BA90] [C000572C] do_IRQ+0x84/0xd4
[C038BAA0] [C000F7B0] ret_from_except+0x0/0x14
--- Exception: 501 at jffs2_scan_medium+0xae4/0xf90
    LR = jffs2_scan_medium+0x190/0xf90
[C038BBE0] [C00D6148] jffs2_do_mount_fs+0x1b4/0x6f8
[C038BC10] [C00D80C4] jffs2_do_fill_super+0xc0/0x224
[C038BC30] [C00D8870] jffs2_get_sb_mtd+0xe0/0x168
[C038BC70] [C00D8AB0] jffs2_get_sb+0x140/0x1e8
[C038BD00] [C005C7C4] vfs_kern_mount+0x5c/0xbc
[C038BD20] [C005C860] do_kern_mount+0x3c/0x60
[C038BD40] [C0073978] do_mount+0x39c/0x68c
[C038BEC0] [C0074004] sys_mount+0x98/0xe8
[C038BEF0] [C01F8880] do_mount_root+0x2c/0xc4
[C038BF10] [C01F89DC] mount_block_root+0xc4/0x24c
[C038BF60] [C01F8E90] prepare_namespace+0xec/0x1b4
[C038BF80] [C0003B30] init+0x260/0x2f0
[C038BFF0] [C000FF48] kernel_thread+0x44/0x60
kernel BUG in __get_vm_area_node at mm/vmalloc.c:171!
Oops: Exception in kernel mode, sig: 5 [#1]

NIP: C0050F1C LR: C0011198 CTR: 00000000
REGS: c038b860 TRAP: 0700   Not tainted  (2.6.19-rc5)
MSR: 00029032 <EE,ME,IR,DR>  CR: 24022044  XER: 00000000
TASK = c07fbb40[1] 'swapper' THREAD: c038a000
GPR00: 00000100 C038B910 C07FBB40 00001000 00000001 C9000000 FDEFB000
FFFFFFFF
GPR08: 000000D0 C038A000 00000030 00000000 C025B508 10078B2C 0FFFCA00
007FFF94
GPR16: 00000000 00000000 0000000A 0360000C 00000000 000001B0 03600000
00000000
GPR24: 0000C000 C0250000 00000001 FDEFB000 00000001 00000000 00001000
C0266F80
NIP [C0050F1C] __get_vm_area_node+0x2c/0x1c0
LR [C0011198] __ioremap+0x144/0x184
Call Trace:
[C038B910] [C0263E84] 0xc0263e84 (unreliable)
[C038B930] [C0011198] __ioremap+0x144/0x184
[C038B960] [C0015A5C] ucc_fast_init+0x100/0x470
[C038B980] [C011C168] ucc_geth_startup+0x25c/0x18c4
[C038B9D0] [C011D83C] ucc_geth_timeout+0x64/0x8c
[C038B9E0] [C0163670] dev_watchdog+0xa0/0x108
[C038BA00] [C002513C] run_timer_softirq+0xe8/0x1b8
[C038BA40] [C0021184] __do_softirq+0x80/0xe4
[C038BA70] [C00057D4] do_softirq+0x58/0x60
[C038BA80] [C0021230] irq_exit+0x48/0x58
[C038BA90] [C000572C] do_IRQ+0x84/0xd4
[C038BAA0] [C000F7B0] ret_from_except+0x0/0x14
--- Exception: 501 at jffs2_scan_medium+0xae4/0xf90
    LR = jffs2_scan_medium+0x190/0xf90
[C038BBE0] [C00D6148] jffs2_do_mount_fs+0x1b4/0x6f8
[C038BC10] [C00D80C4] jffs2_do_fill_super+0xc0/0x224
[C038BC30] [C00D8870] jffs2_get_sb_mtd+0xe0/0x168
[C038BC70] [C00D8AB0] jffs2_get_sb+0x140/0x1e8
[C038BD00] [C005C7C4] vfs_kern_mount+0x5c/0xbc
[C038BD20] [C005C860] do_kern_mount+0x3c/0x60
[C038BD40] [C0073978] do_mount+0x39c/0x68c
[C038BEC0] [C0074004] sys_mount+0x98/0xe8
[C038BEF0] [C01F8880] do_mount_root+0x2c/0xc4
[C038BF10] [C01F89DC] mount_block_root+0xc4/0x24c
[C038BF60] [C01F8E90] prepare_namespace+0xec/0x1b4
[C038BF80] [C0003B30] init+0x260/0x2f0
[C038BFF0] [C000FF48] kernel_thread+0x44/0x60
Instruction dump:
4bffff20 7c0802a6 9421ffe0 bf410008 54290024 7c7e1b78 7c9a2378 90010024
7cdb3378 3b800001 8009000c 5400012e <0f000000> 70800001 41820020
7c600034
 <0>Kernel panic - not syncing: Fatal exception in interrupt
 <0>Rebooting in 180 seconds..<2>kernel BUG in __get_vm_area_node at 
mm/vmalloc.c:171!
Oops: Exception in kernel mode, sig: 5 [#2]
