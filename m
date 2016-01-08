From: Huw Davies <huw@codeweavers.com>
Subject: [RFC PATCH v2 01/18] netlabel: Mark rcu pointers with __rcu.
Date: Fri,  8 Jan 2016 09:52:37 +0000
Message-ID: <1452246774-13241-2-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:38296 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbcAHJw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 04:52:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes sparse errors of the form:
  incompatible types in comparison expression (different address spaces)

This patch also removes unnecessary initialization of static variables
to NULL.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 net/netlabel/netlabel_domainhash.c | 4 ++--
 net/netlabel/netlabel_unlabeled.c  | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index f0cb92f..d4d6640 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -55,8 +55,8 @@ struct netlbl_domhsh_tbl {
 static DEFINE_SPINLOCK(netlbl_domhsh_lock);
 #define netlbl_domhsh_rcu_deref(p) \
 	rcu_dereference_check(p, lockdep_is_held(&netlbl_domhsh_lock))
-static struct netlbl_domhsh_tbl *netlbl_domhsh = NULL;
-static struct netlbl_dom_map *netlbl_domhsh_def = NULL;
+static struct netlbl_domhsh_tbl __rcu *netlbl_domhsh;
+static struct netlbl_dom_map __rcu *netlbl_domhsh_def;
 
 /*
  * Domain Hash Table Helper Functions
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index b038092..a323815 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -116,8 +116,8 @@ struct netlbl_unlhsh_walk_arg {
 static DEFINE_SPINLOCK(netlbl_unlhsh_lock);
 #define netlbl_unlhsh_rcu_deref(p) \
 	rcu_dereference_check(p, lockdep_is_held(&netlbl_unlhsh_lock))
-static struct netlbl_unlhsh_tbl *netlbl_unlhsh = NULL;
-static struct netlbl_unlhsh_iface *netlbl_unlhsh_def = NULL;
+static struct netlbl_unlhsh_tbl __rcu *netlbl_unlhsh;
+static struct netlbl_unlhsh_iface __rcu *netlbl_unlhsh_def;
 
 /* Accept unlabeled packets flag */
 static u8 netlabel_unlabel_acceptflg = 0;
-- 
1.8.0
