From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 2/4] Add new timeval_to_sec function
Date: Mon, 23 Jul 2007 10:11:59 +0530
Message-ID: <20070723101159.32ef3bdd.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:51818 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbXGWElq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 00:41:46 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6N4fkG9021264
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 00:41:46 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6N4fkHh258146
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 22:41:46 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6N4fjBo004957
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 22:41:46 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A new function for converting timeval to time_t is added in time.h. Its a common function used in different
places.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 include/linux/time.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/time.h b/include/linux/time.h
index dda9be6..c81baa6 100644
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
+	return (tv->tv_sec + (tv->tv_usec + 500000)/1000000);
+}
+
+/**
  * ns_to_timespec - Convert nanoseconds to timespec
  * @nsec:	the nanoseconds value to be converted
  *
-- 
1.4.3.4

