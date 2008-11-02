From: "Liqiang Yang" <yliqiang@gmail.com>
Subject: More debug info - Re: About tcp header misalignment
Date: Mon, 3 Nov 2008 01:52:35 +0800
Message-ID: <127841bd0811020952m5d971cc4lbd55170f7db1c9ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:51017 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824AbYKBRwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 12:52:38 -0500
Received: by fg-out-1718.google.com with SMTP id 19so1813858fgg.17
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2008 09:52:35 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

~ $ saddr: 1603780a, daddr: ec0e527c
sport: fd12, dport: f763
tcp_header_size: 32
th: 819e22a9 skb->len:100, skb->data_len: 0
skb->head:819e2000, skb->tail: 819e230d skb->end: 819e2640
0000 28 e0 5d ad 8b d5 2f 35 f1 16 d9 ae 99 0e 40 84 (.].../5......@.
0010 a7 db 22 79 18 bd 0f da 90 d7 22 f6 dc 07 74 a7 .."y......"...t.
0020 e6 b7 69 4b 19 92 15 b8 40 65 57 0a 20 22 e3 11 ..iK....@eW. "..
0030 20 c2 9c a6 7e 76 18 13 1f 30 46 94 e2 d9 75 65  ...~v...0F...ue
0040 dd 88 97 50 e9 bd 39 b0 ef e4 f5 05 22 9e 00 45 ...P..9....."..E
0050 b9 16 23 f8 31 f7 1a 4a 08 f1 20 14 22 a9 8f a7 ..#.1..J.. ."...
0060 32 ed 7b 05                                     2.{.
Call Trace:
 [<80340000>] skb_find_text+0x38/0x98
 [<80385f58>] tcp_transmit_skb+0x92c/0xd90
 [<80385f4c>] tcp_transmit_skb+0x920/0xd90
 [<80387354>] tcp_retransmit_skb+0x178/0x8f4
 [<80387340>] tcp_retransmit_skb+0x164/0x8f4
 [<803676cc>] ip_rcv+0x4d0/0x704
 [<8038a198>] tcp_write_timer+0x37c/0x8e0
 [<8038a310>] tcp_write_timer+0x4f4/0x8e0
 [<8034bb90>] process_backlog+0x258/0x268
 [<80039a40>] update_process_times+0x90/0x1bc
 [<80389e1c>] tcp_write_timer+0x0/0x8e0
 [<80039ccc>] run_timer_softirq+0x160/0x2b4
 [<80008c0c>] timer_interrupt+0x13c/0x2ac
 [<80008c0c>] timer_interrupt+0x13c/0x2ac
 [<80033a80>] __do_softirq+0xa8/0x14c
 [<80033bcc>] do_softirq+0xa8/0xb0
 [<80003888>] do_IRQ+0x34/0x4c
 [<800016cc>] c2IRQ+0x10c/0x1a0
 [<80003b10>] cpu_idle+0x30/0x3c
 [<80003af4>] cpu_idle+0x14/0x3c
 [<805506d4>] start_kernel+0x268/0x28c
 [<805506cc>] start_kernel+0x260/0x28c
 [<805506a0>] start_kernel+0x234/0x28c
 [<80000800>] kernel_entry_jump+0x0/0x20
Kernel unaligned instruction access in
arch/c2/kernel/unaligned.c::do_ade, line 498[#1]:
Cpu 0
$ 0   : 00000000 f0018000 00000004 0000fd12
$ 4   : 804768d4 00000001 805145cc 0000000a
$ 8   : 00000000 ffffd46a 00000000 00000000
$12   : 10000040 00800000 ffffffff 000f3800
$16   : 80340000 8248b5c0 819e22a9 83fba34c
$20   : 83fba37c 00000000 00000020 00000001
$24   : 80470000 b0001604
$28   : 80470000 80473d20 8248b620 80385f58
Hi    : 00000063
Lo    : bcd77800
epc   : 803857a4 tcp_transmit_skb+0x178/0xd90     Not tainted
ra    : 80385f58 tcp_transmit_skb+0x92c/0xd90
Status: f0018003    USER EXL IE
Cause : 20008014
BadVA : 819e22a9
PrId  : 0000c201
Modules linked in:
Process swapper (pid: 0, threadinfo=80470000, task=80474000)
Stack : 8248b5c0 83fba2c0 ffffffbc 83fba2f0 00000044 00000000 00000002 00000001
        80387354 83fba2c0 ffffffbc 83fba2f0 80387340 803676cc 806f3180 825717bc
        00000001 8248b5c0 00000008 80470000 8248b620 8066ae08 80470000 00200200
        80470000 80473d60 80670000 8038a198 8038a310 8034bb90 00037180 00000001
        80474000 00000000 80660000 80660000 80470000 80473da0 00000000 80039a40
        ...
Call Trace:
 [<80387354>] tcp_retransmit_skb+0x178/0x8f4
 [<80387340>] tcp_retransmit_skb+0x164/0x8f4
 [<803676cc>] ip_rcv+0x4d0/0x704
 [<8038a198>] tcp_write_timer+0x37c/0x8e0
 [<8038a310>] tcp_write_timer+0x4f4/0x8e0
 [<8034bb90>] process_backlog+0x258/0x268
 [<80039a40>] update_process_times+0x90/0x1bc
 [<80389e1c>] tcp_write_timer+0x0/0x8e0
 [<80039ccc>] run_timer_softirq+0x160/0x2b4
 [<80008c0c>] timer_interrupt+0x13c/0x2ac
 [<80008c0c>] timer_interrupt+0x13c/0x2ac
 [<80033a80>] __do_softirq+0xa8/0x14c
 [<80033bcc>] do_softirq+0xa8/0xb0
 [<80003888>] do_IRQ+0x34/0x4c
 [<800016cc>] c2IRQ+0x10c/0x1a0
 [<80003b10>] cpu_idle+0x30/0x3c
 [<80003af4>] cpu_idle+0x14/0x3c
 [<805506d4>] start_kernel+0x268/0x28c
 [<805506cc>] start_kernel+0x260/0x28c
 [<805506a0>] start_kernel+0x234/0x28c
 [<80000800>] kernel_entry_jump+0x0/0x20
Code: 158001c1  3c048045  9623013c <a6430000> 963f012c  a65f0002
8e8c0010  040d0000  000c8600
Kernel panic - not syncing: Aiee, killing interrupt handler!

tcp_header_size: 32
th: 81e85c86 skb->len:426, skb->data_len: 0
skb->head:81e85800, skb->tail: 81e85e30
0000 fc 23 19 a7 db a1 54 64 6f 70 d8 81 d1 c5 52 ed .#....Tdop....R.
0010 6e bb 83 2a 57 75 bf a1 df be c9 72 e5 e6 62 e0 n..*Wu.....r..b.
0020 5c bf 72 b8 df 8e e1 5e e7 c8 68 5e c5 b9 bc de \.r....^..h^....
0030 ac 87 d6 50 e9 40 16 a0 bd da 0c 70 43 56 d6 2b ...P.@.....pCV.+
0040 8e fc 67 c4 a6 74 f7 84 30 a5 c4 1b 84 14 e3 fb ..g..t..0.......
0050 b2 06 bd 2e d3 9e dc 8a ce ae 2b a8 60 9f 23 7a ..........+.`.#z
0060 86 cd a3 6b b1 0d 96 b3 f7 58 08 7c 9a 89 f2 e7 ...k.....X.|....
0070 63 99 8e 5b 08 3f ba 1c 52 01 f3 86 8c ad 63 2a c..[.?..R.....c*
0080 ff e5 6f 1d 9f 52 94 b1 25 a7 d8 8d 11 07 fc e0 ..o..R..%.......
0090 cd 33 ca f4 36 2a ea b2 54 44 63 2e d0 89 ee f1 .3..6*..TDc.....
00a0 12 8c 3f 23 77 35 6b bb 66 e3 5c 97 7d a1 a4 d1 ..?#w5k.f.\.}...
00b0 95 e8 dd e0 33 10 26 9a 35 6d 8b 86 5f 86 8a 11 ....3.&.5m.._...
00c0 4e e4 4d 4c f7 7b 80 53 f5 32 a4 17 7b b0 03 fb N.ML.{.S.2..{...
00d0 5d e4 ef 21 15 60 fe 25 28 94 a9 37 98 5a 81 d6 ]..!.`.%(..7.Z..
00e0 81 c7 f2 2d 07 53 39 1c de 22 f7 f3 60 12 4d 33 ...-.S9.."..`.M3
00f0 34 ba a6 b8 b6 0f 1e 17 f2 98 31 81 08 64 68 6e 4.........1..dhn
0100 ca 4a 7f b6 27 57 2a be 4c 51 17 31 0d 98 4b 36 .J..'W*.LQ.1..K6
0110 7b d9 67 32 11 77 b4 5e c8 9f 07 55 8a 94 65 e0 {.g2.w.^...U..e.
0120 55 b7 24 bf 3e 1b 8c 03 5c 1b aa 21 50 60 98 5a U.$.>...\..!P`.Z
0130 5b 1b b4 81 60 25 56 18 5d 20 2c 75 c8 4e 9d 69 [...`%V.] ,u.N.i
0140 e0 91 63 d9 2e 20 06 7e 64 94 0d 95 aa 00 1a bf ..c.. .~d.......
0150 79 dc 60 e9 4c 7b 7e b3 25 fd ba d8 24 57 0a af y.`.L{~.%...$W..
0160 b0 1e e4 c6 da 01 53 61 c2 bb d2 8b 0a 4b 19 7a ......Sa.....K.z
0170 bd 37 b5 ff 34 ae aa b8 8f fa 6a 02 33 63 7e fd .7..4.....j.3c~.
0180 ac 0a a8 c0 46 92 cd 23 52 0f 14 fd 01 5f 65 74 ....F..#R...._et
0190 d6 09 a3 43 d3 ce c6 fc 1c 7c 3e 19 c2 f0 93 24 ...C.....|>....$
01a0 75 a2 5b 25 db 3a 94 dc ee d9

2008/10/17 Liqiang Yang <yliqiang@gmail.com>:
> Hi,All
>
> We runing linux-2.6.14 on a MIPS like platform,
> When running a bittorrent client, there is a misalignment in tcp
> header occurs randomly.
> Now, we know that it caused by line 319 of net/ipv4/tcp_output.c.
>
>       th = (struct tcphdr *) skb_push(skb, tcp_header_size);
>       skb->h.th = th;
>       skb_set_owner_w(skb, sk);
>       /* Build TCP header and checksum it. */
>       th->source = inet->sport;(Line 319 of tcp_output.c)
>
> th: 82ffa881
>
> Call Trace:
>  [<80373acc>] tcp_transmit_skb+0xcc0/0xd10
>  [<80373ad8>] tcp_transmit_skb+0xccc/0xd10
>  [<80374ab4>] tcp_retransmit_skb+0x178/0x8f4
>  [<80374aa0>] tcp_retransmit_skb+0x164/0x8f4
>  [<8035502c>] ip_rcv+0x4d0/0x704
>  [<803778f8>] tcp_write_timer+0x37c/0x8e0
>  [<80377a70>] tcp_write_timer+0x4f4/0x8e0
>  [<80039a40>] update_process_times+0x90/0x1bc
>  [<8037757c>] tcp_write_timer+0x0/0x8e0
>  [<80039ccc>] run_timer_softirq+0x160/0x2b4
>  [<80008c0c>] timer_interrupt+0x13c/0x2ac
>  [<80008c0c>] timer_interrupt+0x13c/0x2ac
>  [<80033a80>] __do_softirq+0xa8/0x14c
>  [<80033bcc>] do_softirq+0xa8/0xb0
>  [<80003888>] do_IRQ+0x34/0x4c
>  [<800016cc>] c2IRQ+0x10c/0x1a0
>  [<80003b10>] cpu_idle+0x30/0x3c
>  [<80003afc>] cpu_idle+0x1c/0x3c
>  [<805386d4>] start_kernel+0x268/0x28c
>  [<805386cc>] start_kernel+0x260/0x28c
>  [<805386a0>] start_kernel+0x234/0x28c
>  [<80000800>] kernel_entry_jump+0x0/0x20
>
> Could you give me some advices how to fix the problems.
> Thanks.
>
