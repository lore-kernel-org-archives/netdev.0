From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: 2.6.35->2.6.36 regression, vanilla kernel panic, ppp or hrtimers crashing
Date: Mon, 25 Oct 2010 12:22:36 +0300
Message-ID: <201010251222.37191.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>,
	Paul Mackerras <paulus@samba.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Here is what i got from netconsole
 [  259.238755] BUG: unable to handle kernel 
 paging request
 at f8ba001c
 [  259.238953] IP:
 [<c0199ebe>] do_select+0x2cc/0x502
 [  259.239008] *pdpt = 0000000000a55001 
 *pde = 0000000036dd6067 
 *pte = 0000000000000000 
 
 [  259.239008] Oops: 0000 [#1] 
 SMP 
 
 [  259.239008] last sysfs file: /sys/devices/pnp0/00:02/rtc/rtc0/dev
 [  259.239008] Modules linked in:
 rtc_cmos
 rtc_core
 rtc_lib
 act_skbedit
 sch_ingress
 sch_prio
 
 configfs
 cls_flow
 cls_u32
 em_meta
 cls_basic
 xt_dscp
 ipt_REJECT
 ts_bm
 xt_string
 xt_hl
 ifb
 cls_fw
 sch_tbf
 sch_htb
 act_ipt
 act_mirred
 pppoe
 pppox
 ppp_generic
 slhc
 ipt_REDIRECT
 ipt_MASQUERADE
 xt_TCPMSS
 xt_DSCP
 xt_mark
 xt_tcpudp
 iptable_mangle
 iptable_nat
 nf_nat
 nf_conntrack_ipv4
 nf_conntrack
 nf_defrag_ipv4
 iptable_filter
 ip_tables
 x_tables
 8021q
 garp
 stp
 llc
 loop
 usb_storage
 iTCO_wdt
 iTCO_vendor_support
 ata_generic
 pata_acpi
 ata_piix
 libata
 8139cp
 sr_mod
 cdrom
 tulip
 r8169
 sky2
 via_velocity
 via_rhine
 sis900
 ne2k_pci
 8390
 skge
 tg3
 libphy
 8139too
 e1000
 e100
 usbhid
 ohci_hcd
 uhci_hcd
 ehci_hcd
 usbcore
 nls_base
 
 [  259.239008] 
 [  259.239008] Pid: 3307, comm: pppd Not tainted 2.6.36-build-0053 #14 
D915GAV                        /        
 [  259.239008] EIP: 0060:[<c0199ebe>] EFLAGS: 00010286 CPU: 0
 [  259.239008] EIP is at do_select+0x2cc/0x502
 [  259.239008] EAX: f610a600 EBX: 00000080 ECX: f8ba0000 EDX: f60f1808
 [  259.239008] ESI: 00000000 EDI: f610a600 EBP: f60eae4c ESP: f60eab64
 [  259.239008]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
 [  259.239008] Process pppd (pid: 3307, ti=f60ea000 task=f66a0000 
task.ti=f60ea000)
 [  259.239008] Stack:
 [  259.239008]  0e95bb42
 0000003d
 000000d0
 00000000
 f60eaf60
 f66a0000
 f60eae6c
 f60eae70
 
 [  259.239008] <0>
 f60eae74
 f60eae60
 f60eae64
 f60eae68
 00000180
 00000020
 010eabdc
 002dc698
 
 [  259.239008] <0>
 f60eae34
 00000180
 00000000
 00000180
 00000000
 00000000
 00000000
 00000000
 
 [  259.239008] Call Trace:
 [  259.239008]  [<c019a484>] ? __pollwait+0x0/0xa5
 [  259.239008]  [<c019a529>] ? pollwake+0x0/0x63
 [  259.239008]  [<c019a529>] ? pollwake+0x0/0x63
 [  259.239008]  [<c0143f37>] ? sched_clock_local+0x17/0x13d
 [  259.239008]  [<c0122ac4>] ? update_curr+0x84/0x15c
 [  259.239008]  [<c011f5a3>] ? kmap_atomic_prot+0xe1/0xe3
 [  259.239008]  [<c0143f37>] ? sched_clock_local+0x17/0x13d
 [  259.239008]  [<c02044ee>] ? put_dec+0x2a/0x74
 [  259.239008]  [<c0204689>] ? number+0x151/0x223
 [  259.239008]  [<c012461f>] ? dequeue_task_fair+0x283/0x28b
 [  259.239008]  [<c0123845>] ? __dequeue_entity+0x23/0x27
 [  259.239008]  [<c01238d6>] ? set_next_entity+0x8d/0xf7
 [  259.239008]  [<c012889c>] ? finish_task_switch+0x33/0x7a
 [  259.239008]  [<c02f931c>] ? schedule+0x5c0/0x5ff
 [  259.239008]  [<c019a208>] ? core_sys_select+0x114/0x190
 [  259.239008]  [<c015ce1c>] ? call_rcu_sched+0xd/0xf
 [  259.239008]  [<c015ce26>] ? call_rcu+0x8/0xa
 [  259.239008]  [<c012f80b>] ? release_task+0x28d/0x29d
 [  259.239008]  [<c012fc80>] ? wait_consider_task+0x465/0x7b7
 [  259.239008]  [<c013fa7f>] ? spin_unlock_irqrestore+0x8/0xa
 [  259.239008]  [<c013fc10>] ? remove_wait_queue+0x31/0x36
 [  259.239008]  [<f8bacff1>] ? ppp_read+0x101/0x145 [ppp_generic]
 [  259.239008]  [<c0145ceb>] ? timekeeping_get_ns+0x11/0x4f
 [  259.239008]  [<c014688a>] ? ktime_get_ts+0x89/0x93
 [  259.239008]  [<c019a42e>] ? sys_select+0x68/0x84
 [  259.239008]  [<c02fa625>] ? syscall_call+0x7/0xb
 [  259.239008] Code: 
 85 
 9d 
 48 
 fd 
 ff 
 ff 
 0f 
 84 
 cb 
 00 
 00 
 00 
 8b 
 85 
 7c 
 fd 
 ff 
 ff 
 8d 
 55 
 f0 
 e8 
 c1 
 55 
 ff 
 ff 
 85 
 c0 
 89 
 c7 
 0f 
 84 
 b3 
 00 
 00 
 00 
 8b 
 48 
 10 
 85 
 c9 
 74 
 3a 
 
 79 
 1c 
 00 
 74 
 34 
 85 
 f6 
 74 
 25 
 c7 
 46 
 04 
 02 
 00 
 00 
 00 
 85 
 9d 
 5c 
 fd 
 
 [  259.239008] EIP: [<c0199ebe>] 
 do_select+0x2cc/0x502
 SS:ESP 0068:f60eab64
 [  259.239008] CR2: 00000000f8ba001c
 [  259.239008] ---[ end trace a6117b9e067aeb87 ]---
 [  259.239008] Kernel panic - not syncing: Fatal exception
 [  259.239008] Pid: 3307, comm: pppd Tainted: G      D     2.6.36-build-0053 
#14
 [  259.239008] Call Trace:
 [  259.239008]  [<c02f8ace>] ? printk+0xf/0x11
 [  259.239008]  [<c02f89cb>] panic+0x50/0x144
 [  259.239008]  [<c0105061>] oops_end+0x8b/0x9a
 [  259.239008]  [<c011af70>] no_context+0x13e/0x148
 [  259.239008]  [<c0142b8c>] ? hrtimer_try_to_cancel+0x60/0x69
 [  259.239008]  [<c011b05f>] __bad_area_nosemaphore+0xe5/0xed
 [  259.239008]  [<c011b074>] bad_area_nosemaphore+0xd/0x10
 [  259.239008]  [<c011b2d6>] do_page_fault+0xf6/0x230
 [  259.239008]  [<c011b1e0>] ? do_page_fault+0x0/0x230
 [  259.239008]  [<c02fac22>] error_code+0x5a/0x60
 [  259.239008]  [<c019007b>] ? grab_super+0x30/0x56
 [  259.239008]  [<c011b1e0>] ? do_page_fault+0x0/0x230
 [  259.239008]  [<c0199ebe>] ? do_select+0x2cc/0x502
 [  259.239008]  [<c019a484>] ? __pollwait+0x0/0xa5
 [  259.239008]  [<c019a529>] ? pollwake+0x0/0x63
 [  259.239008]  [<c019a529>] ? pollwake+0x0/0x63
 [  259.239008]  [<c0143f37>] ? sched_clock_local+0x17/0x13d
 [  259.239008]  [<c0122ac4>] ? update_curr+0x84/0x15c
 [  259.239008]  [<c011f5a3>] ? kmap_atomic_prot+0xe1/0xe3
 [  259.239008]  [<c0143f37>] ? sched_clock_local+0x17/0x13d
 [  259.239008]  [<c02044ee>] ? put_dec+0x2a/0x74
 [  259.239008]  [<c0204689>] ? number+0x151/0x223
 [  259.239008]  [<c012461f>] ? dequeue_task_fair+0x283/0x28b
 [  259.239008]  [<c0123845>] ? __dequeue_entity+0x23/0x27
 [  259.239008]  [<c01238d6>] ? set_next_entity+0x8d/0xf7
 [  259.239008]  [<c012889c>] ? finish_task_switch+0x33/0x7a
 [  259.239008]  [<c02f931c>] ? schedule+0x5c0/0x5ff
 [  259.239008]  [<c019a208>] core_sys_select+0x114/0x190
 [  259.239008]  [<c015ce1c>] ? call_rcu_sched+0xd/0xf
 [  259.239008]  [<c015ce26>] ? call_rcu+0x8/0xa
 [  259.239008]  [<c012f80b>] ? release_task+0x28d/0x29d
 [  259.239008]  [<c012fc80>] ? wait_consider_task+0x465/0x7b7
 [  259.239008]  [<c013fa7f>] ? spin_unlock_irqrestore+0x8/0xa
 [  259.239008]  [<c013fc10>] ? remove_wait_queue+0x31/0x36
 [  259.239008]  [<f8bacff1>] ? ppp_read+0x101/0x145 [ppp_generic]
 [  259.239008]  [<c0145ceb>] ? timekeeping_get_ns+0x11/0x4f
 [  259.239008]  [<c014688a>] ? ktime_get_ts+0x89/0x93
 [  259.239008]  [<c019a42e>] sys_select+0x68/0x84
 [  259.239008]  [<c02fa625>] syscall_call+0x7/0xb
 [  259.239008] Rebooting in 5 seconds..

It is not easy to do full git bisect(it is semi-embedded distro), but i can 
try reversing particular commits, if someone can give idea which one, and can 
try debug patches.
