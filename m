From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 17/40] netvm: filter emergency skbs.
Date: Fri, 04 May 2007 12:27:08 +0200
Message-ID: <20070504103159.389910222@chello.nl>
References: <20070504102651.923946304@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:15195 "EHLO
	amsfep14-int.chello.nl" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S2993215AbXEDKe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 06:34:58 -0400
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

