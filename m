From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH]: bnx2: Fix uninitialized variable warning in bnx2_disable_forced_2g5()
Date: Thu, 27 May 2010 18:13:01 -0400
Message-ID: <20100527220856.25418.86593.sendpatchset@prarit.bos.redhat.com>
Cc: Prarit Bhargava <prarit@redhat.com>
To: netdev@vger.kernel.org, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757930Ab0E0WNC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 18:13:02 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o4RMD1Db029395
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 18:13:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warning:

drivers/net/bnx2.c: In function 'bnx2_disable_forced_2g5':
drivers/net/bnx2.c:1489: warning: 'bmcr' may be used uninitialized in this function

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 667f419..7e2f8ac 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1486,7 +1486,7 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
 static void
 bnx2_disable_forced_2g5(struct bnx2 *bp)
 {
-	u32 bmcr;
+	u32 uninitialized_var(bmcr);
 
 	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return;
