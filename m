From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] ppp: release rtnl mutex when interface creation fails
Date: Mon, 7 Mar 2016 19:36:44 +0100
Message-ID: <cde1cd85393f3a2f0900b7c2ec6ed5f615783351.1457375501.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:52338 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcCGSgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 13:36:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing rtnl_unlock() in the error path of ppp_create_interface().

Fixes: 58a89ecaca53 ("ppp: fix lockdep splat in ppp_dev_uninit()")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index e8a5936..d61da9ec 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2816,6 +2816,7 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
 
 out2:
 	mutex_unlock(&pn->all_ppp_mutex);
+	rtnl_unlock();
 	free_netdev(dev);
 out1:
 	*retp = ret;
-- 
2.7.0
