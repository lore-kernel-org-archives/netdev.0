From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: [DCCP] kernel BUG on connecting
Date: Fri, 2 May 2008 15:45:15 +0200
Message-ID: <200805021545.16399.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:4073 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758541AbYEBNpk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 09:45:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today after I pulled from dccp test tree I get the following while trying to 
connect. As there were no changes in dccp tree alone I assume the bug must 
have been introduced (or simply uncovered) by a patch in netdev tree. Any 
ideas?

skb_under_panic: text:e084cc55 len:4 put:4 head:df016c5c data:df0167fc 
tail:0xdf016800 end:0xdf016c80 dev:<NULL>
------------[ cut here ]------------
kernel BUG 
at /home/users/tomek/rpm/BUILD/kernel-vanilla-2.6.25/linux-2.6.25/net/core/skbuff.c:149!
invalid opcode: 0000 [#1] SMP
Modules linked in: dccp_ccid2 dccp_ccid3 dccp_tfrc_lib dccp_ipv4 dccp 
nls_iso8859_1 nls_utf8 smbfs ipv6 sch_sfq pcnet32 mii ide_pci_generic piix 
ide_cd_mod cdrom evdev

Pid: 2373, comm: client Not tainted (2.6.25_vanilla-1 #1)
EIP: 0060:[<c02d675c>] EFLAGS: 00010286 CPU: 0
EIP is at skb_under_panic+0x5c/0x60
EAX: 00000074 EBX: df016c5c ECX: 00000082 EDX: 00000046
ESI: 00000000 EDI: 00000004 EBP: ddd03c98 ESP: ddd03c6c
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process client (pid: 2373, ti=ddd02000 task=df108bb0 task.ti=ddd02000)
Stack: c041a7c4 e084cc55 00000004 00000004 df016c5c df0167fc df016800 df016c80
       c03fff1e df1ab140 00000004 ddd03ca4 c02d76fa 00000001 00000000 e084cc55
       00000004 ddcd1f40 00000000 e08492c5 20041f40 df1ab140 00000000 00000020
Call Trace:
 [<e084cc55>] ? dccp_insert_fn_opt+0x85/0x180 [dccp]
 [<c02d76fa>] ? skb_push+0x2a/0x40
 [<e084cc55>] ? dccp_insert_fn_opt+0x85/0x180 [dccp]
 [<e08492c5>] ? dccp_feat_printvals+0x35/0x70 [dccp]
 [<e084a8de>] ? dccp_feat_insert_opts+0x12e/0x2f0 [dccp]
 [<c01254cb>] ? printk+0x1b/0x20
 [<e084c8b4>] ? dccp_insert_options+0x1b4/0x4d0 [dccp]
 [<c012984c>] ? __do_softirq+0xcc/0xf0
 [<c01254cb>] ? printk+0x1b/0x20
 [<e084d7cb>] ? dccp_transmit_skb+0xdb/0x460 [dccp]
 [<e084e6e5>] ? dccp_connect+0x135/0x1e0 [dccp]
 [<e086fee1>] ? dccp_v4_connect+0x331/0x3c0 [dccp_ipv4]
 [<c0323f18>] ? inet_stream_connect+0x1b8/0x240
 [<c02d2781>] ? sys_connect+0x91/0xb0
 [<c011fbc5>] ? hrtick_set+0x85/0x100
 [<c034ff93>] ? schedule+0x233/0x6e0
 [<c026d516>] ? tty_write+0x1a6/0x1c0
 [<c02d30a9>] ? sys_socketcall+0x249/0x290
 [<c026d370>] ? tty_write+0x0/0x1c0
 [<c0103cea>] ? syscall_call+0x7/0xb
 =======================
Code: 00 00 89 5c 24 14 8b 98 a0 00 00 00 89 54 24 0c 89 5c 24 10 8b 40 50 89 
4c 24 04 c7 04 24 c4 a7 41 c0 89 44 24 08 e8 54 ed e4 ff <0f> 0b eb fe 55 89 
e5 56 53 bb 1e ff 3f c0 83 ec 24 8b 70 14 85
EIP: [<c02d675c>] skb_under_panic+0x5c/0x60 SS:ESP 0068:ddd03c6c
---[ end trace 929041808e20fa0d ]---
-- 
Regards,
Tomasz Grobelny
