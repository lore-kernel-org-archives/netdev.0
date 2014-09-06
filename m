From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v1 1/2] bonding: display xmit_hash_policy for non-dynamic-tlb mode
Date: Fri,  5 Sep 2014 23:35:32 -0700
Message-ID: <1409985332-2241-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:35485 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbaIFGnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 02:43:35 -0400
Received: by mail-yh0-f74.google.com with SMTP id 29so1436359yhl.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 23:43:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's trivial fix to display xmit_hash_policy for this new TLB mode
since it uses transmit-hash-poilicy as part of bonding-master info
(/proc/net/bonding/<bonding-interface).

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1
 Rebase

 drivers/net/bonding/bond_procfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index de62c0385dfb..ebcf63a6ddf0 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -84,7 +84,8 @@ static void bond_info_show_master(struct seq_file *seq)
 	seq_printf(seq, "\n");
 
 	if (BOND_MODE(bond) == BOND_MODE_XOR ||
-		BOND_MODE(bond) == BOND_MODE_8023AD) {
+		BOND_MODE(bond) == BOND_MODE_8023AD ||
+		bond_is_nondyn_tlb(bond)) {
 		optval = bond_opt_get_val(BOND_OPT_XMIT_HASH,
 					  bond->params.xmit_policy);
 		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
-- 
2.1.0.rc2.206.gedb03e5
