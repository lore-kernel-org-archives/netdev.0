From: Wim Vandersmissen <Wim.Vandersmissen@icts.kuleuven.be>
Subject: kernel BUG at net/core/skbuff.c:1048!
Date: Fri, 04 Oct 2013 11:35:55 +0200
Message-ID: <524E8BFB.9080708@icts.kuleuven.be>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090802080200060901050102"
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhcavspool02.kulnet.kuleuven.be ([134.58.240.194]:41968 "EHLO
	cavspool01.kulnet.kuleuven.be" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750905Ab3JDJrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 05:47:25 -0400
Received: from cavuit02.kulnet.kuleuven.be (rhcavuit02.kulnet.kuleuven.be [134.58.240.130])
	by cavspool01.kulnet.kuleuven.be (Postfix) with ESMTP id 7BBC1713E
	for <netdev@vger.kernel.org>; Fri,  4 Oct 2013 11:36:57 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090802080200060901050102
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Got the following BUG when using ipv6 netfilter/conntrack/ipv6 
forwarding and traffic flowing.

No issues in 3.4.x, but triggered in 3.10.x (introduced in 3.7)


git bisect tells me:

58a317f1061c894d2344c0b6a18ab4a64b69b815 is the first bad commit
commit 58a317f1061c894d2344c0b6a18ab4a64b69b815
Author: Patrick McHardy <kaber@trash.net>
Date:   Sun Aug 26 19:14:12 2012 +0200
netfilter: ipv6: add IPv6 NAT support




kernel: kernel BUG at net/core/skbuff.c:1048!
kernel: invalid opcode: 0000 [#1] SMP
kernel: icrocode]
kernel: CPU 2
kernel: Pid: 0, comm: swapper/2 Not tainted 3.6.0-rc2+ #1 HP ProLiant 
DL380 G6
kernel: RIP: 0010:[<ffffffff8126d8b8>]  [<ffffffff8126d8b8>] 
pskb_expand_head+0x30/0x210
kernel: RSP: 0018:ffff88019fc239f0  EFLAGS: 00010202
kernel: RAX: 0000000000000001 RBX: ffff88018ae50880 RCX: 0000000000000020
kernel: RDX: 0000000000000000 RSI: 00000000000002c0 RDI: ffff88018ae50880
kernel: RBP: 0000000000000020 R08: 0000000000000000 R09: 0000000000000000
kernel: R10: ffff88018af4a2c0 R11: ffffffffa0271ff8 R12: 0000000000000000
kernel: R13: ffff880196ca26c0 R14: ffff88018ac55456 R15: ffffffff814b0f40
kernel: FS:  0000000000000000(0000) GS:ffff88019fc20000(0000) 
knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
kernel: CR2: ffffffffff600000 CR3: 000000018b2ab000 CR4: 00000000000007e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
kernel: Process swapper/2 (pid: 0, threadinfo ffff8801990ca000, task 
ffff88019909e090)
kernel: Stack:
kernel: 0000000800000040 ffff88018ae50880 ffff88018ae50880 0000000000000000
kernel: ffff880196ca26c0 ffff88018ac55456 ffffffff814b0f40 ffffffffa02725ab
kernel: 0000000800000000 0006000000000000 402c022a00000000 ffff88018ae508a8
kernel: Call Trace:
kernel: <IRQ>
kernel: [<ffffffffa02725ab>] ? ip6_forward+0x5b3/0x72a [ipv6]
kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
kernel: [<ffffffffa02f7407>] ? __ipv6_conntrack_in+0xed/0x153 
[nf_conntrack_ipv6]
kernel: [<ffffffff81298f00>] ? nf_iterate+0x50/0x8b
kernel: [<ffffffff810372eb>] ? mod_timer+0x15e/0x16c
kernel: [<ffffffffa0273b0a>] ? ip6_xmit+0x2d2/0x368 [ipv6]
kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
kernel: [<ffffffff81299135>] ? nf_hook_slow+0x67/0xfb
kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
kernel: [<ffffffffa02f22c0>] ? nf_ct_frag6_output+0x97/0xe1 [nf_defrag_ipv6]
kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
kernel: [<ffffffffa02f207b>] ? ipv6_defrag+0x7a/0x8f [nf_defrag_ipv6]
kernel: [<ffffffff81298f00>] ? nf_iterate+0x50/0x8b
kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
kernel: [<ffffffff81299135>] ? nf_hook_slow+0x67/0xfb
kernel: [<ffffffffa0273bf1>] ? ip6_input+0x51/0x51 [ipv6]
kernel: [<ffffffffa0273f3f>] ? ipv6_rcv+0x2ea/0x33b [ipv6]
kernel: [<ffffffff8127485b>] ? __netif_receive_skb+0x623/0x692
kernel: [<ffffffff81275e66>] ? netif_receive_skb+0x71/0x77
kernel: [<ffffffff8127a2ec>] ? napi_gro_receive+0xe9/0xfb
kernel: [<ffffffff81275ee5>] ? napi_skb_finish+0x1c/0x51
kernel: [<ffffffffa015da8a>] ? ixgbe_poll+0xcd6/0xf04 [ixgbe]
kernel: [<ffffffff81279093>] ? net_rx_action+0xa7/0x189
kernel: [<ffffffff81031dfd>] ? __do_softirq+0xce/0x1a7
kernel: [<ffffffff8106b1f2>] ? handle_irq_event_percpu+0x16b/0x182
kernel: [<ffffffff813121ac>] ? call_softirq+0x1c/0x30
kernel: [<ffffffff81003885>] ? do_softirq+0x31/0x64
kernel: [<ffffffff81032156>] ? irq_exit+0x43/0x61
kernel: [<ffffffff81002ee9>] ? do_IRQ+0x98/0xae
kernel: [<ffffffff8130b167>] ? common_interrupt+0x67/0x67
kernel: <EOI>
kernel: [<ffffffff81053b71>] ? switched_from_fair+0x4c/0x4c
kernel: [<ffffffff81008b6c>] ? mwait_idle+0xf6/0x17a
kernel: [<ffffffff81008a51>] ? cpu_idle+0x53/0x78
kernel: Code: 55 41 54 55 89 cd 53 48 89 fb 48 83 ec 08 89 34 24 8b b7 
d0 00 00 00 83 3c 24 00 79 04 0f 0b eb fe 8b 87 ec 00 00 00 ff c8 74 04 
<0f> 0b eb fe 89 c8 48 8b 4c 24 38 80 cc 20 f6 87 b0 00 00 00 04
kernel: RIP [<ffffffff8126d8b8>] pskb_expand_head+0x30/0x210
kernel: RSP <ffff88019fc239f0>


git bisect start
# good: [b2824f4e0990716407b0c0e7acee75bb6353febf] Linux 3.6.11
git bisect good b2824f4e0990716407b0c0e7acee75bb6353febf
# bad: [ddffeb8c4d0331609ef2581d84de4d763607bd37] Linux 3.7-rc1
git bisect bad ddffeb8c4d0331609ef2581d84de4d763607bd37
# good: [a0d271cbfed1dd50278c6b06bead3d00ba0a88f9] Linux 3.6
git bisect good a0d271cbfed1dd50278c6b06bead3d00ba0a88f9
# bad: [24d7b40a60cf19008334bcbcbd98da374d4d9c64] ARM: OMAP2+: PM: MPU 
DVFS: use generic CPU device for MPU-SS
git bisect bad 24d7b40a60cf19008334bcbcbd98da374d4d9c64
# good: [d9a807461fc8cc0d6ba589ea0730d139122af012] Merge tag 'usb-3.6' 
of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb
git bisect good d9a807461fc8cc0d6ba589ea0730d139122af012
# good: [a20acf99f75e49271381d65db097c9763060a1e8] Merge 
git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-next
git bisect good a20acf99f75e49271381d65db097c9763060a1e8
# bad: [30099b2e9b3a1f88250d31472edf2b6d6f0a7d8b] tcp: TCP Fast Open 
Server - record retransmits after 3WHS
git bisect bad 30099b2e9b3a1f88250d31472edf2b6d6f0a7d8b
# good: [6cc2ff82492d89f763e69ea6b8681926aceda610] netdev/phy: add MDIO 
bus multiplexer driven by a memory-mapped device
git bisect good 6cc2ff82492d89f763e69ea6b8681926aceda610
# bad: [e97563989a609296c3cbf5b6d8c8dc0a3e47b00b] Merge branch 'master' 
of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
git bisect bad e97563989a609296c3cbf5b6d8c8dc0a3e47b00b
# bad: [1e9f0207d3e63fab7a0f8a0e532bdc73ea850baf] Merge branch 'master' 
of git://1984.lsi.us.es/nf-next
git bisect bad 1e9f0207d3e63fab7a0f8a0e532bdc73ea850baf
# good: [eb7e0575966f9c84434e92c8a3f69719cc2e7571] ipv6: remove some 
deadcode
git bisect good eb7e0575966f9c84434e92c8a3f69719cc2e7571
# bad: [236df005614bea6a2f9afa9867e3bdfc206c6291] netfilter: xt_CT: 
refactorize xt_ct_tg_check
git bisect bad 236df005614bea6a2f9afa9867e3bdfc206c6291
# bad: [58a317f1061c894d2344c0b6a18ab4a64b69b815] netfilter: ipv6: add 
IPv6 NAT support
git bisect bad 58a317f1061c894d2344c0b6a18ab4a64b69b815
# good: [811927ccfe90fbfcfff5253ba7f95057f6cae692] netfilter: 
nf_conntrack: restrict NAT helper invocation to IPv4
git bisect good 811927ccfe90fbfcfff5253ba7f95057f6cae692
# good: [c7232c9979cba684c50b64c513c4a83c9aa70563] netfilter: add 
protocol independent NAT core
git bisect good c7232c9979cba684c50b64c513c4a83c9aa70563
# good: [2cf545e835aae92173ef0b1f4af385e9c40f21e8] net: core: add 
function for incremental IPv6 pseudo header checksum updates
git bisect good 2cf545e835aae92173ef0b1f4af385e9c40f21e8

Thanks,


Wim



--------------090802080200060901050102
Content-Type: text/plain; charset=windows-1252;
 name="dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dmesg.txt"

kernel: Linux version 3.6.0-rc2+ (root@builder) (gcc version 4.1.2 20080704 (Red Hat 4.1.2-54)) #1 SMP Fri Oct 4 01:31:21 CEST 2013
kernel: Command line: ro root=LABEL=/ nofb text
kernel: e820: BIOS-provided physical RAM map:
kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009f3ff] usable
kernel: BIOS-e820: [mem 0x000000000009f400-0x000000000009ffff] reserved
kernel: BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
kernel: BIOS-e820: [mem 0x0000000000100000-0x00000000df62efff] usable
kernel: BIOS-e820: [mem 0x00000000df62f000-0x00000000df63bfff] ACPI data
kernel: BIOS-e820: [mem 0x00000000df63c000-0x00000000df63cfff] usable
kernel: BIOS-e820: [mem 0x00000000df63d000-0x00000000e3ffffff] reserved
kernel: BIOS-e820: [mem 0x00000000fec00000-0x00000000fee0ffff] reserved
kernel: BIOS-e820: [mem 0x00000000ff800000-0x00000000ffffffff] reserved
kernel: BIOS-e820: [mem 0x0000000100000000-0x000000031fffefff] usable
kernel: NX (Execute Disable) protection: active
kernel: DMI 2.6 present.
kernel: DMI: HP ProLiant DL380 G6, BIOS P62 03/30/2010
kernel: e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
kernel: e820: remove [mem 0x000a0000-0x000fffff] usable
kernel: No AGP bridge found
kernel: e820: last_pfn = 0x31ffff max_arch_pfn = 0x400000000
kernel: MTRR default type: write-back
kernel: MTRR fixed ranges enabled:
kernel:  00000-9FFFF write-back
kernel:  A0000-BFFFF uncachable
kernel:  C0000-FFFFF write-protect
kernel: MTRR variable ranges enabled:
kernel:  0 base 00E0000000 mask FFE0000000 uncachable
kernel:  1 disabled
kernel:  2 disabled
kernel:  3 disabled
kernel:  4 disabled
kernel:  5 disabled
kernel:  6 disabled
kernel:  7 disabled
kernel:  8 disabled
kernel:  9 disabled
kernel: x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
kernel: e820: last_pfn = 0xdf63d max_arch_pfn = 0x400000000
kernel: found SMP MP-table at [mem 0x000f4f80-0x000f4f8f] mapped at [ffff8800000f4f80]
kernel: initial memory mapped: [mem 0x00000000-0x1fffffff]
kernel: Base memory trampoline at [ffff880000099000] 99000 size 24576
kernel: Using GB pages for direct mapping
kernel: init_memory_mapping: [mem 0x00000000-0xdf63cfff]
kernel: [mem 0x00000000-0xbfffffff] page 1G
kernel: [mem 0xc0000000-0xdf5fffff] page 2M
kernel: [mem 0xdf600000-0xdf63cfff] page 4k
kernel: kernel direct mapping tables up to 0xdf63cfff @ [mem 0x1f9fd000-0x1fffffff]
kernel: init_memory_mapping: [mem 0x100000000-0x31fffefff]
kernel: [mem 0x100000000-0x2ffffffff] page 1G
kernel: [mem 0x300000000-0x31fdfffff] page 2M
kernel: [mem 0x31fe00000-0x31fffefff] page 4k
kernel: kernel direct mapping tables up to 0x31fffefff @ [mem 0xdf62c000-0xdf62efff]
kernel: RAMDISK: [mem 0x37c81000-0x37feffff]
kernel: ACPI: RSDP 00000000000f4f00 00024 (v02 HP    )
kernel: ACPI: XSDT 00000000df630040 000B4 (v01 HP     ProLiant 00000002   <D2>? 0000162E)
kernel: ACPI: FACP 00000000df630140 000F4 (v03 HP     ProLiant 00000002   <D2>? 0000162E)
kernel: ACPI BIOS Bug: Warning: Invalid length for FADT/Pm1aControlBlock: 32, using default 16 (20120711/tbfadt-648)
kernel: ACPI BIOS Bug: Warning: Invalid length for FADT/Pm2ControlBlock: 32, using default 8 (20120711/tbfadt-648)
kernel: ACPI: DSDT 00000000df630240 02005 (v01 HP         DSDT 00000001 INTL 20030228)
kernel: ACPI: FACS 00000000df62f100 00040
kernel: ACPI: SPCR 00000000df62f140 00050 (v01 HP     SPCRRBSU 00000001   <D2>? 0000162E)
kernel: ACPI: MCFG 00000000df62f1c0 0003C (v01 HP     ProLiant 00000001      00000000)
kernel: ACPI: HPET 00000000df62f200 00038 (v01 HP     ProLiant 00000002   <D2>? 0000162E)
kernel: ACPI: FFFF 00000000df62f240 00064 (v02 HP     ProLiant 00000002   <D2>? 0000162E)
kernel: ACPI: SPMI 00000000df62f2c0 00040 (v05 HP     ProLiant 00000001   <D2>? 0000162E)
kernel: ACPI: ERST 00000000df62f300 001D0 (v01 HP     ProLiant 00000001   <D2>? 0000162E)
kernel: ACPI: APIC 00000000df62f500 0015E (v01 HP     ProLiant 00000002      00000000)
kernel: ACPI: SRAT 00000000df62f680 00570 (v01 HP     Proliant 00000001   <D2>? 0000162E)
kernel: ACPI: FFFF 00000000df62fc00 00176 (v01 HP     ProLiant 00000001   <D2>? 0000162E)
kernel: ACPI: BERT 00000000df62fd80 00030 (v01 HP     ProLiant 00000001   <D2>? 0000162E)
kernel: ACPI: HEST 00000000df62fdc0 000BC (v01 HP     ProLiant 00000001   <D2>? 0000162E)
kernel: ACPI: DMAR 00000000df62fe80 0011C (v01 HP     ProLiant 00000001   <D2>? 0000162E)
kernel: ACPI: SSDT 00000000df632280 00125 (v03     HP  CRSPCI0 00000002   HP 00000001)
kernel: ACPI: SSDT 00000000df6323c0 00255 (v03     HP  riser1a 00000002 INTL 20061109)
kernel: ACPI: SSDT 00000000df632640 001B6 (v03     HP  riser2d 00000002 INTL 20061109)
kernel: ACPI: SSDT 00000000df632800 00377 (v01     HP     pmab 00000001 INTL 20090625)
kernel: ACPI: SSDT 00000000df632b80 03444 (v01  INTEL PPM RCM  00000001 INTL 20061109)
kernel: ACPI: Local APIC address 0xfee00000
kernel: SRAT: PXM 0 -> APIC 0x00 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x01 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x02 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x03 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x04 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x05 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x10 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x11 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x12 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x13 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x14 -> Node 0
kernel: SRAT: PXM 0 -> APIC 0x15 -> Node 0
kernel: SRAT: PXM 1 -> APIC 0x20 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x21 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x22 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x23 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x24 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x25 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x30 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x31 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x32 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x33 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x34 -> Node 1
kernel: SRAT: PXM 1 -> APIC 0x35 -> Node 1
kernel: SRAT: Node 0 PXM 0 [mem 0x00000000-0xdfffffff]
kernel: SRAT: Node 0 PXM 0 [mem 0x100000000-0x19fffffff]
kernel: SRAT: Node 1 PXM 1 [mem 0x1a0000000-0x31fffffff]
kernel: NUMA: Node 0 [mem 0x00000000-0xdfffffff] + [mem 0x100000000-0x19fffffff] -> [mem 0x00000000-0x19fffffff]
kernel: Initmem setup node 0 [mem 0x00000000-0x19fffffff]
kernel:  NODE_DATA [mem 0x19fffc000-0x19fffffff]
kernel: Initmem setup node 1 [mem 0x1a0000000-0x31fffefff]
kernel:  NODE_DATA [mem 0x31fffb000-0x31fffefff]
kernel: [ffffea0005b00000-ffffea0005bfffff] potential offnode page_structs
kernel: [ffffea0000000000-ffffea0005bfffff] PMD -> [ffff880199e00000-ffff88019f3fffff] on node 0
kernel: [ffffea0005c00000-ffffea000affffff] PMD -> [ffff880319600000-ffff88031e9fffff] on node 1
kernel: Zone ranges:
kernel:  DMA      [mem 0x00010000-0x00ffffff]
kernel:  DMA32    [mem 0x01000000-0xffffffff]
kernel:  Normal   [mem 0x100000000-0x31fffefff]
kernel: Movable zone start for each node
kernel: Early memory node ranges
kernel:  node   0: [mem 0x00010000-0x0009efff]
kernel:  node   0: [mem 0x00100000-0xdf62efff]
kernel:  node   0: [mem 0xdf63c000-0xdf63cfff]
kernel:  node   0: [mem 0x100000000-0x19fffffff]
kernel:  node   1: [mem 0x1a0000000-0x31fffefff]
kernel: On node 0 totalpages: 1570239
kernel:  DMA zone: 56 pages used for memmap
kernel:  DMA zone: 6 pages reserved
kernel:  DMA zone: 3921 pages, LIFO batch:0
kernel:  DMA32 zone: 14280 pages used for memmap
kernel:  DMA32 zone: 896616 pages, LIFO batch:31
kernel:  Normal zone: 8960 pages used for memmap
kernel:  Normal zone: 646400 pages, LIFO batch:31
kernel: On node 1 totalpages: 1572863
kernel:  Normal zone: 21504 pages used for memmap
kernel:  Normal zone: 1551359 pages, LIFO batch:31
kernel: ACPI: PM-Timer IO Port: 0x908
kernel: ACPI: Local APIC address 0xfee00000
kernel: ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
kernel: ACPI: LAPIC (acpi_id[0x10] lapic_id[0x20] enabled)
kernel: ACPI: LAPIC (acpi_id[0x08] lapic_id[0x10] enabled)
kernel: ACPI: LAPIC (acpi_id[0x18] lapic_id[0x30] enabled)
kernel: ACPI: LAPIC (acpi_id[0x04] lapic_id[0x04] enabled)
kernel: ACPI: LAPIC (acpi_id[0x14] lapic_id[0x24] enabled)
kernel: ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x14] enabled)
kernel: ACPI: LAPIC (acpi_id[0x1c] lapic_id[0x34] enabled)
kernel: ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
kernel: ACPI: LAPIC (acpi_id[0x12] lapic_id[0x22] enabled)
kernel: ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x12] enabled)
kernel: ACPI: LAPIC (acpi_id[0x1a] lapic_id[0x32] enabled)
kernel: ACPI: LAPIC (acpi_id[0x06] lapic_id[0x06] disabled)
kernel: ACPI: LAPIC (acpi_id[0x16] lapic_id[0x26] disabled)
kernel: ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x16] disabled)
kernel: ACPI: LAPIC (acpi_id[0x1e] lapic_id[0x36] disabled)
kernel: ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
kernel: ACPI: LAPIC (acpi_id[0x11] lapic_id[0x21] enabled)
kernel: ACPI: LAPIC (acpi_id[0x09] lapic_id[0x11] enabled)
kernel: ACPI: LAPIC (acpi_id[0x19] lapic_id[0x31] enabled)
kernel: ACPI: LAPIC (acpi_id[0x05] lapic_id[0x05] enabled)
kernel: ACPI: LAPIC (acpi_id[0x15] lapic_id[0x25] enabled)
kernel: ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x15] enabled)
kernel: ACPI: LAPIC (acpi_id[0x1d] lapic_id[0x35] enabled)
kernel: ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
kernel: ACPI: LAPIC (acpi_id[0x13] lapic_id[0x23] enabled)
kernel: ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x13] enabled)
kernel: ACPI: LAPIC (acpi_id[0x1b] lapic_id[0x33] enabled)
kernel: ACPI: LAPIC (acpi_id[0x07] lapic_id[0x07] disabled)
kernel: ACPI: LAPIC (acpi_id[0x17] lapic_id[0x27] disabled)
kernel: ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x17] disabled)
kernel: ACPI: LAPIC (acpi_id[0x1f] lapic_id[0x37] disabled)
kernel: ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
kernel: ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
kernel: IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
kernel: ACPI: IOAPIC (id[0x00] address[0xfec80000] gsi_base[24])
kernel: IOAPIC[1]: apic_id 0, version 32, address 0xfec80000, GSI 24-47
kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 high edge)
kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
kernel: ACPI: IRQ0 used by override.
kernel: ACPI: IRQ2 used by override.
kernel: ACPI: IRQ9 used by override.
kernel: Using ACPI (MADT) for SMP configuration information
kernel: ACPI: HPET id: 0x8086a201 base: 0xfed00000
kernel: smpboot: Allowing 32 CPUs, 8 hotplug CPUs
kernel: nr_irqs_gsi: 64
kernel: e820: [mem 0xe4000000-0xfebfffff] available for PCI devices
kernel: setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:32 nr_node_ids:2
kernel: PERCPU: Embedded 26 pages/cpu @ffff88019fc00000 s76672 r8192 d21632 u131072
kernel: pcpu-alloc: s76672 r8192 d21632 u131072 alloc=1*2097152
kernel: pcpu-alloc: [0] 00 02 04 06 08 10 12 14 16 18 20 22 24 26 28 30
kernel: pcpu-alloc: [1] 01 03 05 07 09 11 13 15 17 19 21 23 25 27 29 31
kernel: Built 2 zonelists in Zone order, mobility grouping on.  Total pages: 3098296
kernel: Policy zone: Normal
kernel: Kernel command line: ro root=LABEL=/ nofb text
kernel: PID hash table entries: 4096 (order: 3, 32768 bytes)
kernel: __ex_table already sorted, skipping sort
kernel: Checking aperture...
kernel: No AGP bridge found
kernel: Memory: 12318972k/13107196k available (3154k kernel code, 534788k absent, 253436k reserved, 1795k data, 540k init)
kernel: Hierarchical RCU implementation.
kernel:   CONFIG_RCU_FANOUT set to non-default value of 32
kernel: NR_IRQS:4352 nr_irqs:1344 16
kernel: Extended CMOS year: 2000
kernel: Console: colour VGA+ 80x25
kernel: console [tty0] enabled
kernel: hpet clockevent registered
kernel: tsc: Fast TSC calibration using PIT
kernel: tsc: Detected 2932.601 MHz processor
kernel: Calibrating delay loop (skipped), value calculated using timer frequency.. 5865.20 BogoMIPS (lpj=2932601)
kernel: pid_max: default: 32768 minimum: 301
kernel: Security Framework initialized
kernel: Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
kernel: Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
kernel: Mount-cache hash table entries: 256
kernel: CPU: Physical Processor ID: 0
kernel: CPU: Processor Core ID: 0
kernel: mce: CPU supports 9 MCE banks
kernel: CPU0: Thermal monitoring enabled (TM1)
2013-10-04T01:37:23+02:00 <kern.info> scotty1 kernel: process: using mwait in idle threads
kernel: Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
kernel: Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
kernel: tlb_flushall_shift is 0x6
kernel: ACPI: Core revision 20120711
kernel: Switched APIC routing to physical flat.
kernel: ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
kernel: smpboot: CPU0: Intel(R) Xeon(R) CPU           X5670  @ 2.93GHz stepping 02
kernel: Performance Events: PEBS fmt1+, 16-deep LBR, Westmere events, Broken BIOS detected, complain to your hardware vendor.
2013-10-04T01:37:23+02:00 <kern.err> scotty1 kernel: [Firmware Bug]: the BIOS has corrupted hw-PMU resources (MSR 38d is 330)
kernel: Intel PMU driver.
kernel: perf_event_intel: CPUID marked event: 'bus cycles' unavailable
kernel: ... version:                3
kernel: ... bit width:              48
kernel: ... generic registers:      4
kernel: ... value mask:             0000ffffffffffff
kernel: ... max period:             000000007fffffff
kernel: ... fixed-purpose events:   3
kernel: ... event mask:             000000070000000f
kernel: smpboot: Booting Node   1, Processors  #1 OK
kernel: smpboot: Booting Node   0, Processors  #2 OK
kernel: smpboot: Booting Node   1, Processors  #3 OK
kernel: smpboot: Booting Node   0, Processors  #4 OK
kernel: smpboot: Booting Node   1, Processors  #5 OK
kernel: smpboot: Booting Node   0, Processors  #6 OK
kernel: smpboot: Booting Node   1, Processors  #7 OK
kernel: smpboot: Booting Node   0, Processors  #8 OK
kernel: smpboot: Booting Node   1, Processors  #9 OK
kernel: smpboot: Booting Node   0, Processors  #10 OK
kernel: smpboot: Booting Node   1, Processors  #11 OK
kernel: smpboot: Booting Node   0, Processors  #12 OK
kernel: smpboot: Booting Node   1, Processors  #13 OK
kernel: smpboot: Booting Node   0, Processors  #14 OK
kernel: smpboot: Booting Node   1, Processors  #15 OK
kernel: smpboot: Booting Node   0, Processors  #16 OK
kernel: smpboot: Booting Node   1, Processors  #17 OK
kernel: smpboot: Booting Node   0, Processors  #18 OK
kernel: smpboot: Booting Node   1, Processors  #19 OK
kernel: smpboot: Booting Node   0, Processors  #20 OK
kernel: smpboot: Booting Node   1, Processors  #21 OK
kernel: smpboot: Booting Node   0, Processors  #22 OK
kernel: smpboot: Booting Node   1, Processors  #23
kernel: Brought up 24 CPUs
kernel: smpboot: Total of 24 processors activated (140755.15 BogoMIPS)
kernel: NET: Registered protocol family 16
kernel: ACPI: bus type pci registered
kernel: PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xe0000000-0xe3ffffff] (base 0xe0000000)
kernel: PCI: MMCONFIG at [mem 0xe0000000-0xe3ffffff] reserved in E820
kernel: PCI: Using configuration type 1 for base access
kernel: PCI: HP ProLiant DL380 detected, enabling pci=bfsort.
kernel: bio: create slab <bio-0> at 0
kernel: ACPI: Added _OSI(Module Device)
kernel: ACPI: Added _OSI(Processor Device)
kernel: ACPI: Added _OSI(3.0 _SCP Extensions)
kernel: ACPI: Added _OSI(Processor Aggregator Device)
kernel: ACPI: EC: Look up EC in DSDT
kernel: ACPI Error: Field [CDW3] at 96 exceeds Buffer [NULL] size 64 (bits) (20120711/dsopcode-236)
kernel: ACPI Error: Method parse/execution failed [\_SB_._OSC] (Node ffff88031905c2b8), AE_AML_BUFFER_LIMIT (20120711/psparse-536)
kernel: ACPI: Interpreter enabled
kernel: ACPI: (supports S0 S5)
kernel: ACPI: Using IOAPIC for interrupt routing
kernel: PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
kernel: ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-19])
kernel: pci_root PNP0A08:00: host bridge window expanded to [mem 0xfed00000-0xfed44fff]; [mem 0xfed00000-0xfed44fff] ignored
kernel: PCI host bridge to bus 0000:00
kernel: pci_bus 0000:00: busn_res: [bus 00-19] is inserted under domain [bus 00-ff]
kernel: pci_bus 0000:00: root bus resource [bus 00-19]
kernel: pci_bus 0000:00: root bus resource [mem 0xe7000000-0xfbffffff]
kernel: pci_bus 0000:00: root bus resource [io  0x1000-0x5fff]
kernel: pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
kernel: pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7]
kernel: pci_bus 0000:00: root bus resource [io  0x0d00-0x0fff]
kernel: pci_bus 0000:00: root bus resource [mem 0xfed00000-0xfed44fff]
kernel: pci_bus 0000:00: root bus resource [io  0x03b0-0x03bb]
kernel: pci_bus 0000:00: root bus resource [io  0x03c0-0x03df]
kernel: pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
kernel: pci 0000:00:00.0: [8086:3406] type 00 class 0x060000
kernel: pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:01.0: [8086:3408] type 01 class 0x060400
kernel: pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:02.0: [8086:3409] type 01 class 0x060400
kernel: pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:03.0: [8086:340a] type 01 class 0x060400
kernel: pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:04.0: [8086:340b] type 01 class 0x060400
kernel: pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:05.0: [8086:340c] type 01 class 0x060400
kernel: pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:06.0: [8086:340d] type 01 class 0x060400
kernel: pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:07.0: [8086:340e] type 01 class 0x060400
kernel: pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:08.0: [8086:340f] type 01 class 0x060400
kernel: pci 0000:00:08.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:09.0: [8086:3410] type 01 class 0x060400
kernel: pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:0a.0: [8086:3411] type 01 class 0x060400
kernel: pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:0d.0: [8086:343a] type 00 class 0x060000
kernel: pci 0000:00:0d.1: [8086:343b] type 00 class 0x060000
kernel: pci 0000:00:0d.2: [8086:343c] type 00 class 0x060000
kernel: pci 0000:00:0d.3: [8086:343d] type 00 class 0x060000
kernel: pci 0000:00:0d.4: [8086:3418] type 00 class 0x060000
kernel: pci 0000:00:0d.5: [8086:3419] type 00 class 0x060000
kernel: pci 0000:00:0d.6: [8086:341a] type 00 class 0x060000
kernel: pci 0000:00:0e.0: [8086:341c] type 00 class 0x060000
kernel: pci 0000:00:0e.1: [8086:341d] type 00 class 0x060000
kernel: pci 0000:00:0e.2: [8086:341e] type 00 class 0x060000
kernel: pci 0000:00:0e.3: [8086:341f] type 00 class 0x060000
kernel: pci 0000:00:0e.4: [8086:3439] type 00 class 0x060000
kernel: pci 0000:00:14.0: [8086:342e] type 00 class 0x080000
kernel: pci 0000:00:14.1: [8086:3422] type 00 class 0x080000
kernel: pci 0000:00:14.2: [8086:3423] type 00 class 0x080000
kernel: pci 0000:00:1c.0: [8086:3a40] type 01 class 0x060400
kernel: pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:1c.2: [8086:3a44] type 01 class 0x060400
kernel: pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:1d.0: [8086:3a34] type 00 class 0x0c0300
kernel: pci 0000:00:1d.0: reg 20: [io  0x1000-0x101f]
kernel: pci 0000:00:1d.1: [8086:3a35] type 00 class 0x0c0300
kernel: pci 0000:00:1d.1: reg 20: [io  0x1020-0x103f]
kernel: pci 0000:00:1d.2: [8086:3a36] type 00 class 0x0c0300
kernel: pci 0000:00:1d.2: reg 20: [io  0x1040-0x105f]
kernel: pci 0000:00:1d.3: [8086:3a39] type 00 class 0x0c0300
kernel: pci 0000:00:1d.3: reg 20: [io  0x1060-0x107f]
kernel: pci 0000:00:1d.7: [8086:3a3a] type 00 class 0x0c0320
kernel: pci 0000:00:1d.7: reg 10: [mem 0xf1df0000-0xf1df03ff]
kernel: pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
kernel: pci 0000:00:1f.0: [8086:3a18] type 00 class 0x060100
kernel: pci 0000:00:1f.2: [8086:3a20] type 00 class 0x01018f
kernel: pci 0000:00:1f.2: reg 10: [io  0x1080-0x1087]
kernel: pci 0000:00:1f.2: reg 14: [io  0x1088-0x108b]
kernel: pci 0000:00:1f.2: reg 18: [io  0x1090-0x1097]
kernel: pci 0000:00:1f.2: reg 1c: [io  0x1098-0x109b]
kernel: pci 0000:00:1f.2: reg 20: [io  0x10a0-0x10af]
kernel: pci 0000:00:1f.2: reg 24: [io  0x10b0-0x10bf]
kernel: pci_bus 0000:04: busn_res: [bus 04] is inserted under [bus 00-19]
kernel: pci 0000:04:00.0: [103c:323a] type 00 class 0x010400
kernel: pci 0000:04:00.0: reg 10: [mem 0xfbc00000-0xfbffffff 64bit]
kernel: pci 0000:04:00.0: reg 18: [mem 0xfbbf0000-0xfbbf0fff 64bit]
kernel: pci 0000:04:00.0: reg 20: [io  0x4000-0x40ff]
kernel: pci 0000:04:00.0: reg 30: [mem 0x00000000-0x0007ffff pref]
kernel: pci 0000:04:00.0: supports D1
kernel: pci 0000:04:00.0: PME# supported from D0
kernel: pci 0000:00:01.0: PCI bridge to [bus 04]
kernel: pci 0000:00:01.0:   bridge window [io  0x4000-0x4fff]
kernel: pci 0000:00:01.0:   bridge window [mem 0xfbb00000-0xfbffffff]
kernel: pci_bus 0000:05: busn_res: [bus 05] is inserted under [bus 00-19]
kernel: pci 0000:00:02.0: PCI bridge to [bus 05]
kernel: pci_bus 0000:10: busn_res: [bus 10-12] is inserted under [bus 00-19]
kernel: pci 0000:10:00.0: [8086:10fb] type 00 class 0x020000
kernel: pci 0000:10:00.0: reg 10: [mem 0xf1c80000-0xf1cfffff 64bit pref]
kernel: pci 0000:10:00.0: reg 18: [io  0x5000-0x501f]
kernel: pci 0000:10:00.0: reg 20: [mem 0xf1c70000-0xf1c73fff 64bit pref]
kernel: pci 0000:10:00.0: PME# supported from D0 D3hot
kernel: pci 0000:10:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.1: [8086:10fb] type 00 class 0x020000
kernel: pci 0000:10:00.1: reg 10: [mem 0xf1b80000-0xf1bfffff 64bit pref]
kernel: pci 0000:10:00.1: reg 18: [io  0x5020-0x503f]
kernel: pci 0000:10:00.1: reg 20: [mem 0xf1b70000-0xf1b73fff 64bit pref]
kernel: pci 0000:10:00.1: PME# supported from D0 D3hot
kernel: pci 0000:10:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:00:03.0: PCI bridge to [bus 10-12]
kernel: pci 0000:00:03.0:   bridge window [io  0x5000-0x5fff]
kernel: pci 0000:00:03.0:   bridge window [mem 0xf1b00000-0xf1cfffff 64bit pref]
kernel: pci_bus 0000:13: busn_res: [bus 13] is inserted under [bus 00-19]
kernel: pci 0000:00:04.0: PCI bridge to [bus 13]
kernel: pci_bus 0000:14: busn_res: [bus 14-16] is inserted under [bus 00-19]
kernel: pci 0000:00:05.0: PCI bridge to [bus 14-16]
kernel: pci_bus 0000:17: busn_res: [bus 17-19] is inserted under [bus 00-19]
kernel: pci 0000:00:06.0: PCI bridge to [bus 17-19]
kernel: pci_bus 0000:0d: busn_res: [bus 0d-0f] is inserted under [bus 00-19]
kernel: pci 0000:00:07.0: PCI bridge to [bus 0d-0f]
kernel: pci_bus 0000:0a: busn_res: [bus 0a-0c] is inserted under [bus 00-19]
kernel: pci 0000:00:08.0: PCI bridge to [bus 0a-0c]
kernel: pci_bus 0000:07: busn_res: [bus 07-09] is inserted under [bus 00-19]
kernel: pci 0000:00:09.0: PCI bridge to [bus 07-09]
kernel: pci_bus 0000:06: busn_res: [bus 06] is inserted under [bus 00-19]
kernel: pci 0000:00:0a.0: PCI bridge to [bus 06]
kernel: pci_bus 0000:02: busn_res: [bus 02] is inserted under [bus 00-19]
kernel: pci 0000:02:00.0: [14e4:1639] type 00 class 0x020000
kernel: pci 0000:02:00.0: reg 10: [mem 0xf4000000-0xf5ffffff 64bit]
kernel: pci 0000:02:00.0: reg 30: [mem 0x00000000-0x0000ffff pref]
kernel: pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:02:00.1: [14e4:1639] type 00 class 0x020000
kernel: pci 0000:02:00.1: reg 10: [mem 0xf2000000-0xf3ffffff 64bit]
kernel: pci 0000:02:00.1: reg 30: [mem 0x00000000-0x0000ffff pref]
kernel: pci 0000:02:00.1: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:1c.0: PCI bridge to [bus 02]
kernel: pci 0000:00:1c.0:   bridge window [mem 0xf2000000-0xf5ffffff]
kernel: pci_bus 0000:03: busn_res: [bus 03] is inserted under [bus 00-19]
kernel: pci 0000:03:00.0: [14e4:1639] type 00 class 0x020000
kernel: pci 0000:03:00.0: reg 10: [mem 0xf8000000-0xf9ffffff 64bit]
kernel: pci 0000:03:00.0: reg 30: [mem 0x00000000-0x0000ffff pref]
kernel: pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:03:00.1: [14e4:1639] type 00 class 0x020000
kernel: pci 0000:03:00.1: reg 10: [mem 0xf6000000-0xf7ffffff 64bit]
kernel: pci 0000:03:00.1: reg 30: [mem 0x00000000-0x0000ffff pref]
kernel: pci 0000:03:00.1: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:1c.2: PCI bridge to [bus 03]
kernel: pci 0000:00:1c.2:   bridge window [mem 0xf6000000-0xf9ffffff]
kernel: pci_bus 0000:01: busn_res: [bus 01] is inserted under [bus 00-19]
kernel: pci 0000:01:03.0: [1002:515e] type 00 class 0x030000
kernel: pci 0000:01:03.0: reg 10: [mem 0xe8000000-0xefffffff pref]
kernel: pci 0000:01:03.0: reg 14: [io  0x3000-0x30ff]
kernel: pci 0000:01:03.0: reg 18: [mem 0xf1ff0000-0xf1ffffff]
kernel: pci 0000:01:03.0: reg 30: [mem 0x00000000-0x0001ffff pref]
kernel: pci 0000:01:03.0: supports D1 D2
kernel: pci 0000:01:04.0: [0e11:b203] type 00 class 0x088000
kernel: pci 0000:01:04.0: reg 10: [io  0x2800-0x28ff]
kernel: pci 0000:01:04.0: reg 14: [mem 0xf1fe0000-0xf1fe01ff]
kernel: pci 0000:01:04.0: PME# supported from D0 D3hot D3cold
kernel: pci 0000:01:04.2: [0e11:b204] type 00 class 0x088000
kernel: pci 0000:01:04.2: reg 10: [io  0x3400-0x34ff]
kernel: pci 0000:01:04.2: reg 14: [mem 0xf1fd0000-0xf1fd07ff]
kernel: pci 0000:01:04.2: reg 18: [mem 0xf1fc0000-0xf1fc3fff]
kernel: pci 0000:01:04.2: reg 1c: [mem 0xf1f00000-0xf1f7ffff]
kernel: pci 0000:01:04.2: reg 30: [mem 0x00000000-0x0000ffff pref]
kernel: pci 0000:01:04.2: PME# supported from D0 D3hot D3cold
kernel: pci 0000:01:04.4: [103c:3300] type 00 class 0x0c0300
kernel: pci 0000:01:04.4: reg 20: [io  0x3800-0x381f]
kernel: pci 0000:01:04.4: PME# supported from D0 D3hot D3cold
kernel: pci 0000:01:04.6: [103c:3302] type 00 class 0x0c0701
kernel: pci 0000:01:04.6: reg 10: [mem 0xf1ef0000-0xf1ef00ff]
kernel: pci 0000:01:04.6: PME# supported from D0 D3hot D3cold
kernel: pci 0000:00:1e.0: PCI bridge to [bus 01] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [io  0x2000-0x3fff]
kernel: pci 0000:00:1e.0:   bridge window [mem 0xf1e00000-0xf1ffffff]
kernel: pci 0000:00:1e.0:   bridge window [mem 0xe8000000-0xefffffff 64bit pref]
kernel: pci 0000:00:1e.0:   bridge window [mem 0xe7000000-0xfbffffff] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [io  0x1000-0x5fff] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [io  0x0000-0x03af] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [io  0x03e0-0x0cf7] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [io  0x0d00-0x0fff] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [mem 0xfed00000-0xfed44fff] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [io  0x03b0-0x03bb] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [io  0x03c0-0x03df] (subtractive decode)
kernel: pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.IP2P._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.IPT1._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.IPT3._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT01._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT03._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT04._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT05._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT06._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT07._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT08._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT09._PRT]
kernel: ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PT0A._PRT]
kernel: pci0000:00: ACPI _OSC support notification failed, disabling PCIe ASPM
kernel: pci0000:00: Unable to request _OSC control (_OSC support mask: 0x08)
kernel: ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *7 10 11)
kernel: ACPI: PCI Interrupt Link [LNKB] (IRQs 5 7 10 *11)
kernel: ACPI: PCI Interrupt Link [LNKC] (IRQs *5 7 10 11)
kernel: ACPI: PCI Interrupt Link [LNKD] (IRQs 5 7 *10 11)
kernel: ACPI: PCI Interrupt Link [LNKE] (IRQs *5 7 10 11)
kernel: ACPI: PCI Interrupt Link [LNKF] (IRQs 5 7 *10 11)
kernel: ACPI: PCI Interrupt Link [LNKG] (IRQs 5 7 *10 11)
kernel: ACPI: PCI Interrupt Link [LNKH] (IRQs 5 *7 10 11)
kernel: vgaarb: device added: PCI:0000:01:03.0,decodes=io+mem,owns=io+mem,locks=none
kernel: vgaarb: loaded
kernel: vgaarb: bridge control possible 0000:01:03.0
kernel: ACPI: bus type usb registered
kernel: usbcore: registered new interface driver usbfs
kernel: usbcore: registered new interface driver hub
kernel: usbcore: registered new device driver usb
kernel: PCI: Using ACPI for IRQ routing
kernel: PCI: Discovered peer bus 3e
kernel: PCI: root bus 3e: using default resources
kernel: PCI: Probing PCI hardware (bus 3e)
kernel: PCI host bridge to bus 0000:3e
kernel: pci_bus 0000:3e: root bus resource [io  0x0000-0xffff]
kernel: pci_bus 0000:3e: root bus resource [mem 0x00000000-0xffffffffff]
kernel: pci_bus 0000:3e: No busn resource found for root bus, will use [bus 3e-ff]
kernel: pci_bus 0000:3e: busn_res: [bus 3e-ff] is inserted under domain [bus 00-ff]
kernel: pci 0000:3e:00.0: [8086:2c70] type 00 class 0x060000
kernel: pci 0000:3e:00.1: [8086:2d81] type 00 class 0x060000
kernel: pci 0000:3e:02.0: [8086:2d90] type 00 class 0x060000
kernel: pci 0000:3e:02.1: [8086:2d91] type 00 class 0x060000
kernel: pci 0000:3e:02.2: [8086:2d92] type 00 class 0x060000
kernel: pci 0000:3e:02.3: [8086:2d93] type 00 class 0x060000
kernel: pci 0000:3e:02.4: [8086:2d94] type 00 class 0x060000
kernel: pci 0000:3e:02.5: [8086:2d95] type 00 class 0x060000
kernel: pci 0000:3e:03.0: [8086:2d98] type 00 class 0x060000
kernel: pci 0000:3e:03.1: [8086:2d99] type 00 class 0x060000
kernel: pci 0000:3e:03.2: [8086:2d9a] type 00 class 0x060000
kernel: pci 0000:3e:03.4: [8086:2d9c] type 00 class 0x060000
kernel: pci 0000:3e:04.0: [8086:2da0] type 00 class 0x060000
kernel: pci 0000:3e:04.1: [8086:2da1] type 00 class 0x060000
kernel: pci 0000:3e:04.2: [8086:2da2] type 00 class 0x060000
kernel: pci 0000:3e:04.3: [8086:2da3] type 00 class 0x060000
kernel: pci 0000:3e:05.0: [8086:2da8] type 00 class 0x060000
kernel: pci 0000:3e:05.1: [8086:2da9] type 00 class 0x060000
kernel: pci 0000:3e:05.2: [8086:2daa] type 00 class 0x060000
kernel: pci 0000:3e:05.3: [8086:2dab] type 00 class 0x060000
kernel: pci 0000:3e:06.0: [8086:2db0] type 00 class 0x060000
kernel: pci 0000:3e:06.1: [8086:2db1] type 00 class 0x060000
kernel: pci 0000:3e:06.2: [8086:2db2] type 00 class 0x060000
kernel: pci 0000:3e:06.3: [8086:2db3] type 00 class 0x060000
kernel: pci_bus 0000:3e: busn_res: [bus 3e-ff] end is updated to 3e
kernel: PCI: Discovered peer bus 3f
kernel: PCI: root bus 3f: using default resources
kernel: PCI: Probing PCI hardware (bus 3f)
kernel: PCI host bridge to bus 0000:3f
kernel: pci_bus 0000:3f: root bus resource [io  0x0000-0xffff]
kernel: pci_bus 0000:3f: root bus resource [mem 0x00000000-0xffffffffff]
kernel: pci_bus 0000:3f: No busn resource found for root bus, will use [bus 3f-ff]
kernel: pci_bus 0000:3f: busn_res: [bus 3f-ff] is inserted under domain [bus 00-ff]
kernel: pci 0000:3f:00.0: [8086:2c70] type 00 class 0x060000
kernel: pci 0000:3f:00.1: [8086:2d81] type 00 class 0x060000
kernel: pci 0000:3f:02.0: [8086:2d90] type 00 class 0x060000
kernel: pci 0000:3f:02.1: [8086:2d91] type 00 class 0x060000
kernel: pci 0000:3f:02.2: [8086:2d92] type 00 class 0x060000
kernel: pci 0000:3f:02.3: [8086:2d93] type 00 class 0x060000
kernel: pci 0000:3f:02.4: [8086:2d94] type 00 class 0x060000
kernel: pci 0000:3f:02.5: [8086:2d95] type 00 class 0x060000
kernel: pci 0000:3f:03.0: [8086:2d98] type 00 class 0x060000
kernel: pci 0000:3f:03.1: [8086:2d99] type 00 class 0x060000
kernel: pci 0000:3f:03.2: [8086:2d9a] type 00 class 0x060000
kernel: pci 0000:3f:03.4: [8086:2d9c] type 00 class 0x060000
kernel: pci 0000:3f:04.0: [8086:2da0] type 00 class 0x060000
kernel: pci 0000:3f:04.1: [8086:2da1] type 00 class 0x060000
kernel: pci 0000:3f:04.2: [8086:2da2] type 00 class 0x060000
kernel: pci 0000:3f:04.3: [8086:2da3] type 00 class 0x060000
kernel: pci 0000:3f:05.0: [8086:2da8] type 00 class 0x060000
kernel: pci 0000:3f:05.1: [8086:2da9] type 00 class 0x060000
kernel: pci 0000:3f:05.2: [8086:2daa] type 00 class 0x060000
kernel: pci 0000:3f:05.3: [8086:2dab] type 00 class 0x060000
kernel: pci 0000:3f:06.0: [8086:2db0] type 00 class 0x060000
kernel: pci 0000:3f:06.1: [8086:2db1] type 00 class 0x060000
kernel: pci 0000:3f:06.2: [8086:2db2] type 00 class 0x060000
kernel: pci 0000:3f:06.3: [8086:2db3] type 00 class 0x060000
kernel: pci_bus 0000:3f: busn_res: [bus 3f-ff] end is updated to 3f
kernel: PCI: pci_cache_line_size set to 64 bytes
kernel: e820: reserve RAM buffer [mem 0x0009f400-0x0009ffff]
kernel: e820: reserve RAM buffer [mem 0xdf62f000-0xdfffffff]
kernel: e820: reserve RAM buffer [mem 0xdf63d000-0xdfffffff]
kernel: e820: reserve RAM buffer [mem 0x31ffff000-0x31fffffff]
kernel: NetLabel: Initializing
kernel: NetLabel:  domain hash size = 128
kernel: NetLabel:  protocols = UNLABELED CIPSOv4
kernel: NetLabel:  unlabeled traffic allowed by default
kernel: hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
kernel: hpet0: 4 comparators, 64-bit 14.318180 MHz counter
kernel: Switching to clocksource hpet
kernel: pnp: PnP ACPI init
kernel: ACPI: bus type pnp registered
kernel: pnp 00:00: [bus 00-19]
kernel: pnp 00:00: [mem 0xe7000000-0xfbffffff window]
kernel: pnp 00:00: [io  0x1000-0x5fff window]
kernel: pnp 00:00: [io  0x0000-0x03af window]
kernel: pnp 00:00: [io  0x03e0-0x0cf7 window]
kernel: pnp 00:00: [io  0x0d00-0x0fff window]
kernel: pnp 00:00: [mem 0xfed00000-0xfed03fff window]
kernel: pnp 00:00: [mem 0xfed00000-0xfed44fff window]
kernel: pnp 00:00: [io  0x03b0-0x03bb window]
kernel: pnp 00:00: [io  0x03c0-0x03df window]
kernel: pnp 00:00: [mem 0x000a0000-0x000bffff window]
kernel: pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
kernel: pnp 00:01: [io  0x0070-0x0077]
kernel: pnp 00:01: [io  0x0408-0x040f]
kernel: pnp 00:01: [io  0x04d0-0x04d1]
kernel: pnp 00:01: [io  0x0020-0x003f]
kernel: pnp 00:01: [io  0x00a0-0x00bf]
kernel: pnp 00:01: [io  0x0090-0x009f]
kernel: pnp 00:01: [io  0x0050-0x0053]
kernel: pnp 00:01: [io  0x0700-0x071f]
kernel: pnp 00:01: [io  0x0880-0x08ff]
kernel: pnp 00:01: [io  0x0900-0x097f]
kernel: pnp 00:01: [io  0x0010-0x001f]
kernel: pnp 00:01: [io  0x0c80-0x0c83]
kernel: pnp 00:01: [io  0x0cd4-0x0cd7]
kernel: pnp 00:01: [io  0x0f50-0x0f58]
kernel: pnp 00:01: [io  0x00f0]
kernel: pnp 00:01: [io  0x0ca0-0x0ca1]
kernel: pnp 00:01: [io  0x0ca4-0x0ca5]
kernel: pnp 00:01: [mem 0xe0000000-0xe3ffffff]
kernel: pnp 00:01: [mem 0xfe000000-0xfebfffff]
kernel: pnp 00:01: [mem 0xe7ffe000-0xe7ffffff]
kernel: pnp 00:01: [mem 0x00000000-0xffffffffffffffff disabled]
kernel: pnp 00:01: [io  0x02f8-0x02ff]
kernel: system 00:01: [io  0x0408-0x040f] has been reserved
kernel: system 00:01: [io  0x04d0-0x04d1] has been reserved
kernel: system 00:01: [io  0x0700-0x071f] has been reserved
kernel: system 00:01: [io  0x0880-0x08ff] has been reserved
kernel: system 00:01: [io  0x0900-0x097f] has been reserved
kernel: system 00:01: [io  0x0c80-0x0c83] has been reserved
kernel: system 00:01: [io  0x0cd4-0x0cd7] has been reserved
kernel: system 00:01: [io  0x0f50-0x0f58] has been reserved
kernel: system 00:01: [io  0x0ca0-0x0ca1] has been reserved
kernel: system 00:01: [io  0x0ca4-0x0ca5] has been reserved
kernel: system 00:01: [io  0x02f8-0x02ff] has been reserved
kernel: system 00:01: [mem 0xe0000000-0xe3ffffff] has been reserved
kernel: system 00:01: [mem 0xfe000000-0xfebfffff] has been reserved
kernel: system 00:01: [mem 0xe7ffe000-0xe7ffffff] has been reserved
kernel: system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
kernel: pnp 00:02: [io  0x0ca2-0x0ca3]
kernel: pnp 00:02: Plug and Play ACPI device, IDs IPI0001 (active)
kernel: pnp 00:03: [mem 0xfed00000-0xfed003ff]
kernel: pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
kernel: pnp 00:04: [dma 7]
kernel: pnp 00:04: [io  0x0000-0x000f]
kernel: pnp 00:04: [io  0x0080-0x008f]
kernel: pnp 00:04: [io  0x00c0-0x00df]
kernel: pnp 00:04: Plug and Play ACPI device, IDs PNP0200 (active)
kernel: pnp 00:05: [io  0x0061]
kernel: pnp 00:05: Plug and Play ACPI device, IDs PNP0800 (active)
kernel: pnp 00:06: [io  0x0060]
kernel: pnp 00:06: [io  0x0064]
kernel: pnp 00:06: [irq 1]
kernel: pnp 00:06: Plug and Play ACPI device, IDs PNP0303 (active)
kernel: pnp 00:07: [irq 12]
kernel: pnp 00:07: Plug and Play ACPI device, IDs PNP0f13 PNP0f0e (active)
kernel: pnp 00:08: [io  0x002e-0x002f]
kernel: pnp 00:08: [io  0x0620-0x065f]
kernel: pnp 00:08: [io  0x0680-0x069f]
kernel: pnp 00:08: [io  0x0600-0x061f]
kernel: pnp 00:08: [io  0x0660-0x067f]
kernel: pnp 00:08: [io  0x0300-0x031f]
kernel: pnp 00:08: Plug and Play ACPI device, IDs PNP0a06 (active)
kernel: pnp 00:09: [irq 4]
kernel: pnp 00:09: [io  0x03f8-0x03ff]
kernel: pnp 00:09: Plug and Play ACPI device, IDs PNP0501 PNP0500 (active)
kernel: pnp 00:0a: [io  0x0070-0x0071]
kernel: pnp 00:0a: Plug and Play ACPI device, IDs PNP0b00 (active)
kernel: pnp: PnP ACPI: found 11 devices
kernel: ACPI: ACPI bus type pnp unregistered
kernel: pci 0000:00:03.0: bridge window [mem 0x00100000-0x000fffff] to [bus 10-12] add_size 400000
kernel: pci 0000:00:03.0: res[14]=[mem 0x00100000-0x000fffff] get_res_add_size add_size 400000
kernel: pci 0000:00:01.0: BAR 15: assigned [mem 0xe7000000-0xe70fffff pref]
kernel: pci 0000:00:03.0: BAR 14: assigned [mem 0xe7100000-0xe74fffff]
kernel: pci 0000:00:1c.0: BAR 15: assigned [mem 0xe7500000-0xe75fffff pref]
kernel: pci 0000:00:1c.2: BAR 15: assigned [mem 0xe7600000-0xe76fffff pref]
kernel: pci 0000:04:00.0: BAR 6: assigned [mem 0xe7000000-0xe707ffff pref]
kernel: pci 0000:00:01.0: PCI bridge to [bus 04]
kernel: pci 0000:00:01.0:   bridge window [io  0x4000-0x4fff]
kernel: pci 0000:00:01.0:   bridge window [mem 0xfbb00000-0xfbffffff]
kernel: pci 0000:00:01.0:   bridge window [mem 0xe7000000-0xe70fffff pref]
kernel: pci 0000:00:02.0: PCI bridge to [bus 05]
kernel: pci 0000:10:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: res[7]=[mem 0x00000000-0xffffffffffffffff 64bit] get_res_add_size add_size 100000
kernel: pci 0000:10:00.0: res[10]=[mem 0x00000000-0xffffffffffffffff 64bit] get_res_add_size add_size 100000
kernel: pci 0000:10:00.1: res[7]=[mem 0x00000000-0xffffffffffffffff 64bit] get_res_add_size add_size 100000
kernel: pci 0000:10:00.1: res[10]=[mem 0x00000000-0xffffffffffffffff 64bit] get_res_add_size add_size 100000
kernel: pci 0000:10:00.0: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: BAR 7: assigned [mem 0xe7100000-0xe71fffff 64bit]
kernel: pci 0000:10:00.0: reg 190: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.0: BAR 10: assigned [mem 0xe7200000-0xe72fffff 64bit]
kernel: pci 0000:10:00.1: reg 184: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.1: BAR 7: assigned [mem 0xe7300000-0xe73fffff 64bit]
kernel: pci 0000:10:00.1: reg 190: [mem 0x00000000-0x00003fff 64bit]
kernel: pci 0000:10:00.1: BAR 10: assigned [mem 0xe7400000-0xe74fffff 64bit]
kernel: pci 0000:00:03.0: PCI bridge to [bus 10-12]
kernel: pci 0000:00:03.0:   bridge window [io  0x5000-0x5fff]
kernel: pci 0000:00:03.0:   bridge window [mem 0xe7100000-0xe74fffff]
kernel: pci 0000:00:03.0:   bridge window [mem 0xf1b00000-0xf1cfffff 64bit pref]
kernel: pci 0000:00:04.0: PCI bridge to [bus 13]
kernel: pci 0000:00:05.0: PCI bridge to [bus 14-16]
kernel: pci 0000:00:06.0: PCI bridge to [bus 17-19]
kernel: pci 0000:00:07.0: PCI bridge to [bus 0d-0f]
kernel: pci 0000:00:08.0: PCI bridge to [bus 0a-0c]
kernel: pci 0000:00:09.0: PCI bridge to [bus 07-09]
kernel: pci 0000:00:0a.0: PCI bridge to [bus 06]
kernel: pci 0000:02:00.0: BAR 6: assigned [mem 0xe7500000-0xe750ffff pref]
kernel: pci 0000:02:00.1: BAR 6: assigned [mem 0xe7510000-0xe751ffff pref]
kernel: pci 0000:00:1c.0: PCI bridge to [bus 02]
kernel: pci 0000:00:1c.0:   bridge window [mem 0xf2000000-0xf5ffffff]
kernel: pci 0000:00:1c.0:   bridge window [mem 0xe7500000-0xe75fffff pref]
kernel: pci 0000:03:00.0: BAR 6: assigned [mem 0xe7600000-0xe760ffff pref]
kernel: pci 0000:03:00.1: BAR 6: assigned [mem 0xe7610000-0xe761ffff pref]
kernel: pci 0000:00:1c.2: PCI bridge to [bus 03]
kernel: pci 0000:00:1c.2:   bridge window [mem 0xf6000000-0xf9ffffff]
kernel: pci 0000:00:1c.2:   bridge window [mem 0xe7600000-0xe76fffff pref]
kernel: pci 0000:01:03.0: BAR 6: assigned [mem 0xf1e00000-0xf1e1ffff pref]
kernel: pci 0000:01:04.2: BAR 6: assigned [mem 0xf1e20000-0xf1e2ffff pref]
kernel: pci 0000:00:1e.0: PCI bridge to [bus 01]
kernel: pci 0000:00:1e.0:   bridge window [io  0x2000-0x3fff]
kernel: pci 0000:00:1e.0:   bridge window [mem 0xf1e00000-0xf1ffffff]
kernel: pci 0000:00:1e.0:   bridge window [mem 0xe8000000-0xefffffff 64bit pref]
kernel: pci 0000:00:1e.0: setting latency timer to 64
kernel: pci_bus 0000:00: resource 4 [mem 0xe7000000-0xfbffffff]
kernel: pci_bus 0000:00: resource 5 [io  0x1000-0x5fff]
kernel: pci_bus 0000:00: resource 6 [io  0x0000-0x03af]
kernel: pci_bus 0000:00: resource 7 [io  0x03e0-0x0cf7]
kernel: pci_bus 0000:00: resource 8 [io  0x0d00-0x0fff]
kernel: pci_bus 0000:00: resource 9 [mem 0xfed00000-0xfed44fff]
kernel: pci_bus 0000:00: resource 10 [io  0x03b0-0x03bb]
kernel: pci_bus 0000:00: resource 11 [io  0x03c0-0x03df]
kernel: pci_bus 0000:00: resource 12 [mem 0x000a0000-0x000bffff]
kernel: pci_bus 0000:04: resource 0 [io  0x4000-0x4fff]
kernel: pci_bus 0000:04: resource 1 [mem 0xfbb00000-0xfbffffff]
kernel: pci_bus 0000:04: resource 2 [mem 0xe7000000-0xe70fffff pref]
kernel: pci_bus 0000:10: resource 0 [io  0x5000-0x5fff]
kernel: pci_bus 0000:10: resource 1 [mem 0xe7100000-0xe74fffff]
kernel: pci_bus 0000:10: resource 2 [mem 0xf1b00000-0xf1cfffff 64bit pref]
kernel: pci_bus 0000:02: resource 1 [mem 0xf2000000-0xf5ffffff]
kernel: pci_bus 0000:02: resource 2 [mem 0xe7500000-0xe75fffff pref]
kernel: pci_bus 0000:03: resource 1 [mem 0xf6000000-0xf9ffffff]
kernel: pci_bus 0000:03: resource 2 [mem 0xe7600000-0xe76fffff pref]
kernel: pci_bus 0000:01: resource 0 [io  0x2000-0x3fff]
kernel: pci_bus 0000:01: resource 1 [mem 0xf1e00000-0xf1ffffff]
kernel: pci_bus 0000:01: resource 2 [mem 0xe8000000-0xefffffff 64bit pref]
kernel: pci_bus 0000:01: resource 4 [mem 0xe7000000-0xfbffffff]
kernel: pci_bus 0000:01: resource 5 [io  0x1000-0x5fff]
kernel: pci_bus 0000:01: resource 6 [io  0x0000-0x03af]
kernel: pci_bus 0000:01: resource 7 [io  0x03e0-0x0cf7]
kernel: pci_bus 0000:01: resource 8 [io  0x0d00-0x0fff]
kernel: pci_bus 0000:01: resource 9 [mem 0xfed00000-0xfed44fff]
kernel: pci_bus 0000:01: resource 10 [io  0x03b0-0x03bb]
kernel: pci_bus 0000:01: resource 11 [io  0x03c0-0x03df]
kernel: pci_bus 0000:01: resource 12 [mem 0x000a0000-0x000bffff]
kernel: pci_bus 0000:3e: resource 4 [io  0x0000-0xffff]
kernel: pci_bus 0000:3e: resource 5 [mem 0x00000000-0xffffffffff]
kernel: pci_bus 0000:3f: resource 4 [io  0x0000-0xffff]
kernel: pci_bus 0000:3f: resource 5 [mem 0x00000000-0xffffffffff]
kernel: NET: Registered protocol family 2
kernel: TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
kernel: TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
kernel: TCP: Hash tables configured (established 524288 bind 65536)
kernel: TCP: reno registered
kernel: UDP hash table entries: 8192 (order: 6, 262144 bytes)
kernel: UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
kernel: NET: Registered protocol family 1
kernel: pci 0000:01:03.0: Boot video device
kernel: PCI: CLS 64 bytes, default 64
kernel: Trying to unpack rootfs image as initramfs...
kernel: Freeing initrd memory: 3516k freed
kernel: PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
kernel: software IO TLB [mem 0xdb62c000-0xdf62bfff] (64MB) mapped at [ffff8800db62c000-ffff8800df62bfff]
kernel: HugeTLB registered 2 MB page size, pre-allocated 0 pages
kernel: VFS: Disk quotas dquot_6.5.2
kernel: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
kernel: msgmni has been set to 24067
kernel: Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
kernel: io scheduler noop registered
kernel: io scheduler deadline registered
kernel: io scheduler cfq registered (default)
kernel: pcieport 0000:00:1c.0: irq 64 for MSI/MSI-X
kernel: pcieport 0000:00:1c.2: irq 65 for MSI/MSI-X
kernel: pci_hotplug: PCI Hot Plug PCI Core version: 0.5
kernel: Monitor-Mwait will be used to enter C-1 state
kernel: thermal LNXTHERM:00: registered as thermal_zone0
kernel: ACPI: Thermal Zone [THM0] (8 C)
kernel: Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
kernel: serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
kernel: serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
kernel: 00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
kernel: Non-volatile memory driver v1.3
kernel: Linux agpgart interface v0.103
kernel: brd: module loaded
kernel: Uniform Multi-Platform E-IDE driver
kernel: ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
kernel: Probing IDE interface ide0...
kernel: tsc: Refined TSC clocksource calibration: 2932.497 MHz
kernel: Switching to clocksource tsc
kernel: ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
kernel: Probing IDE interface ide1...
kernel: ide1 at 0x170-0x177,0x376 on irq 15
kernel: ide-gd driver 1.18
kernel: i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f0e:PS2M] at 0x60,0x64 irq 1,12
kernel: serio: i8042 KBD port at 0x60,0x64 irq 1
kernel: serio: i8042 AUX port at 0x60,0x64 irq 12
kernel: mousedev: PS/2 mouse device common for all mice
kernel: cpuidle: using governor ladder
kernel: EFI Variables Facility v0.08 2004-May-17
kernel: usbcore: registered new interface driver usbhid
kernel: usbhid: USB HID core driver
kernel: TCP: bic registered
kernel: Initializing XFRM netlink socket
kernel: NET: Registered protocol family 17
kernel: Key type dns_resolver registered
kernel: registered taskstats version 1
kernel: Freeing unused kernel memory: 540k freed
kernel: nash-hotplug (858): /proc/858/oom_adj is deprecated, please use /proc/858/oom_score_adj instead.
kernel: ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
kernel: ehci_hcd 0000:00:1d.7: setting latency timer to 64
kernel: ehci_hcd 0000:00:1d.7: EHCI Host Controller
kernel: ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
kernel: ehci_hcd 0000:00:1d.7: debug port 1
kernel: ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
kernel: ehci_hcd 0000:00:1d.7: irq 20, io mem 0xf1df0000
kernel: ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
kernel: hub 1-0:1.0: USB hub found
kernel: hub 1-0:1.0: 8 ports detected
kernel: ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
kernel: uhci_hcd: USB Universal Host Controller Interface driver
kernel: uhci_hcd 0000:00:1d.0: setting latency timer to 64
kernel: uhci_hcd 0000:00:1d.0: UHCI Host Controller
kernel: uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
kernel: uhci_hcd 0000:00:1d.0: irq 20, io base 0x00001000
kernel: hub 2-0:1.0: USB hub found
kernel: hub 2-0:1.0: 2 ports detected
kernel: uhci_hcd 0000:00:1d.1: setting latency timer to 64
kernel: uhci_hcd 0000:00:1d.1: UHCI Host Controller
kernel: uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
kernel: uhci_hcd 0000:00:1d.1: irq 23, io base 0x00001020
kernel: hub 3-0:1.0: USB hub found
kernel: hub 3-0:1.0: 2 ports detected
kernel: uhci_hcd 0000:00:1d.2: setting latency timer to 64
kernel: uhci_hcd 0000:00:1d.2: UHCI Host Controller
kernel: uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
kernel: uhci_hcd 0000:00:1d.2: irq 22, io base 0x00001040
kernel: hub 4-0:1.0: USB hub found
kernel: hub 4-0:1.0: 2 ports detected
kernel: uhci_hcd 0000:00:1d.3: setting latency timer to 64
kernel: uhci_hcd 0000:00:1d.3: UHCI Host Controller
kernel: uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
kernel: uhci_hcd 0000:00:1d.3: irq 23, io base 0x00001060
kernel: hub 5-0:1.0: USB hub found
kernel: hub 5-0:1.0: 2 ports detected
kernel: uhci_hcd 0000:01:04.4: UHCI Host Controller
kernel: uhci_hcd 0000:01:04.4: new USB bus registered, assigned bus number 6
kernel: uhci_hcd 0000:01:04.4: port count misdetected? forcing to 2 ports
kernel: uhci_hcd 0000:01:04.4: irq 22, io base 0x00003800
kernel: hub 6-0:1.0: USB hub found
kernel: hub 6-0:1.0: 2 ports detected
kernel: SCSI subsystem initialized
kernel: HP HPSA Driver (v 2.0.2-1)
kernel: hpsa 0000:04:00.0: MSIX
kernel: hpsa 0000:04:00.0: irq 66 for MSI/MSI-X
kernel: hpsa 0000:04:00.0: irq 67 for MSI/MSI-X
kernel: hpsa 0000:04:00.0: irq 68 for MSI/MSI-X
kernel: hpsa 0000:04:00.0: irq 69 for MSI/MSI-X
kernel: hpsa 0000:04:00.0: irq 70 for MSI/MSI-X
kernel: hpsa 0000:04:00.0: irq 71 for MSI/MSI-X
kernel: hpsa 0000:04:00.0: irq 72 for MSI/MSI-X
kernel: hpsa 0000:04:00.0: irq 73 for MSI/MSI-X
kernel: hpsa 0000:04:00.0: hpsa0: <0x323a> at IRQ 66 using DAC
kernel: scsi0 : hpsa
kernel: hpsa 0000:04:00.0: Direct-Access     device c0b0t0l0 added.
kernel: hpsa 0000:04:00.0: RAID              device c0b3t0l0 added.
kernel: scsi 0:0:0:0: Direct-Access     HP       LOGICAL VOLUME   3.00 PQ: 0 ANSI: 5
kernel: sd 0:0:0:0: [sda] 286679925 512-byte logical blocks: (146 GB/136 GiB)
kernel: scsi 0:3:0:0: RAID              HP       P410i            3.00 PQ: 0 ANSI: 0
kernel: sd 0:0:0:0: [sda] Write Protect is off
kernel: sd 0:0:0:0: [sda] Mode Sense: 6b 00 00 08
kernel: sd 0:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
kernel: sda: sda1 sda2
kernel: sd 0:0:0:0: [sda] Attached SCSI disk
kernel: HP CISS Driver (v 3.6.26)
kernel: ACPI: bus type scsi registered
kernel: libata version 3.00 loaded.
kernel: ata_piix 0000:00:1f.2: version 2.13
kernel: ata_piix 0000:00:1f.2: MAP [
kernel: P0 P2 P1 P3 ]
kernel: ata_piix 0000:00:1f.2: setting latency timer to 64
kernel: scsi1 : ata_piix
kernel: scsi2 : ata_piix
kernel: ata1: SATA max UDMA/133 cmd 0x1080 ctl 0x1088 bmdma 0x10a0 irq 17
kernel: ata2: SATA max UDMA/133 cmd 0x1090 ctl 0x1098 bmdma 0x10a8 irq 17
kernel: usb 6-1: new full-speed USB device number 2 using uhci_hcd
kernel: input: HP Virtual Keyboard as /devices/pci0000:00/0000:00:1e.0/0000:01:04.4/usb6/6-1/6-1:1.0/input/input0
kernel: hid-generic 0003:03F0:1027.0001: input: USB HID v1.01 Keyboard [HP Virtual Keyboard] on usb-0000:01:04.4-1/input0
kernel: input: HP Virtual Keyboard as /devices/pci0000:00/0000:00:1e.0/0000:01:04.4/usb6/6-1/6-1:1.1/input/input1
kernel: hid-generic 0003:03F0:1027.0002: input: USB HID v1.01 Mouse [HP Virtual Keyboard] on usb-0000:01:04.4-1/input1
kernel: ata2.00: SATA link down (SStatus 4 SControl 300)
kernel: ata2.01: SATA link down (SStatus 4 SControl 300)
kernel: ata1.00: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
kernel: ata1.01: SATA link down (SStatus 4 SControl 300)
kernel: ata1.01: link offline, clearing class 3 to NONE
kernel: ata1.00: ATAPI: DV-28S-W, C.2D, max UDMA/100
kernel: ata1.00: configured for UDMA/100
kernel: scsi 1:0:0:0: CD-ROM            TEAC     DV-28S-W         C.2D PQ: 0 ANSI: 5
kernel: device-mapper: uevent: version 1.0.3
kernel: device-mapper: ioctl: 4.23.0-ioctl (2012-07-25) initialised: dm-devel@redhat.com
kernel: kjournald starting.  Commit interval 5 seconds
kernel: EXT3-fs (sda1): mounted filesystem with writeback data mode
kernel: microcode: CPU0 sig=0x206c2, pf=0x1, revision=0xc
kernel: ipmi message handler version 39.2
kernel: IPMI System Interface driver.
kernel: ipmi_si 0000:01:04.6: probing via PCI
kernel: ipmi_si 0000:01:04.6: [mem 0xf1ef0000-0xf1ef00ff] regsize 1 spacing 1 irq 21
kernel: ipmi_si: Adding PCI-specified kcs state machine
kernel: ipmi_si: probing via ACPI
kernel: ipmi_si 00:02: [io  0x0ca2-0x0ca3] regsize 1 spacing 1 irq 0
kernel: ipmi_si: Adding ACPI-specified kcs state machine
kernel: ipmi_si: probing via SMBIOS
kernel: ipmi_si: SMBIOS: io 0xca2 regsize 1 spacing 1 irq 0
kernel: ipmi_si: Adding SMBIOS-specified kcs state machine duplicate interface
kernel: ipmi_si: probing via SPMI
kernel: ipmi_si: SPMI: io 0xca2 regsize 2 spacing 2 irq 0
kernel: ipmi_si: Adding SPMI-specified kcs state machine duplicate interface
kernel: ipmi_si: Trying PCI-specified kcs state machine at mem address 0xf1ef0000, slave address 0x0, irq 21
kernel: input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
kernel: ACPI: Power Button [PWRF]
kernel: ipmi_si 0000:01:04.6: Using irq 21
kernel: input: PC Speaker as /devices/platform/pcspkr/input/input3
kernel: Floppy drive(s): fd0 is 1.44M
kernel: ipmi_si 0000:01:04.6: Found new BMC (man_id: 0x00000b, prod_id: 0x2000, dev_id: 0x11)
kernel: ipmi_si 0000:01:04.6: IPMI kcs interface initialized
kernel: microcode: CPU1 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU2 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU3 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU4 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU5 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU6 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU7 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU8 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU9 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU10 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU11 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU12 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU13 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU14 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU15 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU16 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU17 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU18 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU19 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU20 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU21 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU22 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: CPU23 sig=0x206c2, pf=0x1, revision=0xc
kernel: microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
kernel: bnx2: Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.2.3 (June 27, 2012)
kernel: bnx2 0000:02:00.0: eth0: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem f4000000, IRQ 16, node addr d8:d3:85:fb:fc:1a
kernel: bnx2 0000:02:00.1: eth1: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem f2000000, IRQ 17, node addr d8:d3:85:fb:fc:1c
kernel: bnx2 0000:03:00.0: eth2: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem f8000000, IRQ 18, node addr d8:d3:85:fb:fc:1e
kernel: bnx2 0000:03:00.1: eth3: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found at mem f6000000, IRQ 19, node addr d8:d3:85:fb:fc:20
kernel: dca service started, version 1.12.1
kernel: ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.9.15-k
kernel: ixgbe: Copyright (c) 1999-2012 Intel Corporation.
kernel: ixgbe 0000:10:00.0: irq 74 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 75 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 76 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 77 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 78 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 79 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 80 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 81 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 82 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 83 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 84 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 85 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 86 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 87 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 88 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 89 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 90 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 91 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 92 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 93 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 94 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 95 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 96 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 97 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: irq 98 for MSI/MSI-X
kernel: ixgbe 0000:10:00.0: Multiqueue Enabled: Rx Queue count = 24, Tx Queue count = 24
kernel: ixgbe 0000:10:00.0: (PCI Express:5.0GT/s:Width x8) 00:1b:21:69:9d:48
kernel: ixgbe 0000:10:00.0: MAC: 2, PHY: 15, SFP+: 5, PBA No: E68785-002
kernel: ixgbe 0000:10:00.0: Intel(R) 10 Gigabit Network Connection
kernel: ixgbe 0000:10:00.1: irq 99 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 100 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 101 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 102 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 103 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 104 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 105 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 106 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 107 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 108 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 109 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 110 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 111 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 112 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 113 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 114 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 115 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 116 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 117 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 118 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 119 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 120 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 121 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 122 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: irq 123 for MSI/MSI-X
kernel: ixgbe 0000:10:00.1: Multiqueue Enabled: Rx Queue count = 24, Tx Queue count = 24
kernel: ixgbe 0000:10:00.1: (PCI Express:5.0GT/s:Width x8) 00:1b:21:69:9d:49
kernel: ixgbe 0000:10:00.1: MAC: 2, PHY: 15, SFP+: 6, PBA No: E68785-002
kernel: ixgbe 0000:10:00.1: Intel(R) 10 Gigabit Network Connection
kernel: floppy0: no floppy controllers found
kernel: sd 0:0:0:0: Attached scsi generic sg0 type 0
kernel: scsi 0:3:0:0: Attached scsi generic sg1 type 12
kernel: scsi 1:0:0:0: Attached scsi generic sg2 type 5
kernel: sr0: scsi3-mmc drive: 24x/24x cd/rw xa/form2 cdda tray
kernel: cdrom: Uniform CD-ROM driver Revision: 3.20
kernel: sr 1:0:0:0: Attached scsi CD-ROM sr0
kernel: Floppy drive(s): fd0 is 1.44M
kernel: floppy0: no floppy controllers found
kernel: lp: driver loaded but no devices found
kernel: md: Autodetecting RAID arrays.
kernel: md: Scanned 0 and added 0 devices.
kernel: md: autorun ...
kernel: md: ... autorun DONE.
kernel: device-mapper: multipath: version 1.5.0 loaded
kernel: EXT3-fs (sda1): using internal journal
kernel: kjournald starting.  Commit interval 5 seconds
kernel: EXT3-fs (dm-0): using internal journal
kernel: EXT3-fs (dm-0): mounted filesystem with writeback data mode
kernel: kjournald starting.  Commit interval 5 seconds
kernel: EXT3-fs (dm-1): using internal journal
kernel: EXT3-fs (dm-1): mounted filesystem with writeback data mode
kernel: kjournald starting.  Commit interval 5 seconds
kernel: EXT3-fs (dm-2): using internal journal
kernel: EXT3-fs (dm-2): mounted filesystem with writeback data mode
kernel: kjournald starting.  Commit interval 5 seconds
kernel: EXT3-fs (dm-3): using internal journal
kernel: EXT3-fs (dm-3): mounted filesystem with writeback data mode
kernel: kjournald starting.  Commit interval 5 seconds
kernel: EXT3-fs (dm-4): using internal journal
kernel: EXT3-fs (dm-4): mounted filesystem with writeback data mode
kernel: RPC: Registered named UNIX socket transport module.
kernel: RPC: Registered udp transport module.
kernel: RPC: Registered tcp transport module.
kernel: RPC: Registered tcp NFSv4.1 backchannel transport module.
kernel: FS-Cache: Loaded
kernel: FS-Cache: Netfs 'nfs' registered for caching
kernel: Adding 2064380k swap on /dev/rootvg/swap1lv.  Priority:-1 extents:1 across:2064380k
kernel: microcode: Microcode Update Driver: v2.00 removed.
kernel: NET: Registered protocol family 10
kernel: ip6_tables: (C) 2000-2006 Netfilter Core Team
kernel: nf_conntrack version 0.5.0 (1000003 buckets, 8000024 max)
kernel: nf_conntrack: falling back to vmalloc.
kernel: nf_conntrack: falling back to vmalloc.
kernel: Netfilter messages via NETLINK v0.30.
kernel: nr_pdflush_threads exported in /proc is scheduled for removal
kernel: sysctl: The scan_unevictable_pages sysctl/node-interface has been disabled for lack of a legitimate use case.  If you have one, please send an email to linux-mm@kvack.org.
kernel: bnx2 0000:02:00.0: irq 124 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: irq 125 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: irq 126 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: irq 127 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: irq 128 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: irq 129 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: irq 130 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: irq 131 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: irq 132 for MSI/MSI-X
kernel: bnx2 0000:02:00.0: eth0: using MSIX
kernel: IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
kernel: bnx2 0000:02:00.0: eth0: NIC Copper Link is Up, 1000 Mbps full duplex
kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
kernel: IPv6: ADDRCONF(NETDEV_UP): eth4: link is not ready
kernel: ixgbe 0000:10:00.0: eth4: detected SFP+: 5
kernel: ixgbe 0000:10:00.0: eth4: NIC Link is Up 10 Gbps, Flow Control: RX/TX
kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth4: link becomes ready
kernel: IPv6: ADDRCONF(NETDEV_UP): eth5: link is not ready
kernel: ixgbe 0000:10:00.1: eth5: detected SFP+: 6
kernel: ixgbe 0000:10:00.1: eth5: NIC Link is Up 10 Gbps, Flow Control: RX/TX
kernel: IPv6: ADDRCONF(NETDEV_CHANGE): eth5: link becomes ready
kernel: 8021q: 802.1Q VLAN Support v1.8
kernel: 8021q: adding VLAN 0 to HW filter on device eth4
kernel: 8021q: adding VLAN 0 to HW filter on device eth5
kernel: ctnetlink v0.93: registering with nfnetlink.
kernel: i2c /dev entries driver
kernel: netlink: 12 bytes leftover after parsing attributes.




--------------090802080200060901050102
Content-Type: text/plain; charset=windows-1252;
 name="config-3.6.0-rc2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-3.6.0-rc2.txt"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.6.0-rc2 Kernel Configuration
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
# CONFIG_EXPERIMENTAL is not set
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
# CONFIG_FHANDLE is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
# CONFIG_TASK_XACCT is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
# CONFIG_CGROUPS is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
CONFIG_SYSFS_DEPRECATED=y
CONFIG_SYSFS_DEPRECATED_V2=y
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_KRETPROBES=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
CONFIG_MODVERSIONS=y
CONFIG_MODULE_SRCVERSION_ALL=y
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
CONFIG_INLINE_READ_UNLOCK=y
# CONFIG_INLINE_READ_UNLOCK_BH is not set
CONFIG_INLINE_READ_UNLOCK_IRQ=y
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
CONFIG_INLINE_WRITE_UNLOCK=y
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
CONFIG_MUTEX_SPIN_ON_OWNER=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=32
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_I8K=m
CONFIG_MICROCODE=m
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
# CONFIG_SECCOMP is not set
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
CONFIG_ACPI_PROCFS_POWER=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_SBS=m
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=m
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=m
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=m
# CONFIG_I82092 is not set
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_FAKE is not set
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=m
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=m
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
# CONFIG_INET_UDP_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=m
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_DEFAULT_BIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="bic"
CONFIG_IPV6=m
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
CONFIG_INET6_IPCOMP=m
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_IPV6_SIT=m
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
CONFIG_IPV6_GRE=m
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_ACCT=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
# CONFIG_NF_CONNTRACK_ZONES is not set
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NF_CONNTRACK_TIMEOUT=y
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_UDPLITE=m
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_BROADCAST=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_SNMP=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
CONFIG_NF_CT_NETLINK_TIMEOUT=m
CONFIG_NF_CT_NETLINK_HELPER=m
CONFIG_NETFILTER_NETLINK_QUEUE_CT=y
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_PROTO_UDPLITE=m
CONFIG_NETFILTER_XTABLES=m

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_SET=m

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_CT=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_HL=m
CONFIG_NETFILTER_XT_TARGET_HMARK=m
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
# CONFIG_NETFILTER_XT_TARGET_LED is not set
CONFIG_NETFILTER_XT_TARGET_LOG=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
CONFIG_NETFILTER_XT_TARGET_TEE=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_CPU=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ECN=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_HL=m
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_NFACCT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_RECENT=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_IP_SET=m
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=m
CONFIG_IP_SET_BITMAP_IPMAC=m
CONFIG_IP_SET_BITMAP_PORT=m
CONFIG_IP_SET_HASH_IP=m
CONFIG_IP_SET_HASH_IPPORT=m
CONFIG_IP_SET_HASH_IPPORTIP=m
CONFIG_IP_SET_HASH_IPPORTNET=m
CONFIG_IP_SET_HASH_NET=m
CONFIG_IP_SET_HASH_NETPORT=m
CONFIG_IP_SET_HASH_NETIFACE=m
CONFIG_IP_SET_LIST_SET=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
# CONFIG_IP_VS_PE_SIP is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
# CONFIG_IP_NF_QUEUE is not set
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_RPFILTER=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_ULOG=m
CONFIG_NF_NAT_IPV4=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_NF_NAT_SIP=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_SECURITY=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=m
CONFIG_NF_CONNTRACK_IPV6=m
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RPFILTER=m
CONFIG_IP6_NF_MATCH_RT=m
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_RAW=m
CONFIG_IP6_NF_SECURITY=m
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_IP6=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_ULOG=m
CONFIG_BRIDGE_EBT_NFLOG=m
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=m
# CONFIG_L2TP_DEBUGFS is not set
CONFIG_STP=m
CONFIG_GARP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_PHONET is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
# CONFIG_NET_SCH_MULTIQ is not set
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFB=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
# CONFIG_NET_SCH_DRR is not set
CONFIG_NET_SCH_MQPRIO=m
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_CODEL=m
CONFIG_NET_SCH_FQ_CODEL=m
CONFIG_NET_SCH_INGRESS=m
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
# CONFIG_NET_CLS_FLOW is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_EMATCH_IPSET=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
CONFIG_NET_ACT_IPT=m
# CONFIG_NET_ACT_NAT is not set
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
# CONFIG_NET_ACT_SKBEDIT is not set
# CONFIG_NET_ACT_CSUM is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=m
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
# CONFIG_CFG80211 is not set
CONFIG_LIB80211=m
CONFIG_LIB80211_CRYPT_WEP=m
CONFIG_LIB80211_CRYPT_CCMP=m
CONFIG_LIB80211_CRYPT_TKIP=m
# CONFIG_LIB80211_DEBUG is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
CONFIG_MTD_REDBOOT_PARTS=m
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
# CONFIG_MTD_CHAR is not set
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
CONFIG_MTD_BLOCK_RO=m
CONFIG_FTL=m
CONFIG_NFTL=m
CONFIG_NFTL_RW=y
# CONFIG_INFTL is not set
CONFIG_RFD_FTL=m
# CONFIG_SSFDC is not set
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=m
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=m
CONFIG_MTD_CFI_AMDSTD=m
CONFIG_MTD_CFI_STAA=m
CONFIG_MTD_CFI_UTIL=m
CONFIG_MTD_RAM=m
CONFIG_MTD_ROM=m
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_SC520CDP=m
CONFIG_MTD_NETSC520=m
CONFIG_MTD_TS5500=m
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
CONFIG_MTD_SCB2_FLASH=m
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOC2000 is not set
# CONFIG_MTD_DOC2001 is not set
# CONFIG_MTD_DOC2001PLUS is not set
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=m
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=m
# CONFIG_MTD_NAND_VERIFY_WRITE is not set
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
# CONFIG_MTD_NAND_MUSEUM_IDS is not set
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_IDS=m
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=m
# CONFIG_MTD_NAND_PLATFORM is not set
# CONFIG_MTD_ALAUDA is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_UBI is not set
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
CONFIG_PARPORT_PC_PCMCIA=m
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=m
CONFIG_PARIDE=m

#
# Parallel IDE high-level drivers
#
CONFIG_PARIDE_PD=m
CONFIG_PARIDE_PCD=m
CONFIG_PARIDE_PF=m
CONFIG_PARIDE_PT=m
CONFIG_PARIDE_PG=m

#
# Parallel IDE protocol modules
#
CONFIG_PARIDE_ATEN=m
CONFIG_PARIDE_BPCK=m
CONFIG_PARIDE_COMM=m
CONFIG_PARIDE_DSTR=m
CONFIG_PARIDE_FIT2=m
CONFIG_PARIDE_FIT3=m
CONFIG_PARIDE_EPAT=m
CONFIG_PARIDE_EPIA=m
CONFIG_PARIDE_FRIQ=m
CONFIG_PARIDE_FRPW=m
CONFIG_PARIDE_KBIC=m
CONFIG_PARIDE_KTTI=m
CONFIG_PARIDE_ON20=m
CONFIG_PARIDE_ON26=m
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
CONFIG_BLK_CPQ_DA=m
CONFIG_BLK_CPQ_CISS_DA=m
CONFIG_CISS_SCSI_TAPE=y
CONFIG_BLK_DEV_DAC960=m
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=m
# CONFIG_BLK_DEV_DRBD is not set
CONFIG_BLK_DEV_NBD=m
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_SX8=m
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_ATA_OVER_ETH=m
# CONFIG_BLK_DEV_HD is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
# CONFIG_PHANTOM is not set
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HP_ILO=m
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_93CX6=m
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
# CONFIG_IDE_GD_ATAPI is not set
CONFIG_BLK_DEV_IDECS=m
# CONFIG_BLK_DEV_DELKIN is not set
CONFIG_BLK_DEV_IDECD=m
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
CONFIG_BLK_DEV_CMD640=y
CONFIG_BLK_DEV_CMD640_ENHANCED=y
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
CONFIG_BLK_DEV_ALI15X3=y
CONFIG_BLK_DEV_AMD74XX=y
CONFIG_BLK_DEV_ATIIXP=y
CONFIG_BLK_DEV_CMD64X=y
CONFIG_BLK_DEV_TRIFLEX=y
CONFIG_BLK_DEV_CS5530=y
CONFIG_BLK_DEV_HPT366=y
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT8172 is not set
# CONFIG_BLK_DEV_IT8213 is not set
CONFIG_BLK_DEV_IT821X=y
# CONFIG_BLK_DEV_NS87415 is not set
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
CONFIG_BLK_DEV_SVWKS=y
CONFIG_BLK_DEV_SIIMAGE=y
CONFIG_BLK_DEV_SIS5513=y
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
CONFIG_BLK_DEV_VIA82CXXX=y
# CONFIG_BLK_DEV_TC86C001 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=m
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=m
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
# CONFIG_SCSI_CXGB4_ISCSI is not set
CONFIG_SCSI_BNX2_ISCSI=m
# CONFIG_SCSI_BNX2X_FCOE is not set
CONFIG_BE2ISCSI=m
CONFIG_BLK_DEV_3W_XXXX_RAID=m
CONFIG_SCSI_HPSA=m
CONFIG_SCSI_3W_9XXX=m
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_ACARD=m
CONFIG_SCSI_AACRAID=m
CONFIG_SCSI_AIC7XXX=m
CONFIG_AIC7XXX_CMDS_PER_DEVICE=4
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC7XXX_OLD=m
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=m
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=m
CONFIG_SCSI_MVSAS_DEBUG=y
# CONFIG_SCSI_MVSAS_TASKLET is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=m
CONFIG_MEGARAID_MAILBOX=m
CONFIG_MEGARAID_LEGACY=m
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS_LOGGING=y
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=m
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_GDTH=m
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_IPS=m
CONFIG_SCSI_INITIO=m
# CONFIG_SCSI_INIA100 is not set
CONFIG_SCSI_PPA=m
CONFIG_SCSI_IMM=m
# CONFIG_SCSI_IZIP_EPP16 is not set
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=m
CONFIG_SCSI_QLA_FC=m
CONFIG_SCSI_QLA_ISCSI=m
CONFIG_SCSI_LPFC=m
# CONFIG_SCSI_LPFC_DEBUG_FS is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
CONFIG_SCSI_PMCRAID=m
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
CONFIG_SCSI_BFA_FC=m
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
CONFIG_SCSI_DH=m
CONFIG_SCSI_DH_RDAC=m
# CONFIG_SCSI_DH_HP_SW is not set
CONFIG_SCSI_DH_EMC=m
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=m
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARASAN_CF is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_ATP867X is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_JMICRON is not set
CONFIG_PATA_MARVELL=m
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
CONFIG_PATA_PDC2027X=m
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SCH is not set
# CONFIG_PATA_SERVERWORKS is not set
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_PCMCIA is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
# CONFIG_ATA_GENERIC is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_MIRROR=m
# CONFIG_DM_RAID is not set
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
CONFIG_DM_UEVENT=y
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
CONFIG_FUSION_FC=m
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LAN=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_SBP2=m
# CONFIG_FIREWIRE_NET is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_I2O=m
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_EXT_ADAPTEC_DMA64=y
CONFIG_I2O_CONFIG=m
CONFIG_I2O_CONFIG_OLD_IOCTL=y
CONFIG_I2O_BUS=m
CONFIG_I2O_BLOCK=m
CONFIG_I2O_SCSI=m
CONFIG_I2O_PROC=m
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
CONFIG_BONDING=m
CONFIG_DUMMY=m
# CONFIG_EQUALIZER is not set
CONFIG_NET_FC=y
CONFIG_MII=m
CONFIG_IFB=m
CONFIG_NETCONSOLE=m
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
CONFIG_NETPOLL_TRAP=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=m
# CONFIG_VETH is not set
CONFIG_SUNGEM_PHY=m
# CONFIG_ARCNET is not set
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
CONFIG_ATM_TCP=m
CONFIG_ATM_LANAI=m
CONFIG_ATM_ENI=m
# CONFIG_ATM_ENI_DEBUG is not set
# CONFIG_ATM_ENI_TUNE_BURST is not set
CONFIG_ATM_FIRESTREAM=m
# CONFIG_ATM_ZATM is not set
# CONFIG_ATM_NICSTAR is not set
CONFIG_ATM_IDT77252=m
# CONFIG_ATM_IDT77252_DEBUG is not set
# CONFIG_ATM_IDT77252_RCV_ALL is not set
CONFIG_ATM_IDT77252_USE_SUNI=y
CONFIG_ATM_AMBASSADOR=m
# CONFIG_ATM_AMBASSADOR_DEBUG is not set
CONFIG_ATM_HORIZON=m
# CONFIG_ATM_HORIZON_DEBUG is not set
# CONFIG_ATM_IA is not set
# CONFIG_ATM_FORE200E is not set
CONFIG_ATM_HE=m
# CONFIG_ATM_HE_USE_SUNI is not set
# CONFIG_ATM_SOLOS is not set

#
# CAIF transport drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=m
CONFIG_NET_VENDOR_3COM=y
CONFIG_PCMCIA_3C574=m
CONFIG_PCMCIA_3C589=m
CONFIG_VORTEX=m
CONFIG_TYPHOON=m
CONFIG_NET_VENDOR_ADAPTEC=y
CONFIG_ADAPTEC_STARFIRE=m
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=m
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=m
CONFIG_PCNET32=m
CONFIG_PCMCIA_NMCLAN=m
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BNX2=m
CONFIG_CNIC=m
CONFIG_TIGON3=m
CONFIG_BNX2X=m
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=m
# CONFIG_CHELSIO_T1_1G is not set
CONFIG_CHELSIO_T3=m
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=m
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=m
CONFIG_TULIP_MMIO=y
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DE600 is not set
# CONFIG_DE620 is not set
CONFIG_DL2K=m
CONFIG_SUNDANCE=m
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=m
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=m
CONFIG_VXGE=m
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_NET_VENDOR_FUJITSU=y
CONFIG_PCMCIA_FMVJ18X=m
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=m
CONFIG_E1000=m
CONFIG_E1000E=m
CONFIG_IGB=m
CONFIG_IGB_DCA=y
CONFIG_IGBVF=m
CONFIG_IXGB=m
CONFIG_IXGBE=m
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
CONFIG_IXGBEVF=m
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_SKGE=m
# CONFIG_SKGE_DEBUG is not set
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=m
# CONFIG_SKY2_DEBUG is not set
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=m
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=m
CONFIG_MYRI10GE_DCA=y
CONFIG_FEALNX=m
CONFIG_NET_VENDOR_NATSEMI=y
CONFIG_NATSEMI=m
CONFIG_NS83820=m
CONFIG_NET_VENDOR_8390=y
CONFIG_PCMCIA_AXNET=m
CONFIG_NE2K_PCI=m
CONFIG_PCMCIA_PCNET=m
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=m
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
# CONFIG_NET_PACKET_ENGINE is not set
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=m
# CONFIG_QLCNIC is not set
CONFIG_QLGE=m
CONFIG_NETXEN_NIC=m
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
CONFIG_8139TOO=m
# CONFIG_8139TOO_PIO is not set
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=m
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=m
CONFIG_SIS190=m
CONFIG_SFC=m
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_NET_VENDOR_SMSC=y
CONFIG_PCMCIA_SMC91C92=m
CONFIG_EPIC100=m
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
CONFIG_HAPPYMEAL=m
CONFIG_SUNGEM=m
CONFIG_CASSINI=m
CONFIG_NIU=m
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
CONFIG_TLAN=m
CONFIG_NET_VENDOR_VIA=y
CONFIG_VIA_RHINE=m
CONFIG_VIA_RHINE_MMIO=y
CONFIG_VIA_VELOCITY=m
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
CONFIG_PCMCIA_XIRC2PS=m
CONFIG_FDDI=y
# CONFIG_DEFXX is not set
# CONFIG_SKFP is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=m

#
# MII PHY device drivers
#
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=m
CONFIG_DAVICOM_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_LXT_PHY=m
CONFIG_CICADA_PHY=m
CONFIG_VITESSE_PHY=m
CONFIG_SMSC_PHY=m
# CONFIG_BROADCOM_PHY is not set
# CONFIG_BCM87XX_PHY is not set
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
# CONFIG_MDIO_BITBANG is not set
# CONFIG_PLIP is not set
CONFIG_PPP=m
# CONFIG_PPP_BSDCOMP is not set
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_FILTER=y
CONFIG_PPPOATM=m
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_SLIP=m
CONFIG_SLHC=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set

#
# USB Network Adapters
#
CONFIG_USB_KAWETH=m
CONFIG_USB_PEGASUS=m
CONFIG_USB_USBNET=m
CONFIG_USB_NET_AX8817X=m
CONFIG_USB_NET_CDCETHER=m
CONFIG_USB_NET_CDC_NCM=m
CONFIG_USB_NET_DM9601=m
# CONFIG_USB_NET_SMSC75XX is not set
# CONFIG_USB_NET_SMSC95XX is not set
CONFIG_USB_NET_GL620A=m
CONFIG_USB_NET_NET1080=m
# CONFIG_USB_NET_MCS7830 is not set
CONFIG_USB_NET_CDC_SUBSET=m
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_NET_ZAURUS=m
# CONFIG_USB_NET_CX82310_ETH is not set
# CONFIG_USB_NET_KALMIA is not set
# CONFIG_USB_NET_QMI_WWAN is not set
# CONFIG_USB_NET_INT51X1 is not set
# CONFIG_USB_IPHETH is not set
# CONFIG_USB_SIERRA_NET is not set
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
# CONFIG_PCMCIA_RAYCS is not set
CONFIG_AIRO=m
CONFIG_ATMEL=m
CONFIG_PCI_ATMEL=m
CONFIG_PCMCIA_ATMEL=m
CONFIG_AIRO_CS=m
CONFIG_USB_ZD1201=m
CONFIG_HOSTAP=m
CONFIG_HOSTAP_FIRMWARE=y
CONFIG_HOSTAP_FIRMWARE_NVRAM=y
CONFIG_HOSTAP_PLX=m
CONFIG_HOSTAP_PCI=m
CONFIG_HOSTAP_CS=m
# CONFIG_WL_TI is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=m
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_VSXXXAA=m
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
# CONFIG_JOYSTICK_A3D is not set
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
# CONFIG_JOYSTICK_GF2K is not set
# CONFIG_JOYSTICK_GRIP is not set
# CONFIG_JOYSTICK_GRIP_MP is not set
# CONFIG_JOYSTICK_GUILLEMOT is not set
# CONFIG_JOYSTICK_INTERACT is not set
# CONFIG_JOYSTICK_SIDEWINDER is not set
# CONFIG_JOYSTICK_TMDC is not set
# CONFIG_JOYSTICK_IFORCE is not set
# CONFIG_JOYSTICK_WARRIOR is not set
# CONFIG_JOYSTICK_MAGELLAN is not set
# CONFIG_JOYSTICK_SPACEORB is not set
# CONFIG_JOYSTICK_SPACEBALL is not set
# CONFIG_JOYSTICK_STINGER is not set
CONFIG_JOYSTICK_TWIDJOY=m
# CONFIG_JOYSTICK_ZHENHUA is not set
# CONFIG_JOYSTICK_DB9 is not set
# CONFIG_JOYSTICK_GAMECON is not set
# CONFIG_JOYSTICK_TURBOGRAFX is not set
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=m
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_JOYSTICK_WALKERA0701 is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_ILI210X is not set
CONFIG_TOUCHSCREEN_GUNZE=m
CONFIG_TOUCHSCREEN_ELO=m
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
CONFIG_TOUCHSCREEN_MTOUCH=m
# CONFIG_TOUCHSCREEN_INEXIO is not set
CONFIG_TOUCHSCREEN_MK712=m
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WM97XX is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
CONFIG_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=m
CONFIG_GAMEPORT_EMU10K1=m
CONFIG_GAMEPORT_FM801=m

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_MOXA_INTELLIO is not set
# CONFIG_MOXA_SMARTIO is not set
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
# CONFIG_ISI is not set
CONFIG_N_HDLC=m
# CONFIG_TRACE_SINK is not set
CONFIG_DEVKMEM=y
# CONFIG_STALDRV is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CS=m
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=m
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
CONFIG_PRINTER=m
CONFIG_LP_CONSOLE=y
CONFIG_PPDEV=m
CONFIG_IPMI_HANDLER=m
CONFIG_IPMI_PANIC_EVENT=y
CONFIG_IPMI_PANIC_STRING=y
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_NVRAM=y
# CONFIG_RTC is not set
# CONFIG_GEN_RTC is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=8192
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
CONFIG_DEVPORT=y
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=m
CONFIG_I2C_ALGOBIT=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=m
CONFIG_I2C_ALI15X3=m
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=m
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_SIS5595=m
CONFIG_I2C_SIS630=m
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_INTEL_MID is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable Device Drivers -> PPS to see the PTP clock options.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7475=m
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
# CONFIG_SENSORS_IBMAEM is not set
CONFIG_SENSORS_IBMPEX=m
CONFIG_SENSORS_IT87=m
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LM95241 is not set
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_PCF8591=m
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SIS5595=m
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=m
CONFIG_SENSORS_THMC50=m
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_APPLESMC=m

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
CONFIG_THERMAL=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
# CONFIG_SP5100_TCO is not set
# CONFIG_SC520_WDT is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=m
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
# CONFIG_HP_WATCHDOG is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=m
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83697UG_WDT is not set
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
# CONFIG_SSB_PCMCIAHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
# CONFIG_SSB_SDIOHOST is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_LPC_SCH is not set
# CONFIG_LPC_ICH is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_REGULATOR is not set
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=m
CONFIG_DRM_KMS_HELPER=m
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=m
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
# CONFIG_DRM_RADEON_KMS is not set
# CONFIG_DRM_NOUVEAU is not set

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
CONFIG_DRM_I810=m
CONFIG_DRM_I915=m
# CONFIG_DRM_I915_KMS is not set
CONFIG_DRM_MGA=m
# CONFIG_DRM_SIS is not set
CONFIG_DRM_VIA=m
CONFIG_DRM_SAVAGE=m
# CONFIG_DRM_VMWGFX is not set
# CONFIG_STUB_POULSBO is not set
CONFIG_VGASTATE=m
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=m
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_FOREIGN_ENDIAN is not set
# CONFIG_FB_SYS_FOPS is not set
# CONFIG_FB_WMT_GE_ROPS is not set
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=m
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
CONFIG_FB_VGA16=m
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=m
CONFIG_FB_NVIDIA_I2C=y
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=m
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
CONFIG_FB_RIVA_BACKLIGHT=y
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
CONFIG_FB_KYRO=m
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_SMSCUFX is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
# CONFIG_BACKLIGHT_PROGEAR is not set
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LP855X is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
CONFIG_SND_PCM_OSS=m
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_SEQUENCER_OSS=y
# CONFIG_SND_HRTIMER is not set
CONFIG_SND_DYNAMIC_MINORS=y
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_KCTL_JACK=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=m
CONFIG_SND_OPL3_LIB_SEQ=m
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=m
# CONFIG_SND_ALOOP is not set
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
# CONFIG_SND_AC97_POWER_SAVE is not set
CONFIG_SND_SB_COMMON=m
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
CONFIG_SND_ALS300=m
CONFIG_SND_ALS4000=m
CONFIG_SND_ALI5451=m
# CONFIG_SND_ASIHPI is not set
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
CONFIG_SND_AZT3328=m
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
# CONFIG_SND_OXYGEN is not set
CONFIG_SND_CS4281=m
CONFIG_SND_CS46XX=m
CONFIG_SND_CS46XX_NEW_DSP=y
# CONFIG_SND_CS5530 is not set
CONFIG_SND_CS5535AUDIO=m
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
CONFIG_SND_ES1938=m
CONFIG_SND_ES1968=m
# CONFIG_SND_ES1968_INPUT is not set
CONFIG_SND_FM801=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
# CONFIG_SND_HDA_INPUT_JACK is not set
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CA0132=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
CONFIG_SND_MAESTRO3=m
# CONFIG_SND_MAESTRO3_INPUT is not set
CONFIG_SND_MIXART=m
CONFIG_SND_NM256=m
CONFIG_SND_PCXHR=m
CONFIG_SND_RIPTIDE=m
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
CONFIG_SND_SONICVIBES=m
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
# CONFIG_SND_VIRTUOSO is not set
CONFIG_SND_VX222=m
CONFIG_SND_YMFPCI=m
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
# CONFIG_SND_USB_UA101 is not set
CONFIG_SND_USB_USX2Y=m
# CONFIG_SND_USB_CAIAQ is not set
# CONFIG_SND_USB_6FIRE is not set
CONFIG_SND_FIREWIRE=y
# CONFIG_SND_FIREWIRE_SPEAKERS is not set
# CONFIG_SND_ISIGHT is not set
CONFIG_SND_PCMCIA=y
# CONFIG_SND_VXPOCKET is not set
# CONFIG_SND_PDAUDIOCF is not set
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_PRODIKEYS is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_LOGITECH_FF=y
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTRIG=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_MON=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=m
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=m
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=m
CONFIG_USB_SL811_HCD=m
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=m
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_CHIPIDEA is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set
# CONFIG_USB_UAS is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=m
CONFIG_USB_EZUSB=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_AIRCABLE is not set
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
# CONFIG_USB_SERIAL_CH341 is not set
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
# CONFIG_USB_SERIAL_CP210X is not set
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_FUNSOFT=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
# CONFIG_USB_SERIAL_F81232 is not set
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
# CONFIG_USB_SERIAL_IUU is not set
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KEYSPAN_MPR=y
CONFIG_USB_SERIAL_KEYSPAN_USA28=y
CONFIG_USB_SERIAL_KEYSPAN_USA28X=y
CONFIG_USB_SERIAL_KEYSPAN_USA28XA=y
CONFIG_USB_SERIAL_KEYSPAN_USA28XB=y
CONFIG_USB_SERIAL_KEYSPAN_USA19=y
CONFIG_USB_SERIAL_KEYSPAN_USA18X=y
CONFIG_USB_SERIAL_KEYSPAN_USA19W=y
CONFIG_USB_SERIAL_KEYSPAN_USA19QW=y
CONFIG_USB_SERIAL_KEYSPAN_USA19QI=y
CONFIG_USB_SERIAL_KEYSPAN_USA49W=y
CONFIG_USB_SERIAL_KEYSPAN_USA49WLC=y
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
# CONFIG_USB_SERIAL_METRO is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_MOTOROLA is not set
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
# CONFIG_USB_SERIAL_OTI6858 is not set
# CONFIG_USB_SERIAL_QCAUX is not set
CONFIG_USB_SERIAL_QUALCOMM=m
# CONFIG_USB_SERIAL_SPCP8X5 is not set
CONFIG_USB_SERIAL_HP4X=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
# CONFIG_USB_SERIAL_SIEMENS_MPI is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
# CONFIG_USB_SERIAL_SYMBOL is not set
CONFIG_USB_SERIAL_TI=m
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
# CONFIG_USB_SERIAL_OPTICON is not set
# CONFIG_USB_SERIAL_VIVOPAY_SERIAL is not set
# CONFIG_USB_SERIAL_ZIO is not set
# CONFIG_USB_SERIAL_SSU100 is not set
# CONFIG_USB_SERIAL_QT2 is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
CONFIG_USB_RIO500=m
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
CONFIG_USB_LED=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
# CONFIG_USB_FTDI_ELAN is not set
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
CONFIG_USB_TEST=m
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_YUREX is not set

#
# USB Physical Layer drivers
#
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_NOP_USB_XCEIV is not set
CONFIG_MMC=m
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_PLTFM is not set
CONFIG_MMC_WBSD=m
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_VUB300 is not set
# CONFIG_MMC_USHC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LP3944 is not set
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA9633 is not set
# CONFIG_LEDS_BD2802 is not set
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_DELL_NETBOOKS is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM3556 is not set
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=m
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_IDE_DISK=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=m
CONFIG_INFINIBAND_USER_MAD=m
CONFIG_INFINIBAND_USER_ACCESS=m
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=m
CONFIG_INFINIBAND_MTHCA_DEBUG=y
# CONFIG_INFINIBAND_IPATH is not set
# CONFIG_INFINIBAND_QIB is not set
# CONFIG_INFINIBAND_AMSO1100 is not set
CONFIG_INFINIBAND_CXGB3=m
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
CONFIG_MLX4_INFINIBAND=m
CONFIG_INFINIBAND_NES=m
# CONFIG_INFINIBAND_NES_DEBUG is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=m
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=m
CONFIG_INFINIBAND_ISER=m
CONFIG_EDAC=y

#
# Reporting subsystems
#
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=m
CONFIG_EDAC_E752X=m
# CONFIG_EDAC_I82975X is not set
CONFIG_EDAC_I3000=m
# CONFIG_EDAC_X38 is not set
CONFIG_EDAC_I5400=m
# CONFIG_EDAC_I7CORE is not set
CONFIG_EDAC_I5000=m
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=m
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
CONFIG_DCA=m
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
# CONFIG_UIO_PCI_GENERIC is not set
# CONFIG_UIO_NETX is not set

#
# Virtio drivers
#
# CONFIG_VIRTIO_BALLOON is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_WMI=m
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WMI is not set
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=m
# CONFIG_MSI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
CONFIG_ACPI_TOSHIBA=m
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_MXM_WMI is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set
# CONFIG_INTEL_IOMMU is not set

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_EFI_VARS=y
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=m
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=m
CONFIG_EXT4_FS_XATTR=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_DEBUG=y
CONFIG_FS_XIP=y
CONFIG_JBD=m
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=m
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=m
# CONFIG_CUSE is not set

#
# Caches
#
CONFIG_FSCACHE=m
# CONFIG_FSCACHE_STATS is not set
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
CONFIG_CACHEFILES_DEBUG=y
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=m
CONFIG_MISC_FILESYSTEMS=y
CONFIG_HFSPLUS_FS=m
CONFIG_JFFS2_FS=m
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_CRAMFS=m
CONFIG_SQUASHFS=m
# CONFIG_SQUASHFS_XATTR is not set
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=m
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_PSTORE is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V2=m
CONFIG_NFS_V3=m
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
# CONFIG_SUNRPC_DEBUG is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CIFS_ACL is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=m
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=m

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_DEBUG_KERNEL is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_STACKTRACE=y
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
# CONFIG_FRAME_POINTER is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_LKDTM is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_EVENT_POWER_TRACING_DEPRECATED=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
# CONFIG_FUNCTION_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_SCHED_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
# CONFIG_UPROBE_EVENT is not set
CONFIG_PROBE_EVENTS=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
# CONFIG_DYNAMIC_DEBUG is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_DEBUG_SET_MODULE_RONX is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_OPTIMIZE_INLINING is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
# CONFIG_SECURITY_PATH is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=m
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
# CONFIG_CRYPTO_GF128MUL is not set
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_WORKQUEUE=y
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_CTR=m
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=m
# CONFIG_CRYPTO_LRW is not set
# CONFIG_CRYPTO_PCBC is not set
# CONFIG_CRYPTO_XTS is not set

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=m
CONFIG_CRYPTO_MICHAEL_MIC=m
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
# CONFIG_CRYPTO_RMD256 is not set
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_X86_64 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA is not set
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=m
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=m
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=m
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
# CONFIG_CRYPTO_DEV_PADLOCK_SHA is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=m
CONFIG_CRC_T10DIF=m
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=m
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CORDIC=m
# CONFIG_DDR is not set





--------------090802080200060901050102--
