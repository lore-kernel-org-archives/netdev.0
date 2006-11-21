From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 5/11] [IPVS]: Use kmemdup where appropriate
Date: Tue, 21 Nov 2006 01:28:08 -0200
Message-ID: <20061121032807.GF7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:10477 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030683AbWKUD2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:28:15 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/ipv4/ipvs/ip_vs_app.c   |    3 +--
 net/ipv4/ipvs/ip_vs_proto.c |    8 +-------
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index e775233..6c40899 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -80,10 +80,9 @@ ip_vs_app_inc_new(struct ip_vs_app *app,
 	if (!pp->unregister_app)
 		return -EOPNOTSUPP;
 
-	inc = kmalloc(sizeof(struct ip_vs_app), GFP_KERNEL);
+	inc = kmemdup(app, sizeof(*inc), GFP_KERNEL);
 	if (!inc)
 		return -ENOMEM;
-	memcpy(inc, app, sizeof(*inc));
 	INIT_LIST_HEAD(&inc->p_list);
 	INIT_LIST_HEAD(&inc->incs_list);
 	inc->app = app;
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index c4528b5..e844ddb 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -118,13 +118,7 @@ void ip_vs_protocol_timeout_change(int f
 int *
 ip_vs_create_timeout_table(int *table, int size)
 {
-	int *t;
-
-	t = kmalloc(size, GFP_ATOMIC);
-	if (t == NULL)
-		return NULL;
-	memcpy(t, table, size);
-	return t;
+	return kmemdup(table, size, GFP_ATOMIC);
 }
 
 
-- 
1.4.2.1.g3d5c

