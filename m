From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] atm: he: use module_pci_driver to simplify the code
Date: Wed, 10 Oct 2012 21:00:04 +0800
Message-ID: <CAPgLHd-aYakavX_RRdiF3Sy1kjpUWWgHe0pqkpmGt6O8oi75jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:41135 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755005Ab2JJNAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 09:00:05 -0400
Received: by mail-qc0-f174.google.com with SMTP id d3so334557qch.19
        for <netdev@vger.kernel.org>; Wed, 10 Oct 2012 06:00:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Use the module_pci_driver() macro to make the code simpler
by eliminating module_init and module_exit calls.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/atm/he.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index b182c2f..e184339 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2883,15 +2883,4 @@ static struct pci_driver he_driver = {
 	.id_table =	he_pci_tbl,
 };
 
-static int __init he_init(void)
-{
-	return pci_register_driver(&he_driver);
-}
-
-static void __exit he_cleanup(void)
-{
-	pci_unregister_driver(&he_driver);
-}
-
-module_init(he_init);
-module_exit(he_cleanup);
+module_pci_driver(he_driver);
