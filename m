From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net] ipx: restore token ring define to include/linux/ipx.h
Date: Wed, 23 May 2012 10:43:45 -0400
Message-ID: <1337784225-30641-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48792 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119Ab2EWOoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 10:44:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 211ed865108e24697b44bee5daac502ee6bdd4a4

    "net: delete all instances of special processing for token ring"

removed the define for IPX_FRAME_TR_8022.

While it is unlikely, we can't be 100% sure that there aren't
random userspace consumers of this value, so restore it.

The only instance I could find was in ncpfs-2.2.6, and it was
safe as-is, since it used #ifdef IPX_FRAME_TR_8022 around the
two use cases it had, but there may be other userspace packages
without similar ifdefs.

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/include/linux/ipx.h b/include/linux/ipx.h
index 8f02439..3d48014 100644
--- a/include/linux/ipx.h
+++ b/include/linux/ipx.h
@@ -38,7 +38,7 @@ struct ipx_interface_definition {
 #define IPX_FRAME_8022		2
 #define IPX_FRAME_ETHERII	3
 #define IPX_FRAME_8023		4
-/* obsolete token ring was	5 */
+#define IPX_FRAME_TR_8022       5 /* obsolete */
 	unsigned char ipx_special;
 #define IPX_SPECIAL_NONE	0
 #define IPX_PRIMARY		1
-- 
1.7.9.1
