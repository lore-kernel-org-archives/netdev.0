From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v2 1/2] bonding: display xmit_hash_policy for non-dynamic-tlb mode
Date: Tue,  9 Sep 2014 17:46:27 -0700
Message-ID: <1410309987-10542-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:41922 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbaIJAyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:54:08 -0400
Received: by mail-qg0-f73.google.com with SMTP id i50so114258qgf.2
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 17:54:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's trivial fix to display xmit_hash_policy for this new TLB mode
since it uses transmit-hash-poilicy as part of bonding-master info
(/proc/net/bonding/<bonding-interface).

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1
 Rebase
v2
 Added bond_mode_uses_xmit_hash() inline function

 drivers/net/bonding/bond_procfs.c | 3 +--
 drivers/net/bonding/bonding.h     | 7 +++++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index de62c0385dfb..ba0b2c242f22 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -83,8 +83,7 @@ static void bond_info_show_master(struct seq_file *seq)
 
 	seq_printf(seq, "\n");
 
-	if (BOND_MODE(bond) == BOND_MODE_XOR ||
-		BOND_MODE(bond) == BOND_MODE_8023AD) {
+	if (bond_mode_uses_xmit_hash(bond)) {
 		optval = bond_opt_get_val(BOND_OPT_XMIT_HASH,
 					  bond->params.xmit_policy);
 		seq_printf(seq, "Transmit Hash Policy: %s (%d)\n",
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index aace510d08d1..64b36ba65b89 100644
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
