From: Huw Davies <huw@codeweavers.com>
Subject: [RFC PATCH v3 01/19] netlabel: Mark rcu pointers with __rcu.
Date: Wed, 17 Feb 2016 13:21:51 +0000
Message-ID: <1455715329-9601-2-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
2.7.0

