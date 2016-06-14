From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 1/3] macsec: add rcu_barrier() on module exit
Date: Tue, 14 Jun 2016 15:25:14 +0200
Message-ID: <5120805ba38a47a8f5c662191339fc4f9e50f44a.1465908271.git.sd@queasysnail.net>
References: <cover.1465908271.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41871 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbcFNNZY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 09:25:24 -0400
In-Reply-To: <cover.1465908271.git.sd@queasysnail.net>
In-Reply-To: <cover.1465908271.git.sd@queasysnail.net>
References: <cover.1465908271.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this, the various uses of call_rcu could cause a kernel panic.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 47ee2c840b55..e80736f6acd7 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3361,6 +3361,7 @@ static void __exit macsec_exit(void)
 	genl_unregister_family(&macsec_fam);
 	rtnl_link_unregister(&macsec_link_ops);
 	unregister_netdevice_notifier(&macsec_notifier);
+	rcu_barrier();
 }
 
 module_init(macsec_init);
-- 
2.8.3
