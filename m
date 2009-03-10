From: Felix Radensky <felix@embedded-sol.com>
Subject: Machine check in ibm_newemac driver
Date: Tue, 10 Mar 2009 21:26:04 +0200
Message-ID: <49B6BECC.4080805@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:38570 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756847AbZCJUP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 16:15:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm getting machine check exception when executing "ethtool -d eth0"
on Kilauea evaluation board (AMCC 40EX) running linux-2.6.29-rc7.

-bash-3.2# ethtool -d eth0
Data machine check in kernel mode.
Oops: Machine check, sig: 7 [#1]
Kilauea
Modules linked in:
NIP: c000e240 LR: c0158358 CTR: 00000004
REGS: cfffdf50 TRAP: 0202   Not tainted  (2.6.29-rc7)
MSR: 00029030 <EE,ME,CE,IR,DR>  CR: 22002044  XER: 2000005f
TASK = cfa79740[1011] 'ethtool' THREAD: cfa82000
GPR00: 00000001 cfa83d10 cfa79740 cf8d7a34 d105696c 00000004 cfa83d40 
00000000
GPR08: 00000000 0000001b 00000004 00000004 22002022 1005f4d0 10010000 
1000d9c4
GPR16: 1000d9bc 1000d9b4 1000fbec 10057650 100118a4 10010000 1000da10 
100570ec
GPR24: bf90f790 00000000 cfa83d38 cf8d7800 10058008 cf8d7800 cf8d79c0 
cf811360
NIP [c000e240] _memcpy_fromio+0x9c/0xc4
LR [c0158358] emac_ethtool_get_regs+0x68/0xc4
Call Trace:
[cfa83d10] [c015831c] emac_ethtool_get_regs+0x2c/0xc4 (unreliable)
[cfa83d30] [c017ed00] ethtool_get_regs+0xf8/0x1f8
[cfa83d60] [c018036c] dev_ethtool+0x10f4/0x13ac
[cfa83df0] [c017d7dc] dev_ioctl+0x430/0x700
[cfa83e70] [c016ad80] sock_ioctl+0x80/0x2ec
[cfa83e90] [c0088104] vfs_ioctl+0x34/0x98
[cfa83ea0] [c0088550] do_vfs_ioctl+0x3c0/0x734
[cfa83f10] [c0088904] sys_ioctl+0x40/0x74
[cfa83f40] [c000eb60] ret_from_syscall+0x0/0x3c
Instruction dump:
419c004c 80040000 90030000 7c0006ac 38840004 38630004 38a5fffc 4200ffe8
2f050000 41baffb4 7ca903a6 88040000 <98030000> 7c0006ac 38840001 38630001
---[ end trace 075752cbf5bce2a1 ]---
Bus error

I can trace this problem back to 2.6.25. Replacing memcpy_fromio() by 
memcpy()
fixes the exception, but register values look wrong.

Any help in debugging this is very much appreciated.

Thanks.

Felix.

