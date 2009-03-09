From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC 1/4] net: sysctl_net - use net_eq to compare nets
Date: Mon, 09 Mar 2009 21:16:29 +0300
Message-ID: <20090309182731.621869188@gmail.com>
References: <20090309181628.109019157@gmail.com>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: davem@davemloft.net, kaber@trash.net
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline; filename=net-sysctl-net-use-net_eq
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---

Btw, wouldn't be better to have a special macro/inline
to check if net is init_net? Something like is_init_net()

 net/sysctl_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.git/net/sysctl_net.c
===================================================================
--- linux-2.6.git.orig/net/sysctl_net.c
+++ linux-2.6.git/net/sysctl_net.c
@@ -61,7 +61,7 @@ static struct ctl_table_root net_sysctl_
 static int net_ctl_ro_header_perms(struct ctl_table_root *root,
 		struct nsproxy *namespaces, struct ctl_table *table)
 {
-	if (namespaces->net_ns == &init_net)
+	if (net_eq(namespaces->net_ns, &init_net))
 		return table->mode;
 	else
 		return table->mode & ~0222;
