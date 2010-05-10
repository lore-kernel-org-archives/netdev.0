From: kaber@trash.net
Subject: [PATCH 23/84] netfilter: update documentation fields of x_tables.h
Date: Mon, 10 May 2010 22:17:54 +0200
Message-ID: <1273522735-24672-24-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 84c7c92..c68ff82 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -197,6 +197,7 @@ struct xt_counters_info {
  * @family:	Actual NFPROTO_* through which the function is invoked
  * 		(helpful when match->family == NFPROTO_UNSPEC)
  * @hotdrop:	drop packet if we had inspection problems
+ * Network namespace obtainable using dev_net(in/out)
  */
 struct xt_match_param {
 	const struct net_device *in, *out;
@@ -213,12 +214,14 @@ struct xt_match_param {
  * struct xt_mtchk_param - parameters for match extensions'
  * checkentry functions
  *
+ * @net:	network namespace through which the check was invoked
  * @table:	table the rule is tried to be inserted into
  * @entryinfo:	the family-specific rule data
- * 		(struct ipt_ip, ip6t_ip, ebt_entry)
+ * 		(struct ipt_ip, ip6t_ip, arpt_arp or (note) ebt_entry)
  * @match:	struct xt_match through which this function was invoked
  * @matchinfo:	per-match data
  * @hook_mask:	via which hooks the new rule is reachable
+ * Other fields as above.
  */
 struct xt_mtchk_param {
 	struct net *net;
@@ -230,7 +233,10 @@ struct xt_mtchk_param {
 	u_int8_t family;
 };
 
-/* Match destructor parameters */
+/**
+ * struct xt_mdtor_param - match destructor parameters
+ * Fields as above.
+ */
 struct xt_mtdtor_param {
 	struct net *net;
 	const struct xt_match *match;
-- 
1.7.0.4

