From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net] vxlan: fix incorrect RCO bit in VXLAN header
Date: Fri,  4 Dec 2015 13:54:03 +0100
Message-ID: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947AbbLDMyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 07:54:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3511494ce2f3d ("vxlan: Group Policy extension") changed definition of
VXLAN_HF_RCO from 0x00200000 to BIT(24). This is obviously incorrect. It's
also in violation with the RFC draft.

Fixes: 3511494ce2f3d ("vxlan: Group Policy extension")
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
This code is, unfortunately, in the tree since 4.0. Not sure whether we can
change it now. On the other hand, we're in violation with the RFC draft and
collide with VXLAN-GPE flags assignment which defines this bit as OAM flag.

Opinions welcome, especially by Tom and Thomas.
---
 include/net/vxlan.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index c1c899c3a51b..e289ada6adf6 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -79,7 +79,7 @@ struct vxlanhdr {
 };
 
 /* VXLAN header flags. */
-#define VXLAN_HF_RCO BIT(24)
+#define VXLAN_HF_RCO BIT(21)
 #define VXLAN_HF_VNI BIT(27)
 #define VXLAN_HF_GBP BIT(31)
 
-- 
1.8.3.1
