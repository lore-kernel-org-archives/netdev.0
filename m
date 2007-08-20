From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 2/4 - rev2] Add new timeval_to_sec function
Date: Mon, 20 Aug 2007 13:45:36 +0530
Message-ID: <20070820134536.d260585a.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:38007 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbXHTIPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 04:15:03 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7K8F15L006480
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 04:15:01 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7K8F1Eq174808
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 02:15:01 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7K8F0x6002000
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 02:15:01 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A new function for converting timeval to time_t is added in time.h. Its a common function used in different
places.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 include/linux/time.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/time.h b/include/linux/time.h
index 6a5f503..1faf65c 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -149,6 +149,18 @@ static inline s64 timeval_to_ns(const st
 }
 
 /**
+ * timeval_to_sec - Convert timeval to seconds
+ * @tv:         pointer to the timeval variable to be converted
+ *
+ * Returns the seconds representation of timeval parameter.
+ * Note : Here we round up the value. We dont need accuracy.
+ */
+static inline time_t timeval_to_sec(const struct timeval *tv)
+{
+	return (tv->tv_sec + (tv->tv_usec ? 1 : 0));
+}
+
+/**
  * ns_to_timespec - Convert nanoseconds to timespec
  * @nsec:	the nanoseconds value to be converted
  *
-- 
1.4.3.4

