From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [PATCH v4 01/19] netlabel: Mark rcu pointers with __rcu.
Date: Mon, 20 Jun 2016 14:36:41 +0100
Message-ID: <1466429819-12707-2-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

This fixes sparse errors of the form:
  incompatible types in comparison expression (different address spaces)

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
---
 net/netlabel/netlabel_domainhash.c | 4 ++--
 net/netlabel/netlabel_unlabeled.c  | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index ada6742..d4d6640 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -55,8 +55,8 @@ struct netlbl_domhsh_tbl {
 static DEFINE_SPINLOCK(netlbl_domhsh_lock);
 #define netlbl_domhsh_rcu_deref(p) \
 	rcu_dereference_check(p, lockdep_is_held(&netlbl_domhsh_lock))
-static struct netlbl_domhsh_tbl *netlbl_domhsh;
-static struct netlbl_dom_map *netlbl_domhsh_def;
+static struct netlbl_domhsh_tbl __rcu *netlbl_domhsh;
+static struct netlbl_dom_map __rcu *netlbl_domhsh_def;
 
 /*
  * Domain Hash Table Helper Functions
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 9eaa9a1..ca590d2 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -116,8 +116,8 @@ struct netlbl_unlhsh_walk_arg {
 static DEFINE_SPINLOCK(netlbl_unlhsh_lock);
 #define netlbl_unlhsh_rcu_deref(p) \
 	rcu_dereference_check(p, lockdep_is_held(&netlbl_unlhsh_lock))
-static struct netlbl_unlhsh_tbl *netlbl_unlhsh;
-static struct netlbl_unlhsh_iface *netlbl_unlhsh_def;
+static struct netlbl_unlhsh_tbl __rcu *netlbl_unlhsh;
+static struct netlbl_unlhsh_iface __rcu *netlbl_unlhsh_def;
 
 /* Accept unlabeled packets flag */
 static u8 netlabel_unlabel_acceptflg;
-- 
2.7.4

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
