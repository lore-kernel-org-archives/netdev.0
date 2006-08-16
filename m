From: jamal <hadi@cyberus.ca>
Subject: [PATCH][IPSEC]: Aggregate make_jiffies
Date: Tue, 15 Aug 2006 21:58:19 -0400
Message-ID: <1155693500.5122.39.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-asDMpWmo+1bHy7roN4My"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:37583 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750713AbWHPB6f
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 21:58:35 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GDAfs-0001Ii-O1
	for netdev@vger.kernel.org; Tue, 15 Aug 2006 21:58:28 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-asDMpWmo+1bHy7roN4My
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


make_jiffies definition is repeated in xfrm_state and xfrm_policy.
Aggregate in header instead. Against Dave's last perf improvement
patches.

signed-off-by: Jamal Hadi Salim<hadi@cyberus.ca>




--=-asDMpWmo+1bHy7roN4My
Content-Disposition: attachment; filename=ipsec-p111
Content-Type: text/x-patch; name=ipsec-p111; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 8123d49..05444dd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -619,6 +619,14 @@ xfrm_state_addr_cmp(struct xfrm_tmpl *tm
 	return !0;
 }
 
+static inline unsigned long make_jiffies(long secs)
+{
+	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
+		return MAX_SCHEDULE_TIMEOUT-1;
+	else
+		return secs*HZ;
+}
+
 #ifdef CONFIG_XFRM
 
 extern int __xfrm_policy_check(struct sock *, int dir, struct sk_buff *skb, unsigned short family);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index a378812..cd785be 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -220,14 +220,6 @@ void xfrm_put_mode(struct xfrm_mode *mod
 	module_put(mode->owner);
 }
 
-static inline unsigned long make_jiffies(long secs)
-{
-	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
-		return MAX_SCHEDULE_TIMEOUT-1;
-	else
-	        return secs*HZ;
-}
-
 static void xfrm_policy_timer(unsigned long data)
 {
 	struct xfrm_policy *xp = (struct xfrm_policy*)data;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b1c0ae7..00ae0f8 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -264,14 +264,6 @@ static void xfrm_state_gc_task(void *dat
 	wake_up(&km_waitq);
 }
 
-static inline unsigned long make_jiffies(long secs)
-{
-	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
-		return MAX_SCHEDULE_TIMEOUT-1;
-	else
-	        return secs*HZ;
-}
-
 static void xfrm_timer_handler(unsigned long data)
 {
 	struct xfrm_state *x = (struct xfrm_state*)data;

--=-asDMpWmo+1bHy7roN4My--

