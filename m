From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/4] rcu_assign_pointer: null check fix
Date: Tue, 12 Feb 2008 16:50:43 -0800
Message-ID: <20080213005122.653836965@vyatta.com>
References: <20080213005042.150212716@vyatta.com>
Cc: linux-kernel@vger.kernle.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39667 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754946AbYBMA5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 19:57:14 -0500
Content-Disposition: inline; filename=rcu-assign-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Goofed on last change, should avoid barrier only on rcu_assign_pointer(p, NULL)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 include/linux/rcupdate.h |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

--- a/include/linux/rcupdate.h	2008-02-12 14:46:49.000000000 -0800
+++ b/include/linux/rcupdate.h	2008-02-12 14:56:17.000000000 -0800
@@ -178,7 +178,7 @@ struct rcu_head {
 
 #define rcu_assign_pointer(p, v)			\
 	({						\
-		if (!(__builtin_constant_p(v) && v))	\
+		if (!__builtin_constant_p(v) || v)	\
 			smp_wmb();			\
 		(p) = (v);				\
 	})

-- 
Stephen Hemminger <shemminger@vyatta.com>

