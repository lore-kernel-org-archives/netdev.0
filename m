From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][BRIDGE] Lost call to br_fdb_fini() in br_init() error path
Date: Tue, 27 Nov 2007 17:39:42 +0300
Message-ID: <474C2C2E.7050001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37214 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020AbXK0OkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 09:40:06 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case the br_netfilter_init() (or any subsequent call) 
fails, the br_fdb_fini() must be called to free the allocated
in br_fdb_init() br_fdb_cache kmem cache.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/bridge/br.c b/net/bridge/br.c
index 93867bb..a901828 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -39,7 +39,7 @@ static int __init br_init(void)
 
 	err = br_fdb_init();
 	if (err)
-		goto err_out1;
+		goto err_out;
 
 	err = br_netfilter_init();
 	if (err)
@@ -65,6 +65,8 @@ err_out3:
 err_out2:
 	br_netfilter_fini();
 err_out1:
+	br_fdb_fini();
+err_out:
 	llc_sap_put(br_stp_sap);
 	return err;
 }
