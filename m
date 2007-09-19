From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [RESEND][PATCH 2/4 Rev-3] Add new timeval_to_sec function
Date: Wed, 19 Sep 2007 09:24:07 +0530
Message-ID: <20070919092407.ecd87071.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	tgraf@suug.ch, varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:44557 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbXISDw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 23:52:57 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8J3qvbY014838
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 23:52:57 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8J3qvFN474396
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 21:52:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8J3qubM007131
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 21:52:57 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A new function for converting timeval to time_t is added in netlink.h. Its a common function used in differentplaces. The reason for adding this function in netlink.h is that its used by netlink for stats purpose.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 include/net/netlink.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index d7b824b..f86cc59 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1100,4 +1100,17 @@ static inline int nla_validate_nested(st
 #define nla_for_each_nested(pos, nla, rem) \
 	nla_for_each_attr(pos, nla_data(nla), nla_len(nla), rem)
 
+/**
+ * timeval_to_sec - Convert timeval to seconds
+ * @tv:         pointer to the timeval variable to be converted
+ *
+ * Returns the seconds representation of timeval parameter.
+ * Note : Here we round up the value. We dont need accuracy.
+ * This is mainly used in netlink for stats purpose.
+ */
+static inline time_t timeval_to_sec(const struct timeval *tv)
+{
+	return (tv->tv_sec + (tv->tv_usec ? 1 : 0));
+}
+
 #endif
-- 
1.4.3.4

