From: Bernhard Schmidt <berni@birkenwald.de>
Subject: [IPv6] BUG: NULL pointer dereference in(?) ip6_flush_pending_frames
Date: Mon, 10 Sep 2007 00:24:00 +0200
Message-ID: <20070909222400.GC7591@obelix.birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:53933 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbXIIWdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 18:33:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm running a public Teredo relay (IPv4-to-IPv6 migration protocol)
using Miredo. Every once in a while (a few minutes to days after
daemon restart) it becomes unusable and I see the following kernel
message:

BUG: unable to handle kernel NULL pointer dereference at virtual address
0000008c
 printing eip:
c02640e6
*pde = 00000000
Oops: 0000 [#17]
SMP
Modules linked in: ip6table_filter ip6_tables af_packet tun bitrev crc32
ipt_LOG xt_tcpudp iptable_filter iptable_mangle ip_tables x_tables
dm_mod capability commoncap iTCO_wdt floppy e1000 rtc unix
CPU:    0
EIP:    0060:[<c02640e6>]    Not tainted VLI
EFLAGS: 00210246   (2.6.21.3-iabg-pe750 #1)
EIP is at ip6_flush_pending_frames+0x97/0x121
eax: 00000000   ebx: d3e3ca80   ecx: db590380   edx: d3e3caf0
esi: d3e3cc80   edi: db590380   ebp: 00000002   esp: d4af7cd4
ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
Process miredo (pid: 17615, ti=d4af6000 task=cfd60030 task.ti=d4af6000)
Stack: 000005d0 00000000 d4af7d44 d4af7d54 d4af7d54 00000000 db590380
c0275ab5
       00000000 00000000 00000040 00000000 00000000 d4af7d48 df4c6780
00000040
       d4af7f44 d3e3ca80 3a000000 00000000 0000001c 003a0000 00000000
00000000
Call Trace:
 [<c0275ab5>] rawv6_sendmsg+0x840/0xa63
 [<c0258a09>] inet_sendmsg+0x3b/0x45
 [<c021df73>] sock_sendmsg+0xbc/0xd4
 [<c0123f99>] autoremove_wake_function+0x0/0x35
 [<e087c911>] tun_chr_aio_read+0x29e/0x2a8 [tun]
 [<c011025a>] default_wake_function+0x0/0xc
 [<c021e29c>] sys_sendto+0x118/0x138
 [<c014d03c>] do_readv_writev+0x17d/0x187
 [<e087c673>] tun_chr_aio_read+0x0/0x2a8 [tun]
 [<c021ef2e>] sys_socketcall+0x15e/0x242
 [<c0102560>] syscall_call+0x7/0xb
 =======================
Code: 8d 43 70 8b 48 04 39 c1 74 31 85 c9 74 2d ff 48 08 8b 11 8b 41 04
c7 41 04 00 00 00 00 c7 01 00 00 00 00 89 42 04 89 10 8b 41 28 <8b> b8
8c 00 00 00 85 ff 0f 85 6b ff ff ff eb 94 83 a3 84 01 00
EIP: [<c02640e6>] ip6_flush_pending_frames+0x97/0x121 SS:ESP
0068:d4af7cd4

I have not found anything related on netdev, I'll try a new kernel to be
sure. Do you need any more information to debug this issue?

Hardware is a Dell PowerEdge 750 (i386 P4 HT), vanilla kernel 2.6.21.3
running Debian testing.

Thanks,
Bernhard
