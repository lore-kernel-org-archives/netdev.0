From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-2.6] cxgb4: fix MAC address hash filter
Date: Fri,  3 Dec 2010 12:39:04 -0800
Message-ID: <1291408744-2392-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11132 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab0LCUjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 15:39:05 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oB3Kd54J027397
	for <netdev@vger.kernel.org>; Fri, 3 Dec 2010 12:39:05 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oB3Kd4PB002423
	for <netdev@vger.kernel.org>; Fri, 3 Dec 2010 12:39:04 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oB3Kd46s002422
	for netdev@vger.kernel.org; Fri, 3 Dec 2010 12:39:04 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the calculation of the inexact hash-based MAC address filter.
It's 64 bits but current code is missing a ULL.  Results in filtering out
some legitimate packets.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index bb813d9..e97521c 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -2408,7 +2408,7 @@ int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 		if (index < NEXACT_MAC)
 			ret++;
 		else if (hash)
-			*hash |= (1 << hash_mac_addr(addr[i]));
+			*hash |= (1ULL << hash_mac_addr(addr[i]));
 	}
 	return ret;
 }
-- 
1.5.4

