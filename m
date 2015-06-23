From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH] rocker: call correct unregister function on error
Date: Tue, 23 Jun 2015 10:52:10 +0300
Message-ID: <1435045930-12130-1-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Gilad Ben-Yossef <giladb@ezchip.com>
To: <sfeldma@gmail.com>, <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0094.outbound.protection.outlook.com ([157.56.112.94]:18944
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752080AbbFWIGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 04:06:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the correct unregister function matching the register
function on the error path.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Gilad Ben-Yossef <giladb@ezchip.com>
CC: Scott Feldman <sfeldma@gmail.com>
CC: Jiri Pirko <jiri@resnulli.us>

---
 drivers/net/ethernet/rocker/rocker.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index d4ec660..66b865a 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -5272,7 +5272,7 @@ static int __init rocker_module_init(void)
 	return 0;
 
 err_pci_register_driver:
-	unregister_netdevice_notifier(&rocker_netevent_nb);
+	unregister_netevent_notifier(&rocker_netevent_nb);
 	unregister_netdevice_notifier(&rocker_netdevice_nb);
 	return err;
 }
-- 
1.7.1
