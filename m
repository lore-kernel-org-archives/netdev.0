From: =?UTF-8?B?5pmB5rC455Sf?= <chaoys155@gmail.com>
Subject: kernel 2.6.31.8 panic in neigh_hh_output
Date: Fri, 10 Feb 2012 15:56:55 +0800
Message-ID: <CAADzPW0U6JgSKFSD_q9RM_vv6x0RZ0-tOMZh8mrMk4d=fzZSYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58851 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871Ab2BJH44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 02:56:56 -0500
Received: by wgbdt10 with SMTP id dt10so2510931wgb.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2012 23:56:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got a kernel panic on my uniprocessor ARM machine. backtrace as follows

PID: 18730  TASK: 98b65c20  CPU: 0   COMMAND: "grep"
 #0 [<8007b6d0>] (crash_kexec) from [<802540d0>]
 #1 [<802540d0>] (panic) from [<80027c74>]
 #2 [<80027c74>] (die) from [<8002ad58>]
 #3 [<8002ad58>] (__do_kernel_fault) from [<8002af74>]
 #4 [<8002af74>] (do_page_fault) from [<80023c0c>]
 #5 [<80023c0c>] (__pabt_svc) from [<8020e9d4>]
 #6 [<8020e9d4>] (ip_finish_output) from [<8020ecf8>]
 #7 [<8020ecf8>] (ip_output) from [<8020ee44>]
 #8 [<8020ee44>] (ip_local_out) from [<80224070>]
 #9 [<80224070>] (__tcp_v4_send_synack) from [<80225ffc>]
#10 [<80225ffc>] (tcp_v4_conn_request) from [<8021eae4>]
#11 [<8021eae4>] (tcp_rcv_state_process) from [<80224f48>]
#12 [<80224f48>] (tcp_v4_do_rcv) from [<80225654>]
#13 [<80225654>] (tcp_v4_rcv) from [<80209c0c>]
#14 [<80209c0c>] (ip_local_deliver_finish) from [<80209f78>]
#15 [<80209f78>] (ip_local_deliver) from [<8020939c>]
#16 [<8020939c>] (ip_rcv_finish) from [<80209874>]
#17 [<80209874>] (ip_rcv) from [<801ebd88>]
#18 [<801ebd88>] (netif_receive_skb) from [<7f0f1aec>]
#19 [<7f0f1aec>] (br_handle_frame_finish [bridge]) from [<7f0f61f0>]
#20 [<7f0f61f0>] (br_nf_pre_routing_finish [bridge]) from [<80203c08>]
#21 [<80203c08>] (nf_reinject) from [<7f2d013c>]
#22 [<7f2d013c>] ($a [wnetacc_drv]) from [<80202a30>]
#23 [<80202a30>] (nf_iterate) from [<80203060>]
#24 [<80203060>] (nf_hook_slow) from [<7f0f687c>]
#25 [<7f0f687c>] (br_nf_pre_routing [bridge]) from [<80202a30>]
#26 [<80202a30>] (nf_iterate) from [<80203060>]
#27 [<80203060>] (nf_hook_slow) from [<7f0f1d3c>]
#28 [<7f0f1d3c>] (br_handle_frame [bridge]) from [<801ebca8>]
#29 [<801ebca8>] (netif_receive_skb) from [<7f002344>]
#30 [<7f002344>] (rtl8168_rx_interrupt [r8168]) from [<7f004ff4>]
#31 [<7f004ff4>] ($a [r8168]) from [<801ec454>]
#32 [<801ec454>] (net_rx_action) from [<8005e0e0>]
#33 [<8005e0e0>] (__do_softirq) from [<8002306c>]
#34 [<8002306c>] (asm_do_IRQ) from [<80023cdc>]
    pc : [<2aab3ee0>]    lr : [<2aab4350>]    psr: 20000010
    sp : 7ed0e728  ip : 7ed0e760  fp : 2aacfe00
    r10: 9e7650bc  r9 : 00000000  r8 : 00000000
    r7 : 00000004  r6 : 2aad06c0  r5 : 00000000  r4 : 2aac7554
    r3 : 00009a30  r2 : 00008594  r1 : 0000837c  r0 : 000088b4
    Flags: nzCv  IRQs on  FIQs on  Mode USER_32  ISA ARM

logs caught by kdump as follows

Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = 836b0000
[00000000] *pgd=0377e031, *pte=00000000, *ppte=00000000
Internal error: Oops: 0 [#1]
Modules linked in: skbdump iptable_filter ipt_REDIRECT xt_mark
dosck_drv reconn_drv ipcomp ip_restore_drv waccvlan_drv asyroute_drv
netdep_drv mactrack_drv wnetacc_drv waccsnat vline intelidentify_drv
urlparse fluxlog_drv sch_ucfq_drv sch_htb_drv tc watch_reboot_drv
helper_binding_drv behaviorskype behavior fw_drv actrace url_handle
contchkdrv proxyconvert_drv netpolicy_drv user_group_drv bypass
arpguard ipctcalls webredirect drop_drv tcp_bic if_custom wano_drv
alarm orion_wdt bridge stp llc ipt_MASQUERADE iptable_nat xt_NOTRACK
xt_state nf_nat_ftp nf_conntrack_ftp nf_nat_h323 nf_nat
nf_conntrack_h323 nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack
ipt_REJECT xt_TCPMSS ipt_LOG xt_comment xt_multiport xt_mac xt_limit
xt_tcpudp ip_tables x_tables r8168 [last unloaded: iptable_filter]
CPU: 0    Not tainted  (2.6.31.8 #5)
PC is at 0x0
LR is at ip_finish_output+0x470/0x500
pc : [<00000000>]    lr : [<8020e9d4>]    psr: 20000013
sp : 837cf640  ip : 9b864c00  fp : 98acd380
r10: 00000006  r9 : 9b864cb4  r8 : 98ba9594
r7 : 00000000  r6 : 00000000  r5 : 98acd380  r4 : 98ba9580
r3 : 00000200  r2 : 837ce000  r1 : 837ce000  r0 : 98acd380
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 0005397f  Table: 036b0000  DAC: 00000015
Process grep (pid: 18730, stack limit = 0x837ce270)
Stack: (0x837cf640 to 0x837d0000)
f640: 00000001 000000be 000000be 000000c2 000000be 00000015 000000be 000000c0
f660: 000000be 000000c1 0000c8a2 80203060 8e27d000 8373ef00 00000000 0000000e
f680: c1bec0be bec2bebe 9b864cb4 000000be 000000c0 000000be 000000bf 000000be
f6a0: 98acd380 00000006 9b864cb4 8020ecf8 8e27d000 8020e564 80000000 000000be
f6c0: 000000bf 00001770 000000be 000000c0 000000be 000000c1 0000c8a2 98acd380
f6e0: bfbec0be 8e27d000 c1bec0be bfbec0be 8373ef00 98acd380 bfbec0be 0000001c
f700: 9b864cb4 98acd380 8373ef00 9f10cde0 9889c880 8020ee44 c1bec0be 80224070
f720: 00000000 9f10cde0 00000000 00000000 9f10cde0 00000000 89a8ac40 2e498bbe
f740: 00000000 9889c880 bfbec0be 80225ffc 837cf770 00000000 8033e5d4 8005a380
f760: 803402f2 a0000013 80000010 05b40000 00000000 c1bec0be 803402f2 00000000
f780: 9889c880 89a8ac40 991e4844 00000010 991e4844 991e4830 89a8ac40 8021eae4
f7a0: 9889c880 89a8ac40 9889c880 991e4844 00000010 80224f48 bfbec0be 00001770
f7c0: 00000010 991e4844 00000010 800a8f40 00000000 9889c880 bfbec0be 00001770
f7e0: 991e4844 80225654 00000010 00001770 00000010 000000be 000000c1 0000c8a2
f800: 000000be 000000c0 000000be 000000bf 00001770 000000be bfbec0be c1bec0be
f820: 89a8ac40 80339d58 000000c0 000000be 000000c1 000000be 991e4844 00000006
f840: 89a8ac40 80209c0c 00000001 000000be 000000c0 000000be 000000c1 0000c8a2
f860: 000000be 000000c0 000000be 000000bf 00001770 80000000 bfbec0be c1bec0be
f880: 991e4844 000000be 000000c0 000000be 000000c1 000000be 89a8ac40 00000006
f8a0: 991e4844 80209f78 00000000 802098e0 80000000 000000be 000000c1 0000c8a2
f8c0: 000000be 000000c0 000000be 000000bf 00001770 00000006 bfbec0be c1bec0be
f8e0: 991e4844 000000be 000000c0 000000be 000000c1 00000006 89a8ac40 991e4830
f900: 991e4844 8020939c 00000001 000000be 000000c0 000000be 000000c1 0000c8a2
f920: 000000be 000000c0 000000be 000000bf 00001770 80000000 bfbec0be c1bec0be
f940: 89a8ac40 000000be 000000c0 000000be 000000c1 000000be 991e4844 00000006
f960: 89a8ac40 80209874 00000000 80208e6c 80000000 000000be 000000c1 0000c8a2
f980: 000000be 000000c0 000000be 000000bf 00001770 89a8ac40 00000001 8e27d000
f9a0: bfbec0be c1bec0be 00000000 8034fbe0 00000008 8e27d000 8034fc00 00000000
f9c0: 00000014 00000000 98acd1c0 801ebd88 89a8ac40 00000001 00000007 89a8ac40
f9e0: 89a8ac40 00000000 96d9af00 8e27d2c0 00000000 7f0f1aec 00000000 801eb9ec
fa00: 80000000 00000000 00000000 991e4830 89a8ac40 98ba9400 8e27d000 7f0f61f0
fa20: 00000000 7f0f19c0 00000001 00000020 00000060 0000c8a2 b85ea5b1 000000bf
fa40: 000000be 8e27d000 00000000 8034ffb4 00000001 00000000 9f10ccf8 9f10cce8
fa60: 9f10ccf8 7f2c8a24 bfbec0be c1bec0be 8031a2e4 c1bec0be 00000001 c1bec0be
fa80: 00000001 98ba94c0 89a8ac40 00000000 00000001 80203c08 00000000 837cfaac
faa0: 7f0f5efc 80000000 89a8ac40 8034ffb4 00000000 c1bec0be bec2bebe 0000a2c8
fac0: 00001500 7f2d013c 837cfc78 00000002 bec2bebe c1bec0be 83704a4a 0000002c
fae0: 8e27d000 98acd1c0 7f32d4b0 98acd1c0 7f3469e4 83704a36 00000005 83704a4a
fb00: 83704a36 7f2eee90 7f2eeecc 83704a46 80000000 00000014 00000001 7f000000
fb20: e59c400c c1bec0be 83704a4a 00000000 00000001 83704a4a 83704a36 0c680000
fb40: 98ba94c0 89a8ac40 991e4844 991e4830 837cfc4c 8031c780 00000001 837cfc18
fb60: 60000013 83704a42 80000000 80023230 00000001 8034ffc4 80208e6c 988a3836
fb80: 98acd2c4 8e27d000 8034fc00 836cc000 98acd2a0 7f3469e4 98acd2a0 8020b540
fba0: 8e27d000 ffffffff 837cfbf4 98acd1c0 83704a36 00001500 0000a2c8 800239cc
fbc0: 98acd1c0 00001500 0000a2c8 c1bec0be bec2bebe 1500a2c8 bfc2bebe 89a4d600
fbe0: 60cfa19c 39d0d03f 00000100 00000002 00000000 bec2bebe bec2bebe c1bec0be
fc00: 00000038 7f323604 83704a36 7f3469e4 0000002c 800239cc 83704a4a 9498b042
fc20: c1bec0be bec2bebe 1500a2c8 bec2bebe c1bec0be a2c81500 00000000 00000000
fc40: 00000000 c1bec0be bec2bebe 1500a2c8 bfc2bebe 18150c91 60cfa19c bfc2bebe
fc60: 00000000 00000000 00000000 00000000 00000000 00000000 00000100 89a4d600
fc80: 837cfd7c 98acd1c0 00000000 00000002 00000001 8e27d000 98acd1c0 7f2ea4c0
fca0: 80000000 80202a30 7f0f5efc 8e27d000 8034fc00 00000000 98acd2a0 7f0fc1b8
fcc0: 80000000 801ebd88 98acd2a0 00000001 00000007 98acd2a0 98acd2a0 00000000
fce0: 96d9af00 8e27d2c0 00000000 7f0f1aec 00000000 801eb9ec 80000000 8e27d000
fd00: 00000000 8034ffb4 00000001 00000000 8e27d000 7f0f61f0 00000000 7f0f19c0
fd20: 00000001 7f0f61f0 00000000 98acd1c0 00000000 00000002 8034ffb4 8e27d000
fd40: 00000000 7f0f5efc 80000000 80203060 00000000 837cfd64 7f0f5efc 80000000
fd60: 00000007 7f2ea4c0 9b808000 98acd1c0 00000000 00000007 803500f4 9b808000
fd80: 98acd1c0 7f0fc1b8 80000000 7f0f687c 00000000 7f0f5efc 80000000 7f0f688c
fda0: 00000000 98acd1c0 00000000 00000007 803500f4 80202a30 7f0f19c0 00000007
fdc0: 803500f4 80202a30 7f0f19c0 80350104 00000001 00000000 98833830 8022d0cc
fde0: 8e27d000 00000003 8034fff4 8e27d000 00000000 98acd540 00000002 00000007
fe00: 80350104 9f044800 9b808000 9b808000 00000000 803500f4 00000001 00000000
fe20: 00000000 803500f4 00000001 00000000 fe464646 98acd540 9afdfb40 98acd1c0
fe40: 00000000 00000007 803500f4 9b808000 00000000 7f0f19c0 80000000 80203060
fe60: 00000000 837cfe74 7f0f19c0 80000000 80668460 7f0fc1b8 801e62e4 00008001
fe80: 83704a28 98acd1c0 9afdfb40 00000000 0000004e ffc08000 0000f1af 7f0f1d3c
fea0: 00000000 7f0f19c0 80000000 98acd1c0 9b8082c0 98acd1c0 00000001 9b808000
fec0: 9afdfb40 801ebca8 98acd1c0 0000f77f 08000000 98acd1c0 98acd1c0 9b8082c0
fee0: 98acd1c0 9b808000 000001af 7f002344 9f824200 0000003f ffc09af0 000005f3
ff00: 9a9213c0 9b8082c0 00000040 00000040 9b808000 000000ea 9b8082cc 005b9eb3
ff20: 00000040 7f004ff4 9b8082cc a0954000 9b8082cc 9b8082cc 00000040 00000040
ff40: 0000000c 000000ea 00000001 005b9eb3 2aacfe00 801ec454 00000100 837ce000
ff60: 00000021 0000000c 00000003 00000001 80342a00 8005e0e0 0000000b 837ce000
ff80: 0000000b 00000000 00000800 00000004 00000000 837ce000 9e7650bc 8002306c
ffa0: ffffffff 0000001f 00000800 80023cdc 000088b4 0000837c 00008594 00009a30
ffc0: 2aac7554 00000000 2aad06c0 00000004 00000000 00000000 9e7650bc 2aacfe00
ffe0: 7ed0e760 7ed0e728 2aab4350 2aab3ee0 20000010 ffffffff 00000000 00000000
Code: bad PC value.
Kernel panic - not syncing: Fatal exception in interrupt
Loading crashdump kernel...

It was caught by  kdump, and I don't known how it happened. It seems
not reproducible.

I found it panic at the line in neigh_hh_output : return hh->hh_output(skb);
where hh_output is NULL.  Even the whole hh_cache( 0x98ba9580 ) is 0.
following is a piece from the slab kmalloc-64
0x98ba9500:     0x00000001      0x9b808000      0x00000000      0x00000000
0x98ba9510:     0x7edaa177      0x00000000      0x00000000      0x00000000
0x98ba9520:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9530:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9540:     0x00000001      0x9f044800      0x00000000      0x00000000
0x98ba9550:     0xbec2bebe      0x00000000      0x00000000      0x00000000
0x98ba9560:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9570:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9580:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9590:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba95a0:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba95b0:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba95c0:     0x00000001      0x00000000      0x8e347a48      0x00000000
0x98ba95d0:     0x00000000      0x00000002      0x00000002      0x00000d26
0x98ba95e0:     0x80320ef8      0x00000000      0x8075d2d4      0x00000000
0x98ba95f0:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9600:     0xffffffff      0xffffffff      0x00ffffff      0x00000000
0x98ba9610:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9620:     0x70100000      0x0000000f      0x00000000      0x00000000
0x98ba9630:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9640:     0x00000001      0x00000000      0x00000000      0x00000000
0x98ba9650:     0x00000000      0x9f9282f8      0x80068d64      0x00004927
0x98ba9660:     0x80320ef8      0x00000000      0x00200200      0x00000000
0x98ba9670:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba9680:     0x00000001      0x00000000      0x00000000      0x00000000
0x98ba9690:     0x00000000      0x9f84d298      0x80068d64      0x00004928
0x98ba96a0:     0x80320ef8      0x00000000      0x00200200      0x00000000
0x98ba96b0:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba96c0:     0x00000001      0x9f044800      0x9b808000      0x00000008
0x98ba96d0:     0x400d0de1      0x00000000      0x00000000      0x00000000
0x98ba96e0:     0x00000000      0x00000000      0x00000000      0x00000000
0x98ba96f0:     0x00000000      0x00000000      0x00000000      0x00000000

the dst_entry pointing to the hh_cache is:
crash> dst_entry 8373ef00
struct dst_entry {
  rcu_head = {
    next = 0x0,
    func = 0
  },
  child = 0x0,
  dev = 0x8e27d000,
  error = 0,
  obsolete = 0,
  flags = 1,
  expires = 0,
  header_len = 0,
  trailer_len = 0,
  rate_tokens = 0,
  rate_last = 0,
  path = 0x8373ef00,
  neighbour = 0x98adae80,
  hh = 0x98ba9580,
  xfrm = 0x0,
  input = 0x801f17f4 <dst_discard>,
  output = 0x8020ea64 <ip_output>,
  ops = 0x803388d0,
  metrics = {0, 1500, 0, 230, 130, 2, 3, 1460, 0, 64, 0, 0, 0},
  tclassid = 0,
  __pad_to_align_refcnt = {0},
  __refcnt = {
    counter = 4
  },
  __use = 21,
  lastuse = 6004476,
  {
    next = 0x0,
    rt_next = 0x0,
    rt6_next = 0x0,
    dn_next = 0x0
  }
}

and the neighbour is:

crash> neighbour 0x98adae80
struct neighbour {
  next = 0x0,
  tbl = 0x803395b8,
  parms = 0x99b50660,
  dev = 0x8e27d000,
  used = 6003450,
  confirmed = 6003712,
  updated = 6001307,
  flags = 0 '\000',
  nud_state = 2 '\002',
  type = 1 '\001',
  dead = 0 '\000',
  probes = {
    counter = 0
  },
  lock = {
    raw_lock = {<No data fields>}
  },
  ha = "\000\034%\337^\300\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  hh = 0x98ba9580,
  refcnt = {
    counter = 7
  },
  output = 0x801f33ac <neigh_resolve_output>,
  arp_queue = {
    next = 0x98adaed0,
    prev = 0x98adaed0,
    qlen = 0,
    lock = {
      raw_lock = {<No data fields>}
    }
  },
  timer = {
    entry = {
      next = 0x7f250f24,
      prev = 0x9f0f7e24
    },
    expires = 6005120,
    function = 0x801f5150 <neigh_timer_handler>,
    data = 2561519232,
    base = 0x80342ba0
  },
  ops = 0x803396cc,
  primary_key = 0x98adaef8 "\276\300\276\301"
}

I thought it was due to memory corruption. So
I checked the 64 bytes before hh_cache (0x98ba9580), it seems a nf_bridge_info;
and the 64 bytes after hh_cache , it seems a pid.
But the nf_bridge_info and pid both seem ok.
I don't known what to do now. why the hh_cache was zeroed while
neighbour is reachable?
Help.
--
Thanks a lot!
