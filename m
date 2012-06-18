From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/19] batman-adv: ignore trailing CR when comparing protocol names
Date: Mon, 18 Jun 2012 22:39:11 +0200
Message-ID: <1340051963-14836-8-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41512 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190Ab2FRUjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:10 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 65b4f08..8610b5c 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -381,14 +381,19 @@ int bat_algo_seq_print_text(struct seq_file *seq, void *offset)
 static int param_set_ra(const char *val, const struct kernel_param *kp)
 {
 	struct bat_algo_ops *bat_algo_ops;
+	char *algo_name = (char *)val;
+	size_t name_len = strlen(algo_name);
 
-	bat_algo_ops = bat_algo_get((char *)val);
+	if (algo_name[name_len - 1] == '\n')
+		algo_name[name_len - 1] = '\0';
+
+	bat_algo_ops = bat_algo_get(algo_name);
 	if (!bat_algo_ops) {
-		pr_err("Routing algorithm '%s' is not supported\n", val);
+		pr_err("Routing algorithm '%s' is not supported\n", algo_name);
 		return -EINVAL;
 	}
 
-	return param_set_copystring(val, kp);
+	return param_set_copystring(algo_name, kp);
 }
 
 static const struct kernel_param_ops param_ops_ra = {
-- 
1.7.9.4
