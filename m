From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Wed, 20 Oct 2010 13:43:27 -0400
Message-ID: <4CBF2A3F.2070108@cox.net>
References: <loom.20101012T185411-307@post.gmane.org> <1286905245.2703.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao105.cox.net ([68.230.240.47]:63097 "EHLO
	eastrmmtao105.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab0JTRn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 13:43:29 -0400
In-Reply-To: <1286905245.2703.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> 2.6.27 is a bit old, you might try :
> 
> commit 7fa7cb7109d07c29ab28bb877bc7049a0150dbe5
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Mon Sep 27 04:18:27 2010 +0000

Alas, after more load testing I find that the panic still occurs:

CPU 1 Unable to handle kernel paging request at virtual address
0000000000000000, epc == ffffffff8146728c, ra == ffffffff81467258
Oops[#1]:
Cpu 1
$ 0   : 0000000000000000 0000000000000000 0000000000000000 0000000000000000
$ 4   : ffffffffffffffff a80000008c9d78f0 a80000009acd9880 000000000a205a7c
$ 8   : 0000000000000000 0000000000000020 a80000009a9c49d0 0000000000000000
$12   : ffffffff8155de00 0000000000000004 0000000000000001 0000000000000000
$16   : 0000000000000000 a80000008c9d78f0 0000000000000002 a80000009b94ed80
$20   : a80000009b94edf8 0000000000000000 0000000000000003 a80000008c9d78a0
$24   : 0000000000000000 ffffffff812df388
$28   : a80000008c9d4000 a80000008c9d7840 fffffffffffffff5 ffffffff81467258
Hi    : 0000000000000000
Lo    : 0000000000000000
epc   : ffffffff8146728c fib_rules_lookup+0x11c/0x260
    Not tainted
ra    : ffffffff81467258 fib_rules_lookup+0xe8/0x260
Status: 1010cce3    KX SX UX KERNEL EXL IE
Cause : 00800008
BadVA : 0000000000000000
PrId  : 000d0409 (Cavium Octeon)
Modules linked in: x_tables ip_tables iptable_filter nf_conntrack
nf_conntrack_ipv4 nf_nat iptable_nat tun xt_tcpudp xt_state ipt_REJECT
ipv6 ip6_tables ip6table_filter ip6t_ipv6header ip6t_REJECT
Process qscope7500 (pid: 1343, threadinfo=a80000008c9d4000,
task=a80000008c068ac0, tls=000000002d51e920)
Stack : ffffffffffffffff 0000000000000003 a80000008c9d78d8 a80000008c9d79d8
        a80000008c9d78f0 0000000000000000 ffffffff816c39c0 ffffffffffffffff
        0000000000000003 00000000000004a6 0000000000000000 ffffffff814bd2a4
        0000000000000000 a80000008c9d78d8 0000000000000000 ffffffffc001aa24
        a80000008c9d78d8 ffffffff81478a38 0000000000000003 0000000000000001
        0000000000000000 0000000000000000 0000000000000001 000000000a205a7c
        0a2059bf00000000 0000000000000000 0000000000000000 0000000000000000
        0000000000000000 0000000000000000 a80000008c9d79d0 0000000000000000
        a80000008c9d79d8 a8000000994ff380 0000000000000000 0000000000000000
        a80000008c9d79d0 ffffffff816c39c0 0000000000000003 00000000000004a6
        ...
Call Trace:
[<ffffffff8146728c>] fib_rules_lookup+0x11c/0x260
[<ffffffff814bd2a4>] fib_lookup+0x2c/0x48
[<ffffffff81478a38>] __ip_route_output_key+0x918/0xf38
[<ffffffff81479090>] ip_route_output_flow+0x38/0x2e8
[<ffffffff81482c44>] ip_queue_xmit+0x38c/0x3a8
[<ffffffff81497f5c>] tcp_transmit_skb+0x3f4/0x7d0
[<ffffffff8149af2c>] __tcp_push_pending_frames+0x1fc/0x9e0
[<ffffffff8148cf50>] tcp_sendmsg+0x900/0xe00
[<ffffffff81441f7c>] sock_aio_write+0x16c/0x190
[<ffffffff811d0424>] do_sync_write+0xbc/0x130
[<ffffffff811d10a8>] vfs_write+0x150/0x158
[<ffffffff811d124c>] sys_write+0x5c/0x118
[<ffffffff8114532c>] handle_sys+0x12c/0x148


Code: 0040282d  00000000  de100000 <de020000> cc400000  1614ffce
00000000  2405fffd  dfbf0058
Fatal exception: panic in 5 seconds
Kernel panic - not syncing: Fatal exception
Rebooting in 1 seconds..

I'll have a go at adding a spinlock.

Joe Buehler
