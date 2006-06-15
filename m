From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/6][SCTP] Reset rtt_in_progress for the chunk when
	processing its sack.
Date: Thu, 15 Jun 2006 15:46:23 -0700
Message-ID: <1150411583.6028.33.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:63680 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750712AbWFOWrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 18:47:13 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5FMlC7r020108
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5FMl9CS271952
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:10 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5FMl9Bq010426
	for <netdev@vger.kernel.org>; Thu, 15 Jun 2006 18:47:09 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP] Reset rtt_in_progress for the chunk when processing its sack.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

include/net/sctp/sctp.h |    2 +-
net/sctp/outqueue.c     |    1 +
2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -255,7 +255,7 @@ #define SCTP_DEBUG_PRINTK(whatever...)
 #define SCTP_DEBUG_PRINTK_IPADDR(whatever...)
 #define SCTP_ENABLE_DEBUG
 #define SCTP_DISABLE_DEBUG
-#define SCTP_ASSERT(expr, str, func)
+#define SCTP_ASSERT(expr, str, func) BUG_ON(!(expr))
 
 #endif /* SCTP_DEBUG */
 
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -1262,6 +1262,7 @@ #endif /* SCTP_DEBUG */
 			   	if (!tchunk->tsn_gap_acked &&
 				    !tchunk->resent &&
 				    tchunk->rtt_in_progress) {
+					tchunk->rtt_in_progress = 0;
 					rtt = jiffies - tchunk->sent_at;
 					sctp_transport_update_rto(transport,
 								  rtt);


