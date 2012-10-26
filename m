From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qla3xxx: use module_pci_driver to simplify the code
Date: Fri, 26 Oct 2012 23:02:30 +0800
Message-ID: <CAPgLHd_Xu7TKZ_mqQ2r7A2GVCo+Us6kEggHc5d+hhg4Hh6cukA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:65160 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078Ab2JZPCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 11:02:31 -0400
Received: by mail-qc0-f174.google.com with SMTP id o22so1357378qcr.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 08:02:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Use the module_pci_driver() macro to make the code simpler
by eliminating module_init and module_exit calls.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qlogic/qla3xxx.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 6407d0d..232a115 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -3958,15 +3958,4 @@ static struct pci_driver ql3xxx_driver = {
 	.remove = __devexit_p(ql3xxx_remove),
 };
 
-static int __init ql3xxx_init_module(void)
-{
-	return pci_register_driver(&ql3xxx_driver);
-}
-
-static void __exit ql3xxx_exit(void)
-{
-	pci_unregister_driver(&ql3xxx_driver);
-}
-
-module_init(ql3xxx_init_module);
-module_exit(ql3xxx_exit);
+module_pci_driver(ql3xxx_driver);
