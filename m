From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] net: make CONFIG_NETLABEL explicitly dependent on
 CONFIG_INET
Date: Fri, 30 Nov 2012 10:35:19 -0500
Message-ID: <20121130153518.16416.23470.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rdunlap@infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030753Ab2K3Pfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 10:35:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should resolve an issue found during testing with random
configuration files.

  net/built-in.o: In function `netlbl_cfg_cipsov4_add':
  (.text+0x61757): undefined reference to `cipso_v4_doi_add'
  net/built-in.o: In function `netlbl_cfg_cipsov4_del':
  (.text+0x6177d): undefined reference to `cipso_v4_doi_remove'
  [... and so on ...]


Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/netlabel/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlabel/Kconfig b/net/netlabel/Kconfig
index 56958c8..f272826 100644
--- a/net/netlabel/Kconfig
+++ b/net/netlabel/Kconfig
@@ -4,7 +4,7 @@
 
 config NETLABEL
 	bool "NetLabel subsystem support"
-	depends on SECURITY
+	depends on SECURITY && INET
 	default n
 	---help---
 	  NetLabel provides support for explicit network packet labeling
