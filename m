From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 1/3][IPV6] Cleanup the addconf_sysctl_register
Date: Fri, 30 Nov 2007 21:51:34 +0300
Message-ID: <47505BB6.5090202@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52025 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758270AbXK3Svo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 13:51:44 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This only includes fixing the space-indented lines and
removing one unneeded else after the goto.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f177424..2d2886a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4127,7 +4127,8 @@ static void addrconf_sysctl_register(struct inet6_dev *idev, struct ipv6_devconf
 
 	t = kmemdup(&addrconf_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
-		return;
+		goto out;
+
 	for (i=0; t->addrconf_vars[i].data; i++) {
 		t->addrconf_vars[i].data += (char*)p - (char*)&ipv6_devconf;
 		t->addrconf_vars[i].extra1 = idev; /* embedded; no ref */
@@ -4147,7 +4148,7 @@ static void addrconf_sysctl_register(struct inet6_dev *idev, struct ipv6_devconf
 	 */
 	dev_name = kstrdup(dev_name, GFP_KERNEL);
 	if (!dev_name)
-	    goto free;
+		goto free;
 
 	t->addrconf_dev[0].procname = dev_name;
 
@@ -4159,16 +4160,15 @@ static void addrconf_sysctl_register(struct inet6_dev *idev, struct ipv6_devconf
 	t->sysctl_header = register_sysctl_table(t->addrconf_root_dir);
 	if (t->sysctl_header == NULL)
 		goto free_procname;
-	else
-		p->sysctl = t;
+
+	p->sysctl = t;
 	return;
 
-	/* error path */
- free_procname:
+free_procname:
 	kfree(dev_name);
- free:
+free:
 	kfree(t);
-
+out:
 	return;
 }
 
-- 
1.5.3.4

