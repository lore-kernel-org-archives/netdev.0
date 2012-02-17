From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 09/10] batman-adv: allowing changing the routing algorithm via module parameter
Date: Fri, 17 Feb 2012 15:18:29 +0800
Message-ID: <1329463110-856-10-git-send-email-lindner_marek@yahoo.de>
References: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm14-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.250]:39571
	"HELO nm14-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751760Ab2BQHTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 02:19:47 -0500
In-Reply-To: <1329463110-856-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/main.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index bcc2bdd..8ae497b 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -256,6 +256,30 @@ int bat_algo_seq_print_text(struct seq_file *seq, void *offset)
 	return 0;
 }
 
+static int param_set_ra(const char *val, const struct kernel_param *kp)
+{
+	struct bat_algo_ops *bat_algo_ops;
+
+	bat_algo_ops = bat_algo_get((char *)val);
+	if (!bat_algo_ops) {
+		pr_err("Routing algorithm '%s' is not supported\n", val);
+		return -EINVAL;
+	}
+
+	return param_set_copystring(val, kp);
+}
+
+static const struct kernel_param_ops param_ops_ra = {
+	.set = param_set_ra,
+	.get = param_get_string,
+};
+
+static struct kparam_string __param_string_ra = {
+	.maxlen = sizeof(bat_routing_algo),
+	.string = bat_routing_algo,
+};
+
+module_param_cb(routing_algo, &param_ops_ra, &__param_string_ra, 0644);
 module_init(batman_init);
 module_exit(batman_exit);
 
-- 
1.7.9
