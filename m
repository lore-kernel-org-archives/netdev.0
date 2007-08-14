From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] econet: remove econet_packet_type on unload
Date: Wed, 15 Aug 2007 01:25:53 +0400
Message-ID: <20070814212553.GB5873@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:22972 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757684AbXHNVZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 17:25:59 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1776406fkz
        for <netdev@vger.kernel.org>; Tue, 14 Aug 2007 14:25:57 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steps to reproduce:

	modprobe econet
	rmmod econet
	modprobe econet

Unable to handle kernel paging request at ffffffff8870a098 RIP: 
 [<ffffffff8040bfb8>] dev_add_pack+0x48/0x90
PGD 203067 PUD 207063 PMD 7817f067 PTE 0
Oops: 0002 [1] PREEMPT SMP 
CPU 1 
Modules linked in: econet [maaaany]
Pid: 10671, comm: modprobe Not tainted 2.6.23-rc3-bloat #6
RIP: 0010:[<ffffffff8040bfb8>]  [<ffffffff8040bfb8>] dev_add_pack+0x48/0x90
RSP: 0000:ffff810076293df8  EFLAGS: 00010202
RAX: ffffffff88659090 RBX: ffffffff88659060 RCX: ffffffff8870a090
RDX: 0000000000000080 RSI: ffffffff805ec660 RDI: ffff810078ce4680
RBP: ffff810076293e08 R08: 0000000000000002 R09: 0000000000000000
R10: ffffffff8040bf88 R11: 0000000000000001 R12: ffff810076293e18
R13: 000000000000001b R14: ffff810076dd06b0 R15: ffffffff886590c0
FS:  00002b96a525dae0(0000) GS:ffff81007e0e2138(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffff8870a098 CR3: 000000007bb67000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 10671, threadinfo ffff810076292000, task ffff810078ce4680)
Stack:  ffff810076dd06b0 0000000000000000 ffff810076293e38 ffffffff8865b180
 0000000000800000 0000000000000000 ffffffff886590c0 ffff810076dd01c8
 ffff810076293f78 ffffffff8026723c ffff810076293e48 ffffffff886590d8
Call Trace:
 [<ffffffff8865b180>] :econet:econet_proto_init+0x180/0x1da
 [<ffffffff8026723c>] sys_init_module+0x15c/0x19e0
 [<ffffffff8020c13e>] system_call+0x7e/0x83


Code: 48 89 41 08 48 89 82 e0 c5 5e 80 48 c7 c7 a0 08 5d 80 e8 f1 
RIP  [<ffffffff8040bfb8>] dev_add_pack+0x48/0x90
 RSP <ffff810076293df8>
CR2: ffffffff8870a098

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/econet/af_econet.c |    3 +++
 1 file changed, 3 insertions(+)

--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1146,6 +1146,9 @@ static void __exit econet_proto_exit(void)
 		sock_release(udpsock);
 #endif
 	unregister_netdevice_notifier(&econet_netdev_notifier);
+#ifdef CONFIG_ECONET_NATIVE
+	dev_remove_pack(&econet_packet_type);
+#endif
 	sock_unregister(econet_family_ops.family);
 	proto_unregister(&econet_proto);
 }

