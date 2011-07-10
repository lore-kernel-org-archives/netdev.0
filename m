From: Gilles Espinasse <g.esp@free.fr>
Subject: [PATCH] iproute2: fix implicit declaration of function '__ALIGN_KERNEL'
Date: Sun, 10 Jul 2011 17:46:20 +0200
Message-ID: <1310312780-2323-1-git-send-email-g.esp@free.fr>
Cc: Gilles Espinasse <g.esp@free.fr>
To: netdev@vger.kernel.org, shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:48577 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561Ab1GJPhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 11:37:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Warning seen with 2.6.32 kernel headers
 m_xt.c:85: warning: implicit declaration of function '__ALIGN_KERNEL'

Declaration lines borrowed from iptables-1.4.11.1

Signed-off-by: Gilles Espinasse <g.esp@free.fr>
---
 include/linux/netfilter/x_tables.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 4120970..a6614b0 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -96,6 +96,8 @@ struct _xt_align {
 	__u64 u64;
 };
 
+#define __ALIGN_KERNEL(x, a)	__ALIGN_KERNEL_MASK(x, (typeof(x))(a) - 1)
+#define __ALIGN_KERNEL_MASK(x, mask)	(((x) + (mask)) & ~(mask))
 #define XT_ALIGN(s) __ALIGN_KERNEL((s), __alignof__(struct _xt_align))
 
 /* Standard return verdict, or do jump. */
-- 
1.5.6.5

