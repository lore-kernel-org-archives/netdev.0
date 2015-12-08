From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 109071] New: Kernel bug in skbuff.c: BUG_ON(len) crashes
 in combination with IPv6 and GRE tunnels
Date: Tue, 8 Dec 2015 08:22:43 -0800
Message-ID: <20151208082243.3519a7c9@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33896 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757055AbbLHQWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 11:22:35 -0500
Received: by pacwq6 with SMTP id wq6so14171236pac.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 08:22:34 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id b15sm5775559pfj.7.2015.12.08.08.22.33
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:22:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 8 Dec 2015 13:26:51 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 109071] New: Kernel bug in skbuff.c: BUG_ON(len) crashes in combination with IPv6 and GRE tunnels


https://bugzilla.kernel.org/show_bug.cgi?id=109071

            Bug ID: 109071
           Summary: Kernel bug in skbuff.c: BUG_ON(len) crashes in
                    combination with IPv6 and GRE tunnels
           Product: Networking
           Version: 2.5
    Kernel Version: Linux skjennungen.simula.nornet 4.2.0-19-generic
                    #23~14.04.1-Ubuntu SMP Thu Nov 12 12:33:30 UTC 2015
                    x86_64 x86_64 x86_64 GNU/Linux
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: dreibh@iem.uni-due.de
        Regression: No

I use a machine with kernel 4.2.0 (64 bit, Ubuntu 14.04) that has 6 Ethernet
interfaces. The machine is running von KVM VM, five of the interfaces are
bridged into the VM. The VM also runs Ubuntu 14.04, 64 bit with the same
kernel. Over the virtual interfaces, the VM creates GRE tunnels transporting
IPv4 and IPv6 packets. GRE is used with key, but without checksum => MTU is
1472 bytes.

The following kernel crashes happen quite frequently with several machines:

[ 1881.204653] kernel BUG at
/build/linux-lts-wily-1zclH3/linux-lts-wily-4.2.0/net/core/skbuff.c:2097!
[ 1881.204784] invalid opcode: 0000 [#1] SMP 
[ 1881.204853] Modules linked in: vhost_net vhost macvtap macvlan
ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat
nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT
nf_reject_ipv4 xt_CHECKSUM iptable_mangle xt_tcpudp ip6table_filter ip6_tables
iptable_filter ip_tables ebtable_nat ebtables x_tables autofs4 deflate ctr
twofish_generic twofish_x86_64_3way twofish_x86_64 twofish_common
camellia_generic camellia_x86_64 serpent_sse2_x86_64 xts serpent_generic
blowfish_generic blowfish_x86_64 blowfish_common cast5_generic cast_common
des_generic cmac xcbc rmd160 crypto_null af_key xfrm_algo nfsd auth_rpcgss
nfs_acl nfs lockd grace sunrpc fscache intel_powerclamp coretemp kvm_intel
gpio_ich amdkfd amd_iommu_v2 kvm radeon ipmi_ssif crct10dif_pclmul crc32_pclmul
aesni_intel
[ 1881.206234]  aes_x86_64 bridge input_leds lrw stp joydev gf128mul llc
glue_helper ablk_helper ttm cryptd drm_kms_helper drm serio_raw i2c_algo_bit
hpilo ipmi_si lpc_ich ipmi_msghandler i7core_edac 8250_fintek mac_hid edac_core
shpchp dummy lp parport reiserfs hid_generic psmouse pata_acpi usbhid hid tg3
e1000e ptp pps_core
[ 1881.206839] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G          I    
4.2.0-19-generic #23~14.04.1-Ubuntu
[ 1881.206975] Hardware name: HP ProLiant DL320 G6, BIOS W07 07/02/2013
[ 1881.207066] task: ffff88020e29b200 ti: ffff88020e2ac000 task.ti:
ffff88020e2ac000
[ 1881.207173] RIP: 0010:[<ffffffff8169eb59>]  [<ffffffff8169eb59>]
__skb_checksum+0x2c9/0x2d0
[ 1881.207304] RSP: 0018:ffff8802174c35e8  EFLAGS: 00010286
[ 1881.207381] RAX: ffff8800c2a86840 RBX: 00000000fffef742 RCX:
ffff8801eff52000
[ 1881.207483] RDX: 0000000000000001 RSI: 0000000000000000 RDI:
ffff88020e29b200
[ 1881.207593] RBP: ffff8802174c3658 R08: ffff8802174c3668 R09:
0000000000000000
[ 1881.207725] R10: 0000000000000000 R11: 0000000000000040 R12:
0000000000000000
[ 1881.207826] R13: 00000000fffef742 R14: 00000000fffef742 R15:
0000000000000001
[ 1881.207928] FS:  0000000000000000(0000) GS:ffff8802174c0000(0000)
knlGS:0000000000000000
[ 1881.208045] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1881.208126] CR2: 00000000028d3000 CR3: 0000000001c0d000 CR4:
00000000000026e0
[ 1881.208227] Stack:
[ 1881.208257]  ffff8802174d6640 0000000000000046 ffff88020e29b200
ffff88020e29b200
[ 1881.208378]  ffff8800fffef742 ffff8801eff52000 0000000000000000
ffff8802174c3668
[ 1881.208500]  ffff8802174c3648 ffff8801eff52000 0000000000000001
ffff8800c2a87660
[ 1881.208622] Call Trace:
[ 1881.208660]  <IRQ> 
[ 1881.208712]  [<ffffffff8169eb86>] skb_checksum+0x26/0x30
[ 1881.208800]  [<ffffffff8169bc10>] ? skb_push+0x40/0x40
[ 1881.208878]  [<ffffffff8169b920>] ? reqsk_fastopen_remove+0x160/0x160
[ 1881.208971]  [<ffffffff8178dfda>] udp6_ufo_fragment+0xba/0x2e0
[ 1881.209061]  [<ffffffff810b6bf5>] ? __wake_up_common+0x55/0x90
[ 1881.209147]  [<ffffffff8178d9d9>] ipv6_gso_segment+0x109/0x2a0
[ 1881.209235]  [<ffffffff816b1eb5>] skb_mac_gso_segment+0x95/0xf0
[ 1881.209324]  [<ffffffff81733f57>] gre_gso_segment+0x167/0x440
[ 1881.209408]  [<ffffffff817b013c>] ? __slab_free+0x104/0x25c
[ 1881.209491]  [<ffffffff817249d3>] inet_gso_segment+0x163/0x360
[ 1881.209578]  [<ffffffff816b1eb5>] skb_mac_gso_segment+0x95/0xf0
[ 1881.209665]  [<ffffffff816b1f73>] __skb_gso_segment+0x63/0x90
[ 1881.209747]  [<ffffffff816b22a3>]
validate_xmit_skb.isra.101.part.102+0x123/0x2b0
[ 1881.209894]  [<ffffffff816b280f>] validate_xmit_skb_list+0x3f/0x60
[ 1881.214432]  [<ffffffff816d451d>] sch_direct_xmit+0xcd/0x1e0
[ 1881.218910]  [<ffffffffc06f029a>] ? ebt_do_table+0x55a/0x64c [ebtables]
[ 1881.223445]  [<ffffffff816d46c3>] __qdisc_run+0x93/0x1b0
[ 1881.227887]  [<ffffffff816b2bec>] __dev_queue_xmit+0x2cc/0x550
[ 1881.232311]  [<ffffffff816b2e83>] dev_queue_xmit_sk+0x13/0x20
[ 1881.236629]  [<ffffffffc02acbd5>] br_dev_queue_push_xmit+0x125/0x170
[bridge]
[ 1881.240936]  [<ffffffffc02acd7a>] br_forward_finish+0x2a/0x80 [bridge]
[ 1881.245106]  [<ffffffff813b21d1>] ? csum_partial+0x11/0x20
[ 1881.249207]  [<ffffffffc02acab0>] ? deliver_clone+0x60/0x60 [bridge]
[ 1881.253138]  [<ffffffffc02ace58>] __br_forward+0x88/0x110 [bridge]
[ 1881.257012]  [<ffffffffc02ad287>] br_forward+0x87/0xa0 [bridge]
[ 1881.260788]  [<ffffffffc02ae135>] br_handle_frame_finish+0x145/0x580
[bridge]
[ 1881.264474]  [<ffffffffc06d704a>] ? ebt_nat_in+0x2a/0x30 [ebtable_nat]
[ 1881.268071]  [<ffffffff816e3c51>] ? nf_iterate+0x51/0x80
[ 1881.271503]  [<ffffffff816e3ceb>] ? nf_hook_slow+0x6b/0xc0
[ 1881.274842]  [<ffffffffc02ae6b6>] br_handle_frame+0x146/0x270 [bridge]
[ 1881.278191]  [<ffffffffc02adff0>] ? br_handle_local_finish+0x80/0x80
[bridge]
[ 1881.281467]  [<ffffffff816b0182>] __netif_receive_skb_core+0x1d2/0x9a0
[ 1881.284760]  [<ffffffffc0065935>] ? e1000_alloc_rx_buffers+0x75/0x240
[e1000e]
[ 1881.287985]  [<ffffffff816b0968>] __netif_receive_skb+0x18/0x60
[ 1881.291180]  [<ffffffff816b09d3>] netif_receive_skb_internal+0x23/0x80
[ 1881.294432]  [<ffffffff816b0b28>] napi_gro_complete+0x98/0xd0
[ 1881.297602]  [<ffffffff816b0bc3>] napi_gro_flush+0x63/0x90
[ 1881.300746]  [<ffffffff816b0c57>] napi_complete_done+0x67/0xa0
[ 1881.303959]  [<ffffffffc006a25a>] e1000e_poll+0xba/0x2a0 [e1000e]
[ 1881.307091]  [<ffffffff817bd5fa>] ? do_IRQ+0x5a/0xe0
[ 1881.310220]  [<ffffffff816b0ddc>] net_rx_action+0x14c/0x320
[ 1881.313279]  [<ffffffff8107b3d2>] __do_softirq+0xd2/0x250
[ 1881.316251]  [<ffffffff8107b785>] irq_exit+0x95/0xa0
[ 1881.319260]  [<ffffffff817bd5fa>] do_IRQ+0x5a/0xe0
[ 1881.322196]  [<ffffffff817bb56b>] common_interrupt+0x6b/0x6b
[ 1881.325155]  <EOI> 
[ 1881.325189]  [<ffffffff810ef0a8>] ? tick_program_event+0x48/0x80
[ 1881.331038]  [<ffffffff81654c45>] ? cpuidle_enter_state+0xb5/0x220
[ 1881.334028]  [<ffffffff81654c24>] ? cpuidle_enter_state+0x94/0x220
[ 1881.337006]  [<ffffffff81654de7>] cpuidle_enter+0x17/0x20
[ 1881.339936]  [<ffffffff810b76eb>] call_cpuidle+0x3b/0x70
[ 1881.342872]  [<ffffffff81654dc3>] ? cpuidle_select+0x13/0x20
[ 1881.345855]  [<ffffffff810b798c>] cpu_startup_entry+0x26c/0x330
[ 1881.348761]  [<ffffffff8104b1a5>] start_secondary+0x175/0x1a0
[ 1881.351699] Code: e8 2d 89 9d ff 8b 45 9c e9 ab fe ff ff be 20 08 00 00 48
c7 c7 c0 78 b4 81 44 89 55 c0 e8 10 89 9d ff 44 8b 55 c0 e9 05 ff ff ff <0f> 0b
0f 1f 44 00 00 66 66 66 66 90 55 48 89 e5 48 83 ec 10 4c 
[ 1881.358334] RIP  [<ffffffff8169eb59>] __skb_checksum+0x2c9/0x2d0
[ 1881.361567]  RSP <ffff8802174c35e8>


Line 2097 in skbuff.c is:
BUG_ON(len);

The problem seems to be somewhere in receive offloading, related to IPv6 and
the tunnels, and possibly related to KVM. I also noticed similar (possibly the
same) issue when using VirtualBox instead of KVM (see
https://www.virtualbox.org/ticket/14779 with the VirtualBox bug report).

If necessary, I can provide plenty of Kdump-generated kernel dumps.

-- 
You are receiving this mail because:
You are the assignee for the bug.
