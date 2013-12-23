From: Sasikanth babu <sasikanth.v19@gmail.com>
Subject: IPV6: ip6_pol_route panic when doing interface up and down
 continuously with ipv6 traffic
Date: Mon, 23 Dec 2013 11:48:00 +0530
Message-ID: <CAOJFanWCwFuX8X0ubNXAaVma0XMwtW4Q5vG=ENvqWp0kYBaSzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: "open list:ETHERNET BRIDGE" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:64995 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757049Ab3LWGSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 01:18:00 -0500
Received: by mail-oa0-f43.google.com with SMTP id i7so5321913oag.30
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 22:18:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been getting two kernel panics in ipv6 stack with 2.6.34.10
kernel. One in ip6_pol_route and other one is in ip6_pkt_drop
function. It is being observed when we did interface up and down
continuously while ipv6 traffic going on.

I looked out for the patches and verified the kernel commit messages I
could not find anything related to these panics.

Any suggestions?

Thanks in advance

Kernel : 2.6.34.10
arch:   Mips

Panic 1
======

[ 3634.197613] $ 4   : 0000000000000000 0000000000000010
0000000000000001 a8000003916a38a0
[ 3634.205678] $ 8   : 0000000000000000 0000000000000001
0000000120467b60 0000000120467b61
[ 3634.213744] $12   : 0000000000000002 0000000000000010
ffffffff806c2318 0000000000000000
[ 3634.221809] $16   : a80000043fe44600 0000000000000001
0000000000000010 a80000043fe44600
[ 3634.229874] $20   : ffffffffffffffff a80000044080ff78
ffffffffffffffff a8000003916a3adc
[ 3634.237940] $24   : 0000000000000000 ffffffff80790550
[ 3634.246006] $28   : a8000003916a0000 a8000003916a38a0
ffffffff81221f70 ffffffff80782c38
[ 3634.254071] Hi    : 0000000000000000
[ 3634.257645] Lo    : 00000000000005a0
[ 3634.261230] epc   : ffffffff80782d68 ip6_pol_route+0x230/0x380
[ 3634.267064]     Not tainted
[ 3634.269860] ra    : ffffffff80782c38 ip6_pol_route+0x100/0x380
[ 3634.275692] Status: 10008ce3    KX SX UX KERNEL EXL IE
[ 3634.281003] Cause : 00800008
[ 3634.283882] BadVA : 0000000000000388
[ 3634.287458] PrId  : 000d910a (Cavium Octeon II)
[ 3634.291988] Modules linked in: ip_tables iptable_filter
iptable_mangle ip6_tables ip6table_filter ip6table_mangle mloopback
bonding bfpga octeon_pow_ether nfnetlink nfnetlink_queue xt_DSCP
xt_NFQUEUE [last unloaded: scsi_wait_scan]
[ 3634.312705] Process nsm (pid: 1265, threadinfo=a8000003916a0000,
task=a80000043f96b480, tls=0000005562c812f0)
[ 3634.322620] Stack : ffffffff00000000 0000033be70819ff
0000000000000000 0000000000000001
[ 3634.330499]         a8000003916a3acc a80000044080ff78
0000000100000000 0000000000000003
[ 3634.338563]         a80000044080ff74 0000000ff8bc5410
ffffffff80782eb8 a80000043fe6d6c0
[ 3634.346628]         a8000003916a39e0 a8000003916a3ac0
ffffffff81221f70 0000000000000001
[ 3634.354692]         a8000003916a39e0 0000000000000003
fffffffffffffff5 ffffffff807a5894
[ 3634.362757]         a8000001c0007000 a80000043f96b480
0000000000000000 a80000043fe6d6c0
[ 3634.370821]         a8000003916a3ac0 0000000000000002
a80000043fe6d600 0000000000000001
[ 3634.378885]         a80000043fe6d678 ffffffff806e8f14
ffffffff81221f70 a8000003916a3ac0
[ 3634.386950]         ffffffff81221f70 a8000001c0198400
0000000000000000 fffffffffffffff2
[ 3634.395014]         a8000001c0198700 a8000003916a3a80
0000000000000000 ffffffff807a59c8
[ 3634.403079]         ...
[ 3634.405734] Call Trace:
[ 3634.408185] [<ffffffff80782d68>] ip6_pol_route+0x230/0x380
[ 3634.413675] [<ffffffff807a5894>] fib6_rule_action+0xbc/0x1c8
[ 3634.419340] [<ffffffff806e8f14>] fib_rules_lookup+0x12c/0x1b8
[ 3634.425089] [<ffffffff807a59c8>] fib6_rule_lookup+0x28/0xa8
[ 3634.430663] [<ffffffff80773b54>] ip6_dst_lookup_tail+0x144/0x158
[ 3634.436673] [<ffffffff80790858>] rawv6_sendmsg+0x308/0xd90
[ 3634.442162] [<ffffffff806c17d0>] sock_sendmsg+0x80/0xb8
[ 3634.447389] [<ffffffff806c24f0>] SyS_sendmsg+0x1d8/0x320
[ 3634.452706] [<ffffffff802cfcc4>] handle_sys64+0x44/0x60
[ 3634.457931]
[ 3634.459421]
[ 3634.459422] Code: de620018  dfd00388  dc4204c8 <dc480388> 1208ffd1
00000000  8d0200f8  e858002d  dfa30010
[ 3634.470779] Disabling lock debugging due to kernel taint
[ 3634.476122] Kernel panic - not syncing: Fatal exception in interrupt


Panic 2
=======

[ 7078.035218] Oops[#1]:
[ 7078.037492] Cpu 0
[ 7078.039416] $ 0   : 0000000000000000 000000000000000c
a8000000e2f3f000 0000000100000060
[ 7078.047482] $ 4   : 00000000ffffff00 0000000000000000
0000000000000020 0000000000000160
[ 7078.055546] $ 8   : 0000000000000100 000000000000000c
0000000060300000 ffffffff80000000
[ 7078.063611] $12   : 0000000000000018 ffffffff8055d950
ffffffff806c2318 0000000000000000
[ 7078.071677] $16   : a800000195fda500 a80000043fe44600
0000000000000000 0000000000000001
[ 7078.079742] $20   : 0000000000000000 a800000195fda100
0000000000000001 ffffffff81221f70
[ 7078.087807] $24   : 2000000000000000 ffffffff8077fb38
[ 7078.095872] $28   : a8000003bd5bc000 a8000003bd5bf8a0
a8000003bd5bf9d0 ffffffff8077f9a0
[ 7078.103937] Hi    : 0000000000000000
[ 7078.107511] Lo    : 0000000000000420
[ 7078.111095] epc   : ffffffff8077fa28 ip6_pkt_drop+0x110/0x1e0
[ 7078.116841]     Not tainted
[ 7078.119636] ra    : ffffffff8077f9a0 ip6_pkt_drop+0x88/0x1e0
[ 7078.125295] Status: 10108ce3    KX SX UX KERNEL EXL IE
[ 7078.130605] Cause : 00800008
[ 7078.133485] BadVA : 0000000100000068
[ 7078.137060] PrId  : 000d910a (Cavium Octeon II)
[ 7078.141590] Modules linked in: ip_tables iptable_filter
iptable_mangle ip6_tables ip6table_filter ip6table_mangle mloopback
bonding bfpga octeon_pow_ether nfnetlink nfnetlink_queue xt_DSCP
xt_NFQUEUE [last unloaded: scsi_wait_scan]
[ 7078.162303] Process wamgr (pid: 1087, threadinfo=a8000003bd5bc000,
task=a80000043edc5400, tls=000000555d1192b0)
[ 7078.172391] Stack : 0000000000000004 a800000195fda500
a800000195f83000 a800000195fda500
[ 7078.180270]         a80000043fda2900 ffffffff806fda9c
ffffffff81116f18 a800000188cfe010
[ 7078.188335]         0000000000000001 a80000018aa9e414
a80000043fda2940 a8000003bd5bf960
[ 7078.196399]         a800000195f83000 ffffffffc00add20
0020000000000000 a80000018aa9e400
[ 7078.204463]         a800000195fda100 a80000018aa9e400
a800000195fda100 ffffffffc00ae788
[ 7078.212527]         ffffffffc00ae8b8 a8000003bd5bf9d0
a800000195fda100 ffffffffc00a43bc
[ 7078.220592]         0000000000000000 0000000000000000
a80000018aa9e414 0000000000000000
[ 7078.228656]         0000000000000000 0000000000000000
0000000000000000 0000000000000000
[ 7078.236720]         0000000000000000 0000000000000000
0000000000000000 a8000003bd5bf930
[ 7078.244784]         ffffffff803b0c68 00000000ffffff01
a80000018aa9e414 0000000000000020
[ 7078.252848]         ...
[ 7078.255502] Call Trace:
[ 7078.257951] [<ffffffff8077fa28>] ip6_pkt_drop+0x110/0x1e0
[ 7078.263353] [<ffffffff806fda9c>] nf_reinject+0x9c/0x180
[ 7078.268585] [<ffffffffc00add20>] nfqnl_recv_verdict+0x2a8/0x368
[nfnetlink_queue]
[ 7078.276074] [<ffffffffc00a43bc>] nfnetlink_rcv_msg+0x21c/0x320 [nfnetlink]
[ 7078.282950]
[ 7078.284440]
[ 7078.284442] Code: 000528f8  7ca2120a  0083182d <dc630008> 00c3302d
00c2302d  dcc20000  64420001  081dfe53
[ 7078.295797] Disabling lock debugging due to kernel taint
[ 7078.301148] Kernel panic - not syncing: Fatal exception in interrupt
[ 7088.034346] INFO: RCU detected CPU 0 stall (t=2500 jiffies)
[ 7118.034349] INFO: RCU detected CPU 0 stall (t=10000 jiffies)
[ 7148.034347] INFO: RCU detected CPU 0 stall (t=17500 jiffies)
[ 7178.034346] INFO: RCU detected CPU 0 stall (t=25000 jiffies)
