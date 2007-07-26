From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 2/4 -rev1] Add new timeval_to_sec function
Date: Thu, 26 Jul 2007 10:45:26 +0530
Message-ID: <20070726104526.0348e746.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:49586 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945AbXGZFPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 01:15:10 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6Q5FAmP006072
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 01:15:10 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6Q5FA6G555238
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 01:15:10 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6Q5F9Rl003729
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 01:15:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A new function for converting timeval to time_t is added in time.h. Its a common function used in different
places. The timeout is now rounded up as per the suggestion.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 include/linux/time.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/time.h b/include/linux/time.h
index dda9be6..908329a 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -147,6 +147,17 @@ static inline s64 timeval_to_ns(const st
 }
 
 /**
+ * timeval_to_sec - Convert timeval to seconds
+ * @tv:         pointer to the timeval variable to be converted
+ *
+ * Returns the seconds representation of timeval parameter.
+ */
+static inline time_t timeval_to_sec(const struct timeval *tv)
+{
+	return (tv->tv_sec + (tv->tv_usec + 999999)/1000000);
+}
+
+/**
  * ns_to_timespec - Convert nanoseconds to timespec
  * @nsec:	the nanoseconds value to be converted
  *
-- 
1.4.3.4

