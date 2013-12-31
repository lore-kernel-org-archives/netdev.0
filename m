From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next bugfix] net, rps: fix build failure when CONFIG_RPS isn't set
Date: Wed,  1 Jan 2014 04:31:01 +0800
Message-ID: <1388521861-17410-1-git-send-email-zwu.kernel@gmail.com>
Cc: davem@davemloft.net, therbert@google.com, fengguang.wu@intel.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:43859 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756224Ab3LaUbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 15:31:18 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Tue, 31 Dec 2013 13:31:17 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 962F61FF001A
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 13:30:47 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBVKV6bv5505336
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 21:31:06 +0100
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBVKVETG001322
	for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 13:31:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 include/net/sock.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8ee90ad..bd716b6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -846,12 +846,16 @@ static inline void sock_rps_reset_flow_hash(__u32 hash)
 
 static inline void sock_rps_record_flow(const struct sock *sk)
 {
+#ifdef CONFIG_RPS
 	sock_rps_record_flow_hash(sk->sk_rxhash);
+#endif
 }
 
 static inline void sock_rps_reset_flow(const struct sock *sk)
 {
+#ifdef CONFIG_RPS
 	sock_rps_reset_flow_hash(sk->sk_rxhash);
+#endif
 }
 
 static inline void sock_rps_save_rxhash(struct sock *sk,
-- 
1.7.6.5
