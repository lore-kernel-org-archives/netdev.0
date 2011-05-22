From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] net: filter: move forward declarations to avoid compile
 warnings
Date: Sun, 22 May 2011 19:08:11 +0200
Message-ID: <20110522170811.GA2758@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:44735 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683Ab1EVRIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 13:08:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Get rid of this compile warning:

In file included from arch/s390/kernel/compat_linux.c:37:0:
include/linux/filter.h:139:23: warning: 'struct sk_buff' declared inside parameter list

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---

 include/linux/filter.h |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 4609b85..9ee3f9f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -131,6 +131,10 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_LL_OFF    (-0x200000)
 
 #ifdef __KERNEL__
+
+struct sk_buff;
+struct sock;
+
 struct sk_filter
 {
 	atomic_t		refcnt;
@@ -146,9 +150,6 @@ static inline unsigned int sk_filter_len(const struct sk_filter *fp)
 	return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
 }
 
-struct sk_buff;
-struct sock;
-
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
 extern unsigned int sk_run_filter(const struct sk_buff *skb,
 				  const struct sock_filter *filter);
