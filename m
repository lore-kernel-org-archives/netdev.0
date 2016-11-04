From: Sumit Gemini1 <sumit.gemini1@globallogic.com>
Subject: Need you attention to solve this soft lockup issue in intel network
 interface card (IGB)
Date: Fri, 4 Nov 2016 12:00:17 +0530
Message-ID: <CAAooqb0Jy6unwR6Ucr69aix2tJo1mky1gGwCs_ANTN6U8aAXbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35292 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933755AbcKDGaT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 02:30:19 -0400
Received: by mail-oi0-f41.google.com with SMTP id x4so139299727oix.2
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 23:30:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,,

msx:~ # ethtool -i eth0
driver: igb
version: 3.2.10-k
firmware-version: 3.2-9
bus-info: 0000:0b:00.1
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes


I have one issue, at customer machine the user space process is
hogging up the processor (soft lockup)along with 2 kernel process and
dump stack trace showing RIP at _ticket_spin_lock in all 3 process.

As i know "If an user-space process had caused the soft-lockup, a line
identifying the process by its pid would logged, followed by the
contents of various CPU-registers without a call-trace of any sorts"
but in my case i am getting dump stack trace for user process too.

is it coming from a misbehaving user space app? is it normal
functionality of soft lockup? if is it functionality of soft lockup
then how to resolve the issue?

Any help will be highly appreciated.
it is x86_64 machine and kernel is 3.1.10. I know all 3 process are
waiting for _ticket_spin_lock. see :

Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492033] BUG: soft
lockup - CPU#3 stuck for 22s! [virtio_shm/5/3:7874]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404215] BUG: soft
lockup - CPU#31 stuck for 23s! [kni_thread:6605]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172014] BUG: soft
lockup - CPU#0 stuck for 22s! [gis:14145]


here gis is my user space process but has call trace.
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492033] BUG: soft
lockup - CPU#3 stuck for 22s! [virtio_shm/5/3:7874]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492036] Modules linked
in: xt_sharedlimit xt_hashlimit ip_set_hash_ipport
ip_set_hash_ipportip xt_NOTRACK ip_set_bitmap_port xt_sctp
nf_conntrack_ipv6 nf_defrag_ipv6 xt_CT arpt_mangle ip_set_hash_ipnet
xt_NFLOG xt_limit xt_hashcounter ip_set_hash_ipip xt_set
ip_set_hash_ip deflate ctr twofish_x86_64 twofish_common camellia
serpent blowfish cast5 des_generic cbc xcbc rmd160 crypto_null af_key
iptable_mangle ip_set arptable_filter arp_tables iptable_raw
iptable_nat nfnetlink_log nfnetlink ipt_ULOG ipt_PORTMAP af_packet
zlib zlib_deflate sha512_generic sha256_generic sha1_generic md5
icp_qa_al pcie8120 rte_kni pfe_pep virtio_rte virtio_shm virtio_vtnet
virtio_uio igb_uio virtio_ring virtio uio xt_tcpudp xt_state
xt_pkttype nf_conntrack_control bonding binfmt_misc iptable_filter
ip6table_filter ip6_tables nf_nat_ftp nf_nat nf_conntrack_ftp
nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables x_tables mperf ipmi_devintf
ipmi_si ipmi_msghandler edd nf_conntrack_proto_sctp nf_conntrack sctp
8021q garp stp llc gb_sys usb_storage uas iTCO_wdt ioatdma pcspkr
iTCO_vendor_support ixgbe igb wmi i2c_i801 mdio dca sg button
container ipv6 autofs4 usbhid ehci_hcd megasr(P) usbcore processor
thermal_sys
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492126] CPU 3
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492127] Modules linked
in: xt_sharedlimit xt_hashlimit ip_set_hash_ipport
ip_set_hash_ipportip xt_NOTRACK ip_set_bitmap_port xt_sctp
nf_conntrack_ipv6 nf_defrag_ipv6 xt_CT arpt_mangle ip_set_hash_ipnet
xt_NFLOG xt_limit xt_hashcounter ip_set_hash_ipip xt_set
ip_set_hash_ip deflate ctr twofish_x86_64 twofish_common camellia
serpent blowfish cast5 des_generic cbc xcbc rmd160 crypto_null af_key
iptable_mangle ip_set arptable_filter arp_tables iptable_raw
iptable_nat nfnetlink_log nfnetlink ipt_ULOG ipt_PORTMAP af_packet
zlib zlib_deflate sha512_generic sha256_generic sha1_generic md5
icp_qa_al pcie8120 rte_kni pfe_pep virtio_rte virtio_shm virtio_vtnet
virtio_uio igb_uio virtio_ring virtio uio xt_tcpudp xt_state
xt_pkttype nf_conntrack_control bonding binfmt_misc iptable_filter
ip6table_filter ip6_tables nf_nat_ftp nf_nat nf_conntrack_ftp
nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables x_tables mperf ipmi_devintf
ipmi_si ipmi_msghandler edd nf_conntrack_proto_sctp nf_conntrack sctp
8021q garp stp llc gb_sys usb_storage uas iTCO_wdt ioatdma pcspkr
iTCO_vendor_support ixgbe igb wmi i2c_i801 mdio dca sg button
container ipv6 autofs4 usbhid ehci_hcd megasr(P) usbcore processor
thermal_sys
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492193]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492196] Pid: 7874,
comm: virtio_shm/5/3 Tainted: P            3.1.10-gb20-default #1
Intel Corporation S2600CO/S2600CO
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492201] RIP:
0010:[<ffffffff81020650>]  [<ffffffff81020650>]
__ticket_spin_lock+0x18/0x1b
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492208] RSP:
0018:ffff88043ee63de8  EFLAGS: 00000293
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492210] RAX:
00000000000069be RBX: ffff880423772740 RCX: 000000000000000e
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492213] RDX:
00000000000069bc RSI: 000000000000000e RDI: ffff88041e56a484
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492215] RBP:
ffff88041e56a484 R08: ffff88041e56a740 R09: ffff88041554f04c
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492217] R10:
0000000000000048 R11: ffff88041ee7fbc0 R12: ffff88043ee63d58
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492219] R13:
ffffffff813f831e R14: ffff88041e56a484 R15: ffff88041ee7fbc0
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492222] FS:
0000000000000000(0000) GS:ffff88043ee60000(0000)
knlGS:0000000000000000
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492225] CS:  0010 DS:
0000 ES: 0000 CR0: 000000008005003b
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492227] CR2:
000000000078a410 CR3: 000000080b8df000 CR4: 00000000000406e0
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492229] DR0:
0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492232] DR3:
0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492234] Process
virtio_shm/5/3 (pid: 7874, threadinfo ffff880811e52000, task
ffff880821e320c0)
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492236] Stack:
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492238]
ffffffff8106b766 ffffffffa05e3a1e 000000001201fea9 ffffffffa03ef8b8
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492244]
0000002e1201fea9 ffff880423772000 ffff88043ee63e48 ffff880423772000
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492249]
ffffffff8192a870 0000000000000608 0000000000000000 ffffffff81928b00
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492255] Call Trace:
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492266]
[<ffffffff8106b766>] do_raw_spin_lock+0x5/0x8
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492275]
[<ffffffffa05e3a1e>] packet_rcv+0x254/0x2ab [af_packet]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492299]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492304]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492311]
[<ffffffffa03e2b49>] virtio_rte_recv_packets+0x2c/0x49 [virtio_rte]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492318]
[<ffffffffa03e2b78>] virtio_rte_poll+0x12/0x8c [virtio_rte]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492325]
[<ffffffff81339c88>] net_rx_action+0x65/0x178
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492331]
[<ffffffff81045c73>] __do_softirq+0xb2/0x19d
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492337]
[<ffffffff813f9aac>] call_softirq+0x1c/0x30
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492343]
[<ffffffff81003931>] do_softirq+0x3c/0x7b
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492348]
[<ffffffff81045971>] _local_bh_enable_ip.isra.12+0x75/0x9b
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492355]
[<ffffffffa03d8cdc>] virtio_shm_interrupt.isra.8+0xd6/0xeb
[virtio_shm]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492363]
[<ffffffffa03d8e0c>] virtio_shm_intr_task+0x11b/0x15f [virtio_shm]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492371]
[<ffffffff8105975a>] kthread+0x76/0x7e
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492377]
[<ffffffff813f99b4>] kernel_thread_helper+0x4/0x10
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492379] Code: b7 c9 40
0f b6 ff 48 89 c2 44 89 ce e9 8e fb ff ff 90 90 b8 00 00 01 00 f0 0f
c1 07 0f b7 d0 c1 e8 10 39 c2 74 07 f3 90 0f b7 17 <eb> f5 c3 8b 07 89
c2 c1 c0 10 39 c2 8d 90 00 00 01 00 75 04 f0
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492409] Call Trace:
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492413]
[<ffffffff8106b766>] do_raw_spin_lock+0x5/0x8
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492418]
[<ffffffffa05e3a1e>] packet_rcv+0x254/0x2ab [af_packet]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492428]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492432]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492437]
[<ffffffffa03e2b49>] virtio_rte_recv_packets+0x2c/0x49 [virtio_rte]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492444]
[<ffffffffa03e2b78>] virtio_rte_poll+0x12/0x8c [virtio_rte]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492450]
[<ffffffff81339c88>] net_rx_action+0x65/0x178
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492454]
[<ffffffff81045c73>] __do_softirq+0xb2/0x19d
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492459]
[<ffffffff813f9aac>] call_softirq+0x1c/0x30
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492463]
[<ffffffff81003931>] do_softirq+0x3c/0x7b
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492467]
[<ffffffff81045971>] _local_bh_enable_ip.isra.12+0x75/0x9b
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492472]
[<ffffffffa03d8cdc>] virtio_shm_interrupt.isra.8+0xd6/0xeb
[virtio_shm]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492480]
[<ffffffffa03d8e0c>] virtio_shm_intr_task+0x11b/0x15f [virtio_shm]
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492486]
[<ffffffff8105975a>] kthread+0x76/0x7e
Aug 26 09:31:58 at-vie01a-cq21b kernel: [115452.492491]
[<ffffffff813f99b4>] kernel_thread_helper+0x4/0x10
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404215] BUG: soft
lockup - CPU#31 stuck for 23s! [kni_thread:6605]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404219] Modules linked
in: xt_sharedlimit xt_hashlimit ip_set_hash_ipport
ip_set_hash_ipportip xt_NOTRACK ip_set_bitmap_port xt_sctp
nf_conntrack_ipv6 nf_defrag_ipv6 xt_CT arpt_mangle ip_set_hash_ipnet
xt_NFLOG xt_limit xt_hashcounter ip_set_hash_ipip xt_set
ip_set_hash_ip deflate ctr twofish_x86_64 twofish_common camellia
serpent blowfish cast5 des_generic cbc xcbc rmd160 crypto_null af_key
iptable_mangle ip_set arptable_filter arp_tables iptable_raw
iptable_nat nfnetlink_log nfnetlink ipt_ULOG ipt_PORTMAP af_packet
zlib zlib_deflate sha512_generic sha256_generic sha1_generic md5
icp_qa_al pcie8120 rte_kni pfe_pep virtio_rte virtio_shm virtio_vtnet
virtio_uio igb_uio virtio_ring virtio uio xt_tcpudp xt_state
xt_pkttype nf_conntrack_control bonding binfmt_misc iptable_filter
ip6table_filter ip6_tables nf_nat_ftp nf_nat nf_conntrack_ftp
nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables x_tables mperf ipmi_devintf
ipmi_si ipmi_msghandler edd nf_conntrack_proto_sctp nf_conntrack sctp
8021q garp stp llc gb_sys usb_storage uas iTCO_wdt ioatdma pcspkr
iTCO_vendor_support ixgbe igb wmi i2c_i801 mdio dca sg button
container ipv6 autofs4 usbhid ehci_hcd megasr(P) usbcore processor
thermal_sys
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404306] CPU 31
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404308] Modules linked
in: xt_sharedlimit xt_hashlimit ip_set_hash_ipport
ip_set_hash_ipportip xt_NOTRACK ip_set_bitmap_port xt_sctp
nf_conntrack_ipv6 nf_defrag_ipv6 xt_CT arpt_mangle ip_set_hash_ipnet
xt_NFLOG xt_limit xt_hashcounter ip_set_hash_ipip xt_set
ip_set_hash_ip deflate ctr twofish_x86_64 twofish_common camellia
serpent blowfish cast5 des_generic cbc xcbc rmd160 crypto_null af_key
iptable_mangle ip_set arptable_filter arp_tables iptable_raw
iptable_nat nfnetlink_log nfnetlink ipt_ULOG ipt_PORTMAP af_packet
zlib zlib_deflate sha512_generic sha256_generic sha1_generic md5
icp_qa_al pcie8120 rte_kni pfe_pep virtio_rte virtio_shm virtio_vtnet
virtio_uio igb_uio virtio_ring virtio uio xt_tcpudp xt_state
xt_pkttype nf_conntrack_control bonding binfmt_misc iptable_filter
ip6table_filter ip6_tables nf_nat_ftp nf_nat nf_conntrack_ftp
nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables x_tables mperf ipmi_devintf
ipmi_si ipmi_msghandler edd nf_conntrack_proto_sctp nf_conntrack sctp
8021q garp stp llc gb_sys usb_storage uas iTCO_wdt ioatdma pcspkr
iTCO_vendor_support ixgbe igb wmi i2c_i801 mdio dca sg button
container ipv6 autofs4 usbhid ehci_hcd megasr(P) usbcore processor
thermal_sys
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404373]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404376] Pid: 6605,
comm: kni_thread Tainted: P            3.1.10-gb20-default #1 Intel
Corporation S2600CO/S2600CO
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404380] RIP:
0010:[<ffffffff81020650>]  [<ffffffff81020650>]
__ticket_spin_lock+0x18/0x1b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404389] RSP:
0018:ffff88083ede3cf0  EFLAGS: 00000297
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404391] RAX:
00000000000069bd RBX: 0000000000000000 RCX: 000000000000000e
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404393] RDX:
00000000000069bc RSI: 000000000000000e RDI: ffff88041e56a484
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404395] RBP:
ffff88041e56a484 R08: ffff88041e56a740 R09: ffff880808f20440
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404397] R10:
ffff88080d395084 R11: 000000000000001f R12: ffff88083ede3c68
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404400] R13:
ffffffff813f831e R14: ffff88041e56a484 R15: ffff88080b97d0c0
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404402] FS:
0000000000000000(0000) GS:ffff88083ede0000(0000)
knlGS:0000000000000000
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404405] CS:  0010 DS:
0000 ES: 0000 CR0: 000000008005003b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404407] CR2:
00007f0ad3e5e000 CR3: 0000000001805000 CR4: 00000000000406e0
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404409] DR0:
0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404412] DR3:
0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404414] Process
kni_thread (pid: 6605, threadinfo ffff88080cab8000, task
ffff8808138562c0)
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404416] Stack:
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404418]
ffffffff8106b766 ffffffffa05e3a1e 0000000000000000 0000000000000000
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404424]
0000002e00000000 ffff88042488a000 0000000000000000 ffff88042488a000
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404429]
ffffffff8192a870 0000000000000608 0000000000000000 ffffffff81928b00
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404435] Call Trace:
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404446]
[<ffffffff8106b766>] do_raw_spin_lock+0x5/0x8
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404454]
[<ffffffffa05e3a1e>] packet_rcv+0x254/0x2ab [af_packet]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404477]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404482]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404487]
[<ffffffff8133979e>] napi_skb_finish+0x1c/0x31
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404497]
[<ffffffffa031adee>] igb_clean_rx_irq+0x30d/0x39e [igb]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404517]
[<ffffffffa031aecd>] igb_poll+0x4e/0x74 [igb]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404532]
[<ffffffff81339c88>] net_rx_action+0x65/0x178
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404538]
[<ffffffff81045c73>] __do_softirq+0xb2/0x19d
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404544]
[<ffffffff813f9aac>] call_softirq+0x1c/0x30
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404550]
[<ffffffff81003931>] do_softirq+0x3c/0x7b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404555]
[<ffffffff81045f98>] irq_exit+0x3c/0xac
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404558]
[<ffffffff81003655>] do_IRQ+0x82/0x98
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404565]
[<ffffffff813f24ee>] common_interrupt+0x6e/0x6e
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404573]
[<ffffffffa05e0003>] atomic_inc+0x3/0x4 [af_packet]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404579]
[<ffffffffa05e3a33>] packet_rcv+0x269/0x2ab [af_packet]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404477]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404482]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404487]
[<ffffffff8133979e>] napi_skb_finish+0x1c/0x31
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404589]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404593]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404610]
[<ffffffffa041bd4b>] kni_net_rx_normal+0x12d/0x178 [rte_kni]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404690]
[<ffffffffa041ae58>] kni_thread+0x39/0x91 [rte_kni]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404758]
[<ffffffff8105975a>] kthread+0x76/0x7e
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404763]
[<ffffffff813f99b4>] kernel_thread_helper+0x4/0x10
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404766] Code: b7 c9 40
0f b6 ff 48 89 c2 44 89 ce e9 8e fb ff ff 90 90 b8 00 00 01 00 f0 0f
c1 07 0f b7 d0 c1 e8 10 39 c2 74 07 f3 90 0f b7 17 <eb> f5 c3 8b 07 89
c2 c1 c0 10 39 c2 8d 90 00 00 01 00 75 04 f0
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404795] Call Trace:
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404800]
[<ffffffff8106b766>] do_raw_spin_lock+0x5/0x8
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404805]
[<ffffffffa05e3a1e>] packet_rcv+0x254/0x2ab [af_packet]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404814]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404818]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404822]
[<ffffffff8133979e>] napi_skb_finish+0x1c/0x31
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404831]
[<ffffffffa031adee>] igb_clean_rx_irq+0x30d/0x39e [igb]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404849]
[<ffffffffa031aecd>] igb_poll+0x4e/0x74 [igb]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404863]
[<ffffffff81339c88>] net_rx_action+0x65/0x178
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404868]
[<ffffffff81045c73>] __do_softirq+0xb2/0x19d
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404872]
[<ffffffff813f9aac>] call_softirq+0x1c/0x30
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404875]
[<ffffffff81003931>] do_softirq+0x3c/0x7b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404880]
[<ffffffff81045f98>] irq_exit+0x3c/0xac
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404883]
[<ffffffff81003655>] do_IRQ+0x82/0x98
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404887]
[<ffffffff813f24ee>] common_interrupt+0x6e/0x6e
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404893]
[<ffffffffa05e0003>] atomic_inc+0x3/0x4 [af_packet]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404899]
[<ffffffffa05e3a33>] packet_rcv+0x269/0x2ab [af_packet]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404908]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404912]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404921]
[<ffffffffa041bd4b>] kni_net_rx_normal+0x12d/0x178 [rte_kni]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.404996]
[<ffffffffa041ae58>] kni_thread+0x39/0x91 [rte_kni]
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.405064]
[<ffffffff8105975a>] kthread+0x76/0x7e
Aug 26 09:32:00 at-vie01a-cq21b kernel: [115455.405068]
[<ffffffff813f99b4>] kernel_thread_helper+0x4/0x10
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172014] BUG: soft
lockup - CPU#0 stuck for 22s! [gis:14145]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172017] Modules linked
in: xt_sharedlimit xt_hashlimit ip_set_hash_ipport
ip_set_hash_ipportip xt_NOTRACK ip_set_bitmap_port xt_sctp
nf_conntrack_ipv6 nf_defrag_ipv6 xt_CT arpt_mangle ip_set_hash_ipnet
xt_NFLOG xt_limit xt_hashcounter ip_set_hash_ipip xt_set
ip_set_hash_ip deflate ctr twofish_x86_64 twofish_common camellia
serpent blowfish cast5 des_generic cbc xcbc rmd160 crypto_null af_key
iptable_mangle ip_set arptable_filter arp_tables iptable_raw
iptable_nat nfnetlink_log nfnetlink ipt_ULOG ipt_PORTMAP af_packet
zlib zlib_deflate sha512_generic sha256_generic sha1_generic md5
icp_qa_al pcie8120 rte_kni pfe_pep virtio_rte virtio_shm virtio_vtnet
virtio_uio igb_uio virtio_ring virtio uio xt_tcpudp xt_state
xt_pkttype nf_conntrack_control bonding binfmt_misc iptable_filter
ip6table_filter ip6_tables nf_nat_ftp nf_nat nf_conntrack_ftp
nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables x_tables mperf ipmi_devintf
ipmi_si ipmi_msghandler edd nf_conntrack_proto_sctp nf_conntrack sctp
8021q garp stp llc gb_sys usb_storage uas iTCO_wdt ioatdma pcspkr
iTCO_vendor_support ixgbe igb wmi i2c_i801 mdio dca sg button
container ipv6 autofs4 usbhid ehci_hcd megasr(P) usbcore processor
thermal_sys
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172098] CPU 0
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172099] Modules linked
in: xt_sharedlimit xt_hashlimit ip_set_hash_ipport
ip_set_hash_ipportip xt_NOTRACK ip_set_bitmap_port xt_sctp
nf_conntrack_ipv6 nf_defrag_ipv6 xt_CT arpt_mangle ip_set_hash_ipnet
xt_NFLOG xt_limit xt_hashcounter ip_set_hash_ipip xt_set
ip_set_hash_ip deflate ctr twofish_x86_64 twofish_common camellia
serpent blowfish cast5 des_generic cbc xcbc rmd160 crypto_null af_key
iptable_mangle ip_set arptable_filter arp_tables iptable_raw
iptable_nat nfnetlink_log nfnetlink ipt_ULOG ipt_PORTMAP af_packet
zlib zlib_deflate sha512_generic sha256_generic sha1_generic md5
icp_qa_al pcie8120 rte_kni pfe_pep virtio_rte virtio_shm virtio_vtnet
virtio_uio igb_uio virtio_ring virtio uio xt_tcpudp xt_state
xt_pkttype nf_conntrack_control bonding binfmt_misc iptable_filter
ip6table_filter ip6_tables nf_nat_ftp nf_nat nf_conntrack_ftp
nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables x_tables mperf ipmi_devintf
ipmi_si ipmi_msghandler edd nf_conntrack_proto_sctp nf_conntrack sctp
8021q garp stp llc gb_sys usb_storage uas iTCO_wdt ioatdma pcspkr
iTCO_vendor_support ixgbe igb wmi i2c_i801 mdio dca sg button
container ipv6 autofs4 usbhid ehci_hcd megasr(P) usbcore processor
thermal_sys
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172163]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172166] Pid: 14145,
comm: gis Tainted: P            3.1.10-gb20-default #1 Intel
Corporation S2600CO/S2600CO
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172170] RIP:
0010:[<ffffffff8102064d>]  [<ffffffff8102064d>]
__ticket_spin_lock+0x15/0x1b
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172178] RSP:
0000:ffff88043ee03cf0  EFLAGS: 00000293
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172180] RAX:
00000000000069bf RBX: 00000000020110ac RCX: 000000000000000e
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172182] RDX:
00000000000069bc RSI: 000000000000000e RDI: ffff88041e56a484
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172184] RBP:
ffff88041e56a484 R08: ffff88041e56a740 R09: ffff8804154a5840
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172187] R10:
00007f0afce77000 R11: 0000000000000000 R12: ffff88043ee03c68
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172189] R13:
ffffffff813f831e R14: ffff88041e56a484 R15: ffff88041e568280
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172192] FS:
00007f0afd70b700(0000) GS:ffff88043ee00000(0000)
knlGS:0000000000000000
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172194] CS:  0010 DS:
0000 ES: 0000 CR0: 0000000080050033
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172196] CR2:
00007f54f6b88098 CR3: 000000042427e000 CR4: 00000000000406f0
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172199] DR0:
0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172201] DR3:
0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172204] Process gis
(pid: 14145, threadinfo ffff88037537e000, task ffff88036a8fe180)
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172205] Stack:
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172207]
ffffffff8106b766 ffffffffa05e3a1e 0000000101b72e68 ffff8808260ae680
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172213]
0000002e1e568280 ffff880420450000 ffff88041f887a00 ffff880420450000
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172218]
ffffffff8192a870 0000000000000608 0000000000000000 ffffffff81928b00
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172224] Call Trace:
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172233]
[<ffffffff8106b766>] do_raw_spin_lock+0x5/0x8
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172240]
[<ffffffffa05e3a1e>] packet_rcv+0x254/0x2ab [af_packet]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172257]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172262]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172266]
[<ffffffff8133979e>] napi_skb_finish+0x1c/0x31
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172277]
[<ffffffffa031adee>] igb_clean_rx_irq+0x30d/0x39e [igb]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172298]
[<ffffffffa031aecd>] igb_poll+0x4e/0x74 [igb]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172313]
[<ffffffff81339c88>] net_rx_action+0x65/0x178
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172319]
[<ffffffff81045c73>] __do_softirq+0xb2/0x19d
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172324]
[<ffffffff813f9aac>] call_softirq+0x1c/0x30
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172329]
[<ffffffff81003931>] do_softirq+0x3c/0x7b
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172333]
[<ffffffff81045f98>] irq_exit+0x3c/0xac
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172337]
[<ffffffff81003655>] do_IRQ+0x82/0x98
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172342]
[<ffffffff813f24ee>] common_interrupt+0x6e/0x6e
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172351]
[<00007f0c560356d1>] 0x7f0c560356d0
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172353] Code: ff 45 0f
b7 c9 40 0f b6 ff 48 89 c2 44 89 ce e9 8e fb ff ff 90 90 b8 00 00 01
00 f0 0f c1 07 0f b7 d0 c1 e8 10 39 c2 74 07 f3 90 <0f> b7 17 eb f5 c3
8b 07 89 c2 c1 c0 10 39 c2 8d 90 00 00 01 00
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172382] Call Trace:
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172386]
[<ffffffff8106b766>] do_raw_spin_lock+0x5/0x8
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172392]
[<ffffffffa05e3a1e>] packet_rcv+0x254/0x2ab [af_packet]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172402]
[<ffffffff81337bbf>] __netif_receive_skb+0x2e1/0x36b
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172406]
[<ffffffff81339722>] netif_receive_skb+0x7e/0x84
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172410]
[<ffffffff8133979e>] napi_skb_finish+0x1c/0x31
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172418]
[<ffffffffa031adee>] igb_clean_rx_irq+0x30d/0x39e [igb]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172436]
[<ffffffffa031aecd>] igb_poll+0x4e/0x74 [igb]
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172450]
[<ffffffff81339c88>] net_rx_action+0x65/0x178
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172454]
[<ffffffff81045c73>] __do_softirq+0xb2/0x19d
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172459]
[<ffffffff813f9aac>] call_softirq+0x1c/0x30
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172462]
[<ffffffff81003931>] do_softirq+0x3c/0x7b
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172467]
[<ffffffff81045f98>] irq_exit+0x3c/0xac
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172470]
[<ffffffff81003655>] do_IRQ+0x82/0x98
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172474]
[<ffffffff813f24ee>] common_interrupt+0x6e/0x6e
Aug 26 09:32:01 at-vie01a-cq21b kernel: [115456.172480]
[<00007f0c560356d1>] 0x7f0c560356d0



Judging by the backtrace, this sounds more like some sort of a bug in
the igb network interface driver or the network packet driver
af_packet. Your gis userland process is probably the main thing that
talks to the network on that machine, so it appears connected, but
soft lockups are really kernel space bugs.

is my analysis right?

-- 

Sumit Gemini | Software Engineer
GlobalLogic
www.globallogic.com

http://www.globallogic.com/email_disclaimer.txt
