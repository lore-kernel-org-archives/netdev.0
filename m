From: James Chapman <jchapman@katalix.com>
Subject: [PATCH] l2tp: fix possible oops on l2tp_eth module unload
Date: Mon, 21 Mar 2011 09:26:26 GMT
Message-ID: <201103210926.p2L9QQBd009047@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:60275 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637Ab1CUJcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 05:32:36 -0400
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id 0B9FCA6209F
	for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 09:26:28 +0000 (GMT)
Received: (from james@localhost)
	by bert.katalix.com (8.14.2/8.14.2/Submit) id p2L9QQBd009047
	for netdev@vger.kernel.org; Mon, 21 Mar 2011 09:26:26 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A struct used in the l2tp_eth driver for registering network namespace
ops was incorrectly marked as __net_initdata, leading to oops when
module unloaded.

BUG: unable to handle kernel paging request at ffffffffa00ec098
IP: [<ffffffff8123dbd8>] ops_exit_list+0x7/0x4b
PGD 142d067 PUD 1431063 PMD 195da8067 PTE 0
Oops: 0000 [#1] SMP 
last sysfs file: /sys/module/l2tp_eth/refcnt
Call Trace:
 [<ffffffff8123dc94>] ? unregister_pernet_operations+0x32/0x93
 [<ffffffff8123dd20>] ? unregister_pernet_device+0x2b/0x38
 [<ffffffff81068b6e>] ? sys_delete_module+0x1b8/0x222
 [<ffffffff810c7300>] ? do_munmap+0x254/0x318
 [<ffffffff812c64e5>] ? page_fault+0x25/0x30
 [<ffffffff812c6952>] ? system_call_fastpath+0x16/0x1b

Signed-off-by: James Chapman <jchapman@katalix.com>

---
Push to stable trees too?

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 8d9ce0a..a8193f5 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -283,7 +283,7 @@ static __net_init int l2tp_eth_init_net(struct net *net)
 	return 0;
 }
 
-static __net_initdata struct pernet_operations l2tp_eth_net_ops = {
+static struct pernet_operations l2tp_eth_net_ops = {
 	.init = l2tp_eth_init_net,
 	.id   = &l2tp_eth_net_id,
 	.size = sizeof(struct l2tp_eth_net),
