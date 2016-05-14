From: Baozeng Ding <sploving1@gmail.com>
Subject: BUG: net/tipc: NULL-ptr dereference in tipc_nl_publ_dump
Date: Sat, 14 May 2016 23:22:55 +0800
Message-ID: <573742CF.3000703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com, ying.xue@windriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35143 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbcENPXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 11:23:06 -0400
Received: by mail-pf0-f195.google.com with SMTP id b66so3732891pfb.2
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 08:23:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
The following program triggers NULL-ptr dereference in 
tipc_nl_publ_dump. The kernel version is 4.6.0-rc7+ (on May 13 commit
1410b74e4061e05a5d2bffb1f99829efce27c8a9). Thanks.
----------------------------------------------------------------------------------
netlink: 1 bytes leftover after parsing attributes in process 
`syz-executor'.
kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory 
accessgeneral protection fault: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 2 PID: 1346 Comm: syz-executor Not tainted 4.6.0-rc7+ #2
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
Ubuntu-1.8.2-1ubuntu1 04/01/2014
task: ffff88001eb1dd40 ti: ffff88001bd98000 task.ti: ffff88001bd98000
RIP: 0010:[<ffffffff85940bb9>]  [<ffffffff85940bb9>] 
tipc_nl_publ_dump+0xa39/0xdf0
RSP: 0018:ffff88001bd9f428  EFLAGS: 00010246
RAX: dffffc0000000000 RBX: ffff88003562efc0 RCX: ffffc900012c7000
RDX: 0000000000000000 RSI: ffff880036215d98 RDI: ffff8800196fda98
RBP: ffff88001bd9f678 R08: 0000000000000001 R09: 0000000000000000
R10: ffffed00032dfb5a R11: 1ffffffff1131255 R12: 0000000000000000
R13: ffff88002d0f8040 R14: 0000000000000000 R15: ffff88002ea220a8
FS:  00007f0b7c70f700(0000) GS:ffff880036200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020b5d7f2 CR3: 00000000301fe000 CR4: 00000000000006e0
Stack:
  0000000000000000 ffff88002ea22100 ffff88002ea220f8 ffff88002ea220f0
  000000001bd9f520 1ffff100037b3e92 ffff88002ea220b0 ffff88001bd9f498
  ffffffff815bcc6e ffff880036223e40 ffff88002fd60008 0000000000000000
Call Trace:
  [<ffffffff84b9d298>] genl_lock_dumpit+0x68/0x90 
net/netlink/genetlink.c:517
  [<ffffffff84b9250a>] netlink_dump+0x36a/0xa40 
net/netlink/af_netlink.c:2108
  [<ffffffff84b95349>] __netlink_dump_start+0x4e9/0x760 
net/netlink/af_netlink.c:2196
  [<ffffffff84b9e5f1>] genl_family_rcv_msg+0xa91/0xc30 
net/netlink/genetlink.c:584
  [<ffffffff84b9e93b>] genl_rcv_msg+0x1ab/0x260 net/netlink/genetlink.c:658
  [<ffffffff84b9ca3c>] netlink_rcv_skb+0x29c/0x390 
net/netlink/af_netlink.c:2277
  [<ffffffff84b9db48>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:669
  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
  [<ffffffff84b9b352>] netlink_unicast+0x5a2/0x890 
net/netlink/af_netlink.c:1240
  [<ffffffff84b9bfc1>] netlink_sendmsg+0x981/0xcb0 
net/netlink/af_netlink.c:1786
  [<     inline     >] sock_sendmsg_nosec net/socket.c:612
  [<ffffffff849ee09a>] sock_sendmsg+0xca/0x110 net/socket.c:622
  [<ffffffff849efee8>] ___sys_sendmsg+0x728/0x860 net/socket.c:1946
  [<ffffffff849f1ed1>] __sys_sendmsg+0xd1/0x170 net/socket.c:1980
  [<     inline     >] SYSC_sendmsg net/socket.c:1991
  [<ffffffff849f1f9d>] SyS_sendmsg+0x2d/0x50 net/socket.c:1987
  [<ffffffff85b4b340>] entry_SYSCALL_64_fastpath+0x23/0xc1 
arch/x86/entry/entry_64.S:207
Code: df 49 8d 7e 10 48 89 fa 48 c1 ea 03 80 3c 02 00 0f 85 df 01 00 00 
4d 8b 76 10 48 b8 00 00 00 00 00 fc ff df 4c 89 f2 48 c1 ea 03 <0f> b6 
14 02 4c 89 f0 83 e0 07 83 c0 01 38 d0 7c 08 84 d2 0f 85
RIP  [<ffffffff85940bb9>] tipc_nl_publ_dump+0xa39/0xdf0 
net/tipc/socket.c:2810
  RSP <ffff88001bd9f428>
---[ end trace e8355fded2057a4f ]---

#include <unistd.h>
#include <sys/syscall.h>
#include <stdint.h>
#include <sys/socket.h>
#include <sys/mman.h>
#include <linux/netlink.h>

int main()
{
         mmap((void *)0x20000000ul, 0xd7f000ul, PROT_READ|PROT_WRITE, 
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0);
         int sock = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
         *(uint64_t*)0x20000363 = (uint64_t)0x0;
         *(uint32_t*)0x2000036b = (uint32_t)0x0;
         *(uint64_t*)0x20000373 = (uint64_t)0x20001ff0;
         *(uint64_t*)0x2000037b = (uint64_t)0x1;
         *(uint64_t*)0x20000383 = (uint64_t)0x20aab000;
         *(uint64_t*)0x2000038b = (uint64_t)0x5;
         *(uint32_t*)0x20000393 = (uint32_t)0x81;
         *(uint64_t*)0x20001ff0 = (uint64_t)0x20001000;
         *(uint64_t*)0x20001ff8 = (uint64_t)0x3e;
         *(uint32_t*)0x20001000 = (uint32_t)0x15;
         *(uint16_t*)0x20001004 = (uint16_t)0x22;
         *(uint16_t*)0x20001006 = (uint16_t)0x71b;
         *(uint32_t*)0x20001008 = (uint32_t)0x2;
         *(uint32_t*)0x2000100c = (uint32_t)0x2;
         *(uint8_t*)0x20001010 = (uint8_t)0x7;
         *(uint8_t*)0x20001011 = (uint8_t)0x8;
         *(uint8_t*)0x20001012 = (uint8_t)0xa0ad8f89e1b1651f;
         *(uint8_t*)0x20001013 = (uint8_t)0x44;
            *(uint8_t*)0x20001014 = (uint8_t)0x1;
         *(uint32_t*)0x20001015 = (uint32_t)0x15;
         *(uint16_t*)0x20001019 = (uint16_t)0xfffffffffffffffa;
         *(uint16_t*)0x2000101b = (uint16_t)0x100;
         *(uint32_t*)0x2000101d = (uint32_t)0x1ff;
         *(uint32_t*)0x20001021 = (uint32_t)0x4;
         *(uint8_t*)0x20001025 = (uint8_t)0x3;
         *(uint8_t*)0x20001026 = (uint8_t)0x7;
         *(uint8_t*)0x20001027 = (uint8_t)0x4;
         *(uint8_t*)0x20001028 = (uint8_t)0x2;
         *(uint8_t*)0x20001029 = (uint8_t)0x9;
         *(uint32_t*)0x2000102a = (uint32_t)0x14;
         *(uint16_t*)0x2000102e = (uint16_t)0x1;
         *(uint16_t*)0x20001030 = (uint16_t)0x400;
         *(uint32_t*)0x20001032 = (uint32_t)0x80000000;
         *(uint32_t*)0x20001036 = (uint32_t)0x60;
         *(uint8_t*)0x2000103a = (uint8_t)0x1;
         *(uint8_t*)0x2000103b = (uint8_t)0x1ff;
         *(uint8_t*)0x2000103c = (uint8_t)0x3ff;
         *(uint8_t*)0x2000103d = (uint8_t)0x3;
         *(uint64_t*)0x20aab020 = (uint64_t)0x20;
         *(uint32_t*)0x20aab028 = (uint32_t)0x1;
         *(uint32_t*)0x20aab02c = (uint32_t)0x2;
         *(uint32_t*)0x20aab030 = (uint32_t)0x0;
         *(uint32_t*)0x20aab034 = (uint32_t)0x0;
         *(uint32_t*)0x20aab038 = (uint32_t)0x0;
         *(uint64_t*)0x20aab050 = (uint64_t)0x10;
         *(uint32_t*)0x20aab058 = (uint32_t)0x1;
           *(uint32_t*)0x20aab05c = (uint32_t)0x1;
         *(uint64_t*)0x20aab084 = (uint64_t)0x24;
         *(uint32_t*)0x20aab08c = (uint32_t)0x1;
         *(uint32_t*)0x20aab090 = (uint32_t)0x1;
         *(uint32_t*)0x20aab094 = sock;
         *(uint32_t*)0x20aab098 = sock;
         *(uint32_t*)0x20aab09c = sock;
         *(uint32_t*)0x20aab0a0 = sock;
         *(uint32_t*)0x20aab0a4 = sock;
         *(uint64_t*)0x20aab0c8 = (uint64_t)0x20;
         *(uint32_t*)0x20aab0d0 = (uint32_t)0x1;
         *(uint32_t*)0x20aab0d4 = (uint32_t)0x2;
         *(uint32_t*)0x20aab0d8 = (uint32_t)0x0;
         *(uint32_t*)0x20aab0dc = (uint32_t)0x0;
         *(uint32_t*)0x20aab0e0 = (uint32_t)0x0;
         *(uint64_t*)0x20aab108 = (uint64_t)0x20;
         *(uint32_t*)0x20aab110 = (uint32_t)0x1;
         *(uint32_t*)0x20aab114 = (uint32_t)0x2;
         *(uint32_t*)0x20aab118 = (uint32_t)0x0;
         *(uint32_t*)0x20aab11c = (uint32_t)0x0;
         *(uint32_t*)0x20aab120 = (uint32_t)0x0;
         sendmsg(sock, (struct msghdr *)0x20000363ul, 0x800ul);
         return 0;
}

Best Regards,
Baozeng
