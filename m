From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: 2.5.70 kernel BUG at net/xfrm/xfrm_policy.c:185!
Date: 29 May 2003 21:30:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054236655.596.37.camel@simulacron>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kernel: ------------[ cut here ]------------
kernel: kernel BUG at net/xfrm/xfrm_policy.c:185!
kernel: invalid operand: 0000 [#2]
kernel: CPU:    0
kernel: EIP:    0060:[__xfrm_policy_destroy+20/96]    Not tainted
kernel: EFLAGS: 00010246
kernel: EIP is at __xfrm_policy_destroy+0x14/0x60
kernel: eax: 00000001   ebx: cfd48c00   ecx: 00000000   edx: 00000000
kernel: esi: c873ed80   edi: c86fde54   ebp: 00000001   esp: c86fddb4
kernel: ds: 007b   es: 007b   ss: 0068
kernel: Process ping (pid: 500, threadinfo=c86fc000 task=c874d240)
kernel: Stack: cfd48c00 cfd48c00 c03207ad cfd48c00 c86fde14 00000001
c86fde58 c8
6fddf0 
kernel:        00000002 c86f2e60 cfc66000 00000400 00000002 00000003
00000000 c8
6f2e60 
kernel:        c02e20cf 0100a8c0 0a00a8c0 00000000 c86fde58 c86fde54
00000000 c0
2e221f 
kernel: Call Trace:
kernel:  [xfrm_lookup+493/1184] xfrm_lookup+0x1ed/0x4a0
kernel:  [__ip_route_output_key+47/240] __ip_route_output_key+0x2f/0xf0
kernel:  [ip_route_output_flow+47/128] ip_route_output_flow+0x2f/0x80
kernel:  [udp_connect+391/816] udp_connect+0x187/0x330
kernel:  [inet_autobind+134/336] inet_autobind+0x86/0x150
kernel:  [inet_dgram_connect+79/128] inet_dgram_connect+0x4f/0x80
kernel:  [sys_connect+155/208] sys_connect+0x9b/0xd0
kernel:  [sock_map_fd+250/304] sock_map_fd+0xfa/0x130
kernel:  [sock_create+406/704] sock_create+0x196/0x2c0
kernel:  [sys_socket+61/96] sys_socket+0x3d/0x60
kernel:  [sys_socketcall+201/672] sys_socketcall+0xc9/0x2a0
kernel:  [capable+35/80] capable+0x23/0x50
kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
kernel: 
kernel: Code: 0f 0b b9 00 33 88 37 c0 8b 8b c0 00 00 00 85 c9 74 08 0f
0b 

setkey -f mysettings
and I can go on as usual.

seems to happen when racoon does some update
and some packet is still in the queue. 
racoon is
2003-05-29 21:29:31: INFO: main.c:174:main(): @(#)racoon 20001216
20001216 sakane@kame.net
2003-05-29 21:29:31: INFO: main.c:175:main(): @(#)This product linked
OpenSSL 0.9.7b 10 Apr 2003 (http://www.openssl.org/)

I think it is 0.2.2 from ipsec-tools.sf.net ...

Andreas
