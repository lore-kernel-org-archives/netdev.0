From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.19/2.6.20 BUG in inet_rtm_newaddr()/__inet_insert_ifa()
Date: Fri, 9 Mar 2007 11:33:33 +0100
Message-ID: <20070309103333.GA17232@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:39025 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1767194AbXCILfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 06:35:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Try this:

ip addr add 172.18.12.99/21 dev dummy0
ip addr add broadcast 172.18.15.255 dev dummy0

kernel: BUG: unable to handle kernel NULL pointer dereference at virtual address 00000004
kernel:  printing eip:
kernel: c04bc331
kernel: *pde = 00000000
kernel: Oops: 0000 [#1]
kernel: SMP
kernel: Modules linked in:
kernel: CPU:    0
kernel: EIP:    0060:[<c04bc331>]    Not tainted VLI
kernel: EFLAGS: 00010292   (2.6.20.1-y150 #1)
kernel: EIP is at __inet_insert_ifa+0x11/0x150
kernel: eax: 00000000   ebx: 00000000   ecx: 00003984   edx: f709f6a0
kernel: esi: d6f5429c   edi: c04bc8a0   ebp: d3f41c2c   esp: d3f41c04
kernel: ds: 007b   es: 007b   ss: 0068
kernel: Process ip (pid: 14724, ti=d3f40000 task=f647a030 task.ti=d3f40000)
kernel: Stack: 00000000 00000000 00000000 f709f6b8 00000000 00003984 f709f6a0 f709f6a0
kernel:        d6f5429c c04bc8a0 d3f41c48 c04bc8da 00000046 00000000 c045e360 f709f6a0
kernel:        00000004 d3f41c7c c046c19e 00000001 00000046 00000044 00000000 00000001
kernel: Call Trace:
kernel:  [<c0104489>] show_trace_log_lvl+0x19/0x30
kernel:  [<c010454b>] show_stack_log_lvl+0x8b/0xb0
kernel:  [<c0104775>] show_registers+0x1b5/0x2d0
kernel:  [<c01049ef>] die+0x10f/0x240
kernel:  [<c0114f82>] do_page_fault+0x342/0x610
kernel:  [<c0519dbc>] error_code+0x7c/0x90
kernel:  [<c04bc8da>] inet_rtm_newaddr+0x3a/0x70
kernel:  [<c046c19e>] rtnetlink_rcv_msg+0x17e/0x240
kernel:  [<c0475fbd>] netlink_rcv_skb+0x2d/0x70
kernel:  [<c0476035>] netlink_run_queue+0x35/0x80
kernel:  [<c046bff9>] rtnetlink_rcv+0x29/0x50
kernel:  [<c0475978>] netlink_data_ready+0x58/0x60
kernel:  [<c0474c8f>] netlink_sendskb+0x1f/0x40
kernel:  [<c0474e11>] netlink_unicast+0x131/0x140
kernel:  [<c047567a>] netlink_sendmsg+0x1fa/0x270
kernel:  [<c04577da>] sock_sendmsg+0xba/0xf0
kernel:  [<c0458d6f>] sys_sendmsg+0x13f/0x250
kernel:  [<c0459285>] sys_socketcall+0x225/0x230
kernel:  [<c0103100>] syscall_call+0x7/0xb
kernel:  =======================
kernel: Code: c7 44 24 04 00 00 00 00 c7 04 24 00 00 00 00 e8 c6 fd ff ff c9 c3 8d 74 26 00 55 89 e5 57 56 53 83 ec 1c 89 55 f0 89 4d ec 89 c3 <8b> 78 04 e8 77 ea fa ff 85 c0 0f 85 ff 00 00 00 8b 43 10 89 45
kernel: EIP: [<c04bc331>] __inet_insert_ifa+0x11/0x150 SS:ESP 0068:d3f41c04


-- 
Frank
