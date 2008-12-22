From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 07/27] drivers/net/bonding: fix sparse warnings: move decls to
	header file
Date: Mon, 22 Dec 2008 20:15:54 +0100
Message-ID: <20081222191554.11807.66734.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981AbYLVTQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:16:00 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/bonding/bond_main.c:104:20: warning: symbol 'bonding_defaults' was not declared. Should it be static?
  drivers/net/bonding/bond_main.c:204:22: warning: symbol 'ad_select_tbl' was not declared. Should it be static?
  drivers/net/bonding/bond_sysfs.c:60:21: warning: symbol 'bonding_rwsem' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/bonding/bond_main.c  |    1 -
 drivers/net/bonding/bond_sysfs.c |    3 ---
 drivers/net/bonding/bonding.h    |    5 +++++
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a34c186..460c2ca 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -154,7 +154,6 @@ LIST_HEAD(bond_dev_list);
 static struct proc_dir_entry *bond_proc_dir = NULL;
 #endif
 
-extern struct rw_semaphore bonding_rwsem;
 static __be32 arp_target[BOND_MAX_ARP_TARGETS] = { 0, } ;
 static int arp_ip_count	= 0;
 static int bond_mode	= BOND_MODE_ROUNDROBIN;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1860f81..18cf478 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -43,9 +43,6 @@
 
 /*---------------------------- Declarations -------------------------------*/
 
-extern struct bond_params bonding_defaults;
-extern struct bond_parm_tbl ad_select_tbl[];
-
 static int expected_refcount = -1;
 /*--------------------------- Data Structures -----------------------------*/
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 31ae5b5..ca849d2 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -350,6 +350,11 @@ extern const struct bond_parm_tbl bond_mode_tbl[];
 extern const struct bond_parm_tbl xmit_hashtype_tbl[];
 extern const struct bond_parm_tbl arp_validate_tbl[];
 extern const struct bond_parm_tbl fail_over_mac_tbl[];
+extern struct bond_params bonding_defaults;
+extern struct bond_parm_tbl ad_select_tbl[];
+
+/* exported from bond_sysfs.c */
+extern struct rw_semaphore bonding_rwsem;
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 void bond_send_unsolicited_na(struct bonding *bond);

