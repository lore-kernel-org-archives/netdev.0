From: Jan Glauber <jang@linux.vnet.ibm.com>
Subject: [PATCH] chelsio: remove get_clock and use ktime_get
Date: Thu,  6 Dec 2012 10:20:14 +0100
Message-ID: <1354785614-11468-1-git-send-email-jang@linux.vnet.ibm.com>
Cc: Jan Glauber <jang@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:34554 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab2LFJUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 04:20:50 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <jang@linux.vnet.ibm.com>;
	Thu, 6 Dec 2012 09:20:44 -0000
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB69KbZT59441246
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2012 09:20:37 GMT
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB69KiZp013832
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2012 02:20:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The get_clock() of the chelsio driver clashes with the s390 one.
The chelsio helper reads a timespec via ktime just to convert it
back to ktime. I can see no different outcome from calling
ktime_get directly.

Remove the get_clock and use ktime_get directly.

Signed-off-by: Jan Glauber <jang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb/sge.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
index 47a8435..31de20a 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -367,18 +367,6 @@ void t1_sched_set_drain_bits_per_us(struct sge *sge, unsigned int port,
 
 #endif  /*  0  */
 
-
-/*
- * get_clock() implements a ns clock (see ktime_get)
- */
-static inline ktime_t get_clock(void)
-{
-	struct timespec ts;
-
-	ktime_get_ts(&ts);
-	return timespec_to_ktime(ts);
-}
-
 /*
  * tx_sched_init() allocates resources and does basic initialization.
  */
@@ -411,7 +399,7 @@ static int tx_sched_init(struct sge *sge)
 static inline int sched_update_avail(struct sge *sge)
 {
 	struct sched *s = sge->tx_sched;
-	ktime_t now = get_clock();
+	ktime_t now = ktime_get();
 	unsigned int i;
 	long long delta_time_ns;
 
-- 
1.7.12.4
