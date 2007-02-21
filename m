From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 16/29] netvm: filter emergency skbs.
Date: Wed, 21 Feb 2007 15:43:20 +0100
Message-ID: <20070221144843.132373000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304AbXBUPb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 10:31:27 -0500
Content-Disposition: inline; filename=netvm-sk_filter.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Toss all emergency packets not for a SOCK_VMIO socket. This ensures our
precious memory reserve doesn't get stuck waiting for user-space.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/net/sock.h |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6-git/include/net/sock.h
===================================================================
--- linux-2.6-git.orig/include/net/sock.h	2007-02-14 16:15:49.000000000 +0100
+++ linux-2.6-git/include/net/sock.h	2007-02-14 16:16:27.000000000 +0100
@@ -926,6 +926,9 @@ static inline int sk_filter(struct sock 
 {
 	int err;
 	struct sk_filter *filter;
+
+	if (skb_emergency(skb) && !sk_has_vmio(sk))
+		return -EPERM;
 	
 	err = security_sock_rcv_skb(sk, skb);
 	if (err)

-- 

