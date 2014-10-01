From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v6 1/2] bonding: display xmit_hash_policy for non-dynamic-tlb mode
Date: Wed,  1 Oct 2014 01:38:11 -0700
Message-ID: <1412152691-12550-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:59572 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbaJAIiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 04:38:16 -0400
Received: by mail-yh0-f74.google.com with SMTP id f10so9863yha.5
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 01:38:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a trivial fix to display xmit_hash_policy for this new TLB mode
since it uses transmit-hash-poilicy as part of bonding-master info
(/proc/net/bonding/<bonding-interface).

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v1
 Rebase
v2
 Added bond_mode_uses_xmit_hash() inline function
v3-v6
 Rebase

 drivers/net/bonding/bond_procfs.c | 3 +--
 drivers/net/bonding/bonding.h     | 7 +++++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index bb09d0442aa8..a3948f8d1e53 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -73,8 +73,7 @@ static void bond_info_show_master(struct seq_file *seq)
 
 	seq_printf(seq, "\n");
 
-	if (BOND_MODE(bond) == BOND_MODE_XOR ||
-		BOND_MODE(bond) == BOND_MODE_8023AD) {
+	if (bond_mode_uses_xmit_hash(bond)) {
 		optval = bond_opt_get_val(BOND_OPT_XMIT_HASH,
 					  bond->params.xmit_policy);
 		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 57917e63b4e6..5b022da9cad2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -274,6 +274,13 @@ static inline bool bond_is_nondyn_tlb(const struct bonding *bond)
 	       (bond->params.tlb_dynamic_lb == 0);
 }
 
+static inline bool bond_mode_uses_xmit_hash(const struct bonding *bond)
+{
+	return (BOND_MODE(bond) == BOND_MODE_8023AD ||
+		BOND_MODE(bond) == BOND_MODE_XOR ||
+		bond_is_nondyn_tlb(bond));
+}
+
 static inline bool bond_mode_uses_arp(int mode)
 {
 	return mode != BOND_MODE_8023AD && mode != BOND_MODE_TLB &&
-- 
2.1.0.rc2.206.gedb03e5
