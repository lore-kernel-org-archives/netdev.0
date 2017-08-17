From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/7] ipntable: No need to check and assign to parms_rta
Date: Thu, 17 Aug 2017 19:09:26 +0200
Message-ID: <20170817170931.24089-3-phil@nwl.cc>
References: <20170817170931.24089-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59945 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753300AbdHQRMO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:12:14 -0400
In-Reply-To: <20170817170931.24089-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This variable is initialized at declaration and nowhere else does any
assignment to it happen, so just drop the check.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipntable.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/ip/ipntable.c b/ip/ipntable.c
index 7be1f04d33d90..30907146e85a3 100644
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
