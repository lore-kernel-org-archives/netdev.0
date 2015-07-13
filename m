From: clsoto@linux.vnet.ibm.com
Subject: [PATCH] net/bonding: Add function bond_remove_proc_entry at __bond_release_one
Date: Mon, 13 Jul 2015 13:57:28 -0500
Message-ID: <1436813848-30995-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
	j.vosburgh@gmail.com, gospo@cumulusnetworks.com,
	Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:34799 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbbGMTCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 15:02:02 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Mon, 13 Jul 2015 16:01:57 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 70098352006E
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 15:00:50 -0400 (EDT)
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t6DJ0P2a3670396
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 16:00:26 -0300
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t6DJ1rCL031087
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 16:01:54 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

Add function bond_remove_proc_entry at __bond_release_one to avoid stack 
trace at rmmod bonding.

[68830.202239] remove_proc_entry: removing non-empty directory
'net/bonding', leaking at least 'bond0'
[68830.202257] ------------[ cut here ]------------
[68830.202260] WARNING: at fs/proc/generic.c:562
[68830.202412] NIP [c0000000002abf6c] .remove_proc_entry+0x1fc/0x240
[68830.202416] LR [c0000000002abf68] .remove_proc_entry+0x1f8/0x240
[68830.202419] PACATMSCRATCH [8000000000009032]
[68830.202421] Call Trace:
[68830.202424] [c000000179277940] [c0000000002abf68] 
.remove_proc_entry+0x1f8/0x240 (unreliable)
[68830.202434] [c0000001792779f0] [d0000000053229a4] 
.bond_destroy_proc_dir+0x34/0x54 [bonding]
[68830.202440] [c000000179277a70] [d0000000053130e0] 
.bond_net_exit+0x90/0x120 [bonding]
[68830.202445] [c000000179277b10] [c00000000059944c] 
.ops_exit_list.isra.0+0x6c/0xd0
[68830.202450] [c000000179277ba0] [c000000000599774] 
.unregister_pernet_operations+0x94/0x100
[68830.202454] [c000000179277c40] [c000000000599814] 
.unregister_pernet_subsys+0x34/0x60
[68830.202460] [c000000179277cc0] [d000000005323758] 
.bonding_exit+0x48/0x2328 [bonding]
[68830.202466] [c000000179277d30] [c00000000010dcc4] 
.SyS_delete_module+0x1f4/0x340
[68830.202471] [c000000179277e30] [c000000000009e7c] 
syscall_exit+0x0/0x7c
[68830.202491] ---[ end trace 9bd1d810219c9875 ]---

Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/bonding/bond_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19eb990..ace105a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1870,6 +1870,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 		dev_set_mac_address(slave_dev, &addr);
 	}
 
+	bond_remove_proc_entry(bond);
+
 	dev_set_mtu(slave_dev, slave->original_mtu);
 
 	slave_dev->priv_flags &= ~IFF_BONDING;
-- 
1.8.3.1
