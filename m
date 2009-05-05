From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH] bonding: get rid of CONFIG_PROC_FS ifdefs
Date: Tue, 5 May 2009 18:20:51 +0200
Message-ID: <20090505162051.GG3552@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52567 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549AbZEEQU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 12:20:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove CONFIG_PROC_FS ifdefs from the code by adding void functions.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 drivers/net/bonding/bond_main.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e3af662..815191d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3459,8 +3459,28 @@ static void bond_destroy_proc_dir(void)
 		bond_proc_dir = NULL;
 	}
 }
+
+#else /* !CONFIG_PROC_FS */
+
+static int bond_create_proc_entry(struct bonding *bond)
+{
+}
+
+static void bond_remove_proc_entry(struct bonding *bond)
+{
+}
+
+static void bond_create_proc_dir(void)
+{
+}
+
+static void bond_destroy_proc_dir(void)
+{
+}
+
 #endif /* CONFIG_PROC_FS */
 
+
 /*-------------------------- netdev event handling --------------------------*/
 
 /*
@@ -3468,10 +3488,8 @@ static void bond_destroy_proc_dir(void)
  */
 static int bond_event_changename(struct bonding *bond)
 {
-#ifdef CONFIG_PROC_FS
 	bond_remove_proc_entry(bond);
 	bond_create_proc_entry(bond);
-#endif
 	down_write(&(bonding_rwsem));
         bond_destroy_sysfs_entry(bond);
         bond_create_sysfs_entry(bond);
@@ -4637,9 +4655,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 			       NETIF_F_HW_VLAN_RX |
 			       NETIF_F_HW_VLAN_FILTER);
 
-#ifdef CONFIG_PROC_FS
 	bond_create_proc_entry(bond);
-#endif
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
 	return 0;
@@ -4677,9 +4693,7 @@ static void bond_deinit(struct net_device *bond_dev)
 
 	bond_work_cancel_all(bond);
 
-#ifdef CONFIG_PROC_FS
 	bond_remove_proc_entry(bond);
-#endif
 }
 
 /* Unregister and free all bond devices.
@@ -4698,9 +4712,7 @@ static void bond_free_all(void)
 		bond_destroy(bond);
 	}
 
-#ifdef CONFIG_PROC_FS
 	bond_destroy_proc_dir();
-#endif
 }
 
 /*------------------------- Module initialization ---------------------------*/
@@ -5196,9 +5208,7 @@ static int __init bonding_init(void)
 		goto out;
 	}
 
-#ifdef CONFIG_PROC_FS
 	bond_create_proc_dir();
-#endif
 
 	init_rwsem(&bonding_rwsem);
 
