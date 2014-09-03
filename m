From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 1/2] bonding: display xmit_hash_policy for non-dynamic-tlb mode
Date: Wed,  3 Sep 2014 14:38:44 -0700
Message-ID: <1409780324-30420-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:46556 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510AbaICVit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:38:49 -0400
Received: by mail-qa0-f74.google.com with SMTP id j15so1042970qaq.1
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 14:38:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's trivial fix to display xmit_hash_policy for this new TLB mode
since it uses transmit-hash-poilicy as part of bonding-master info
(/proc/net/bonding/<bonding-interface).

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
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
