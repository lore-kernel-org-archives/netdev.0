From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: fix SSN comparision
Date: Thu, 15 Sep 2016 15:02:38 -0300
Message-ID: <9f22e4725d836feda1b2c2483303adb30838216f.1473962178.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35620 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752578AbcIOSC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 14:02:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function actually operates on u32 yet its paramteres were declared
as u16, causing integer truncation upon calling.

Note in patch context that ADDIP_SERIAL_SIGN_BIT is already 32 bits.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

This issue exists since before git import, so I can't put a Fixes tag.
Also, that said, probably not worth queueing it to stable.
Thanks

 include/net/sctp/sm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index efc01743b9d641bf6b16a37780ee0df34b4ec698..bafe2a0ab9085f24e17038516c55c00cfddd02f4 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -382,7 +382,7 @@ enum {
 	ADDIP_SERIAL_SIGN_BIT = (1<<31)
 };
 
-static inline int ADDIP_SERIAL_gte(__u16 s, __u16 t)
+static inline int ADDIP_SERIAL_gte(__u32 s, __u32 t)
 {
 	return ((s) == (t)) || (((t) - (s)) & ADDIP_SERIAL_SIGN_BIT);
 }
-- 
2.7.4
