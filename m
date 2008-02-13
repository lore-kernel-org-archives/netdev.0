From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2][NETLABEL]: Move some initialization code into __init
 section.
Date: Wed, 13 Feb 2008 14:12:06 +0300
Message-ID: <47B2D086.8040008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50636 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754980AbYBMLMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 06:12:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Everything that is called from netlbl_init() can be marked with
__init. This moves 620 bytes from .text section to .text.init one.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/netlabel/netlabel_cipso_v4.c   |    2 +-
 net/netlabel/netlabel_domainhash.c |    2 +-
 net/netlabel/netlabel_mgmt.c       |    2 +-
 net/netlabel/netlabel_unlabeled.c  |    6 +++---
 net/netlabel/netlabel_user.c       |    2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 283ff4a..fdc14a0 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -761,7 +761,7 @@ static struct genl_ops netlbl_cipsov4_ops[] = {
  * mechanism.  Returns zero on success, negative values on failure.
  *
  */
-int netlbl_cipsov4_genl_init(void)
+int __init netlbl_cipsov4_genl_init(void)
 {
 	int ret_val, i;
 
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index fd46231..02c2f7c 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -171,7 +171,7 @@ static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain)
  * values on error.
  *
  */
-int netlbl_domhsh_init(u32 size)
+int __init netlbl_domhsh_init(u32 size)
 {
 	u32 iter;
 	struct netlbl_domhsh_tbl *hsh_tbl;
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 05d9886..22c1912 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -588,7 +588,7 @@ static struct genl_ops netlbl_mgmt_genl_ops[] = {
  * mechanism.  Returns zero on success, negative values on failure.
  *
  */
-int netlbl_mgmt_genl_init(void)
+int __init netlbl_mgmt_genl_init(void)
 {
 	int ret_val, i;
 
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index f0f1322..4478f2f 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1624,7 +1624,7 @@ static struct genl_ops netlbl_unlabel_genl_ops[] = {
  * mechanism.  Returns zero on success, negative values on failure.
  *
  */
-int netlbl_unlabel_genl_init(void)
+int __init netlbl_unlabel_genl_init(void)
 {
 	int ret_val, i;
 
@@ -1661,7 +1661,7 @@ static struct notifier_block netlbl_unlhsh_netdev_notifier = {
  * non-zero values on error.
  *
  */
-int netlbl_unlabel_init(u32 size)
+int __init netlbl_unlabel_init(u32 size)
 {
 	u32 iter;
 	struct netlbl_unlhsh_tbl *hsh_tbl;
@@ -1765,7 +1765,7 @@ unlabel_getattr_nolabel:
  * and to send unlabeled network traffic by default.
  *
  */
-int netlbl_unlabel_defconf(void)
+int __init netlbl_unlabel_defconf(void)
 {
 	int ret_val;
 	struct netlbl_dom_map *entry;
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index 023fc8f..b17d420 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -59,7 +59,7 @@
  * non-zero on failure.
  *
  */
-int netlbl_netlink_init(void)
+int __init netlbl_netlink_init(void)
 {
 	int ret_val;
 
-- 
1.5.3.4

