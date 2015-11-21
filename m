From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] net: atm: constify in_cache_ops and eg_cache_ops structures
Date: Sat, 21 Nov 2015 18:28:05 +0100
Message-ID: <1448126885-7666-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:32615
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751514AbbKURj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 12:39:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The in_cache_ops and eg_cache_ops structures are never modified, so declare
them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/atm/mpc.h         |    4 ++--
 net/atm/mpoa_caches.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/atm/mpc.h b/net/atm/mpc.h
index 0919a88..cfc7b74 100644
--- a/net/atm/mpc.h
+++ b/net/atm/mpc.h
@@ -21,11 +21,11 @@ struct mpoa_client {
 	uint8_t our_ctrl_addr[ATM_ESA_LEN];  /* MPC's control ATM address   */
 
 	rwlock_t ingress_lock;
-	struct in_cache_ops *in_ops; /* ingress cache operations            */
+	const struct in_cache_ops *in_ops; /* ingress cache operations      */
 	in_cache_entry *in_cache;    /* the ingress cache of this MPC       */
 
 	rwlock_t egress_lock;
-	struct eg_cache_ops *eg_ops; /* egress cache operations             */
+	const struct eg_cache_ops *eg_ops; /* egress cache operations       */
 	eg_cache_entry *eg_cache;    /* the egress  cache of this MPC       */
 
 	uint8_t *mps_macs;           /* array of MPS MAC addresses, >=1     */
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index d1b2d9a..9e60e74 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -534,7 +534,7 @@ static void eg_destroy_cache(struct mpoa_client *mpc)
 }
 
 
-static struct in_cache_ops ingress_ops = {
+static const struct in_cache_ops ingress_ops = {
 	in_cache_add_entry,               /* add_entry       */
 	in_cache_get,                     /* get             */
 	in_cache_get_with_mask,           /* get_with_mask   */
@@ -548,7 +548,7 @@ static struct in_cache_ops ingress_ops = {
 	in_destroy_cache                  /* destroy_cache   */
 };
 
-static struct eg_cache_ops egress_ops = {
+static const struct eg_cache_ops egress_ops = {
 	eg_cache_add_entry,               /* add_entry        */
 	eg_cache_get_by_cache_id,         /* get_by_cache_id  */
 	eg_cache_get_by_tag,              /* get_by_tag       */
