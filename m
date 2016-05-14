From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: net/tipc: NULL-ptr dereference in tipc_nl_publ_dump
Date: Sat, 14 May 2016 10:13:10 -0700
Message-ID: <1463245990.18194.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <573742CF.3000703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33556 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbcENRNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 13:13:23 -0400
Received: by mail-pa0-f67.google.com with SMTP id gh9so10878812pac.0
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 10:13:23 -0700 (PDT)
In-Reply-To: <573742CF.3000703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-05-14 at 23:22 +0800, Baozeng Ding wrote:
> Hello all,
> The following program triggers NULL-ptr dereference in 
> tipc_nl_publ_dump. The kernel version is 4.6.0-rc7+ (on May 13 commit
> 1410b74e4061e05a5d2bffb1f99829efce27c8a9). Thanks.
> ----------------------------------------------------------------------------------
> netlink: 1 bytes leftover after parsing attributes in process 
> `syz-executor'.
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory 
> accessgeneral protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 2 PID: 1346 Comm: syz-executor Not tainted 4.6.0-rc7+ #2
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> task: ffff88001eb1dd40 ti: ffff88001bd98000 task.ti: ffff88001bd98000
> RIP: 0010:[<ffffffff85940bb9>]  [<ffffffff85940bb9>] 
> tipc_nl_publ_dump+0xa39/0xdf0
> RSP: 0018:ffff88001bd9f428  EFLAGS: 00010246
> RAX: dffffc0000000000 RBX: ffff88003562efc0 RCX: ffffc900012c7000
> RDX: 0000000000000000 RSI: ffff880036215d98 RDI: ffff8800196fda98
> RBP: ffff88001bd9f678 R08: 0000000000000001 R09: 0000000000000000
> R10: ffffed00032dfb5a R11: 1ffffffff1131255 R12: 0000000000000000
> R13: ffff88002d0f8040 R14: 0000000000000000 R15: ffff88002ea220a8
> FS:  00007f0b7c70f700(0000) GS:ffff880036200000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020b5d7f2 CR3: 00000000301fe000 CR4: 00000000000006e0
> Stack:
>   0000000000000000 ffff88002ea22100 ffff88002ea220f8 ffff88002ea220f0
>   000000001bd9f520 1ffff100037b3e92 ffff88002ea220b0 ffff88001bd9f498
>   ffffffff815bcc6e ffff880036223e40 ffff88002fd60008 0000000000000000
> Call Trace:
>   [<ffffffff84b9d298>] genl_lock_dumpit+0x68/0x90 
> net/netlink/genetlink.c:517
>   [<ffffffff84b9250a>] netlink_dump+0x36a/0xa40 
> net/netlink/af_netlink.c:2108
>   [<ffffffff84b95349>] __netlink_dump_start+0x4e9/0x760 
> net/netlink/af_netlink.c:2196
>   [<ffffffff84b9e5f1>] genl_family_rcv_msg+0xa91/0xc30 
> net/netlink/genetlink.c:584
>   [<ffffffff84b9e93b>] genl_rcv_msg+0x1ab/0x260 net/netlink/genetlink.c:658
>   [<ffffffff84b9ca3c>] netlink_rcv_skb+0x29c/0x390 
> net/netlink/af_netlink.c:2277
>   [<ffffffff84b9db48>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:669
>   [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
>   [<ffffffff84b9b352>] netlink_unicast+0x5a2/0x890 
> net/netlink/af_netlink.c:1240
>   [<ffffffff84b9bfc1>] netlink_sendmsg+0x981/0xcb0 
> net/netlink/af_netlink.c:1786
>   [<     inline     >] sock_sendmsg_nosec net/socket.c:612
>   [<ffffffff849ee09a>] sock_sendmsg+0xca/0x110 net/socket.c:622
>   [<ffffffff849efee8>] ___sys_sendmsg+0x728/0x860 net/socket.c:1946
>   [<ffffffff849f1ed1>] __sys_sendmsg+0xd1/0x170 net/socket.c:1980
>   [<     inline     >] SYSC_sendmsg net/socket.c:1991
>   [<ffffffff849f1f9d>] SyS_sendmsg+0x2d/0x50 net/socket.c:1987
>   [<ffffffff85b4b340>] entry_SYSCALL_64_fastpath+0x23/0xc1 
> arch/x86/entry/entry_64.S:207
> Code: df 49 8d 7e 10 48 89 fa 48 c1 ea 03 80 3c 02 00 0f 85 df 01 00 00 
> 4d 8b 76 10 48 b8 00 00 00 00 00 fc ff df 4c 89 f2 48 c1 ea 03 <0f> b6 
> 14 02 4c 89 f0 83 e0 07 83 c0 01 38 d0 7c 08 84 d2 0f 85
> RIP  [<ffffffff85940bb9>] tipc_nl_publ_dump+0xa39/0xdf0 
> net/tipc/socket.c:2810
>   RSP <ffff88001bd9f428>
> ---[ end trace e8355fded2057a4f ]---

Probable fix :

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3eeb50a27b89..5f80d3fa9c85 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2807,6 +2807,9 @@ int tipc_nl_publ_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (err)
 			return err;
 
+		if (!attrs[TIPC_NLA_SOCK])
+			return -EINVAL;
+
 		err = nla_parse_nested(sock, TIPC_NLA_SOCK_MAX,
 				       attrs[TIPC_NLA_SOCK],
 				       tipc_nl_sock_policy);
