From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH 2/3] net/tokenring: use module_pci_driver
Date: Sat, 14 Apr 2012 12:40:17 +0800
Message-ID: <1334378417.2862.3.camel@phoenix>
References: <1334378323.2862.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63926 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905Ab2DNEkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 00:40:23 -0400
Received: by pbcun15 with SMTP id un15so4317207pbc.19
        for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 21:40:22 -0700 (PDT)
In-Reply-To: <1334378323.2862.1.camel@phoenix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the drivers in drivers/net/tokenring/* to use
module_pci_driver() macro which makes the code smaller and a bit simpler.

Signed-off-by: Axel Lin <axel.lin@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: David Howells <dhowells@redhat.com>
---
 drivers/net/tokenring/3c359.c       |   14 +-------------
 drivers/net/tokenring/lanstreamer.c |   10 +---------
 drivers/net/tokenring/olympic.c     |   14 +-------------
 drivers/net/tokenring/tmspci.c      |   14 +-------------
 4 files changed, 4 insertions(+), 48 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index b15ac81..0924f57 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1826,18 +1826,6 @@ static struct pci_driver xl_3c359_driver = {
 	.remove		= __devexit_p(xl_remove_one),
 };
 
-static int __init xl_pci_init (void)
-{
-	return pci_register_driver(&xl_3c359_driver);
-}
-
-
-static void __exit xl_pci_cleanup (void)
-{
-	pci_unregister_driver (&xl_3c359_driver);
-}
-
-module_init(xl_pci_init);
-module_exit(xl_pci_cleanup);
+module_pci_driver(xl_3c359_driver);
 
 MODULE_LICENSE("GPL") ; 
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 3e4b4f0..97e4c65 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1904,14 +1904,6 @@ static struct pci_driver streamer_pci_driver = {
   .remove   = __devexit_p(streamer_remove_one),
 };
 
-static int __init streamer_init_module(void) {
-  return pci_register_driver(&streamer_pci_driver);
-}
-
-static void __exit streamer_cleanup_module(void) {
-  pci_unregister_driver(&streamer_pci_driver);
-}
+module_pci_driver(streamer_pci_driver);
 
-module_init(streamer_init_module);
-module_exit(streamer_cleanup_module);
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 0e23474..4d45fe8 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1732,18 +1732,6 @@ static struct pci_driver olympic_driver = {
 	.remove		= __devexit_p(olympic_remove_one),
 };
 
-static int __init olympic_pci_init(void) 
-{
-	return pci_register_driver(&olympic_driver) ;
-}
-
-static void __exit olympic_pci_cleanup(void)
-{
-	pci_unregister_driver(&olympic_driver) ; 
-}	
-
-
-module_init(olympic_pci_init) ; 
-module_exit(olympic_pci_cleanup) ; 
+module_pci_driver(olympic_driver);
 
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
index fb9918d..90f3fa4 100644
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -233,16 +233,4 @@ static struct pci_driver tms_pci_driver = {
 	.remove		= __devexit_p(tms_pci_detach),
 };
 
-static int __init tms_pci_init (void)
-{
-	return pci_register_driver(&tms_pci_driver);
-}
-
-static void __exit tms_pci_rmmod (void)
-{
-	pci_unregister_driver (&tms_pci_driver);
-}
-
-module_init(tms_pci_init);
-module_exit(tms_pci_rmmod);
-
+module_pci_driver(tms_pci_driver);
-- 
1.7.5.4
