From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 08/51] ipntable: No need to check and assign to parms_rta
Date: Sat, 12 Aug 2017 14:04:27 +0200
Message-ID: <20170812120510.28750-9-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42131 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752091AbdHLMI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:08:56 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This variable is initialized at declaration and nowhere else does any
assignment to it happen, so just drop the check.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipntable.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/ip/ipntable.c b/ip/ipntable.c
index 879626ee4f491..1837909fa42e7 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -202,8 +202,6 @@ static int ipntable_modify(int cmd, int flags, int argc, char **argv)
 			if (get_u32(&queue, *argv, 0))
 				invarg("\"queue\" value is invalid", *argv);
 
-			if (!parms_rta)
-				parms_rta = (struct rtattr *)&parms_buf;
 			rta_addattr32(parms_rta, sizeof(parms_buf),
 				      NDTPA_QUEUE_LEN, queue);
 			parms_change = 1;
-- 
2.13.1
