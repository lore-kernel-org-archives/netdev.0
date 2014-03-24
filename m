From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] ipv4: remove ipv4_ifdown_dst from route.c
Date: Mon, 24 Mar 2014 11:03:10 +0800
Message-ID: <1395630190-12586-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:40219 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbaCXDDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 23:03:11 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so4814287pbc.16
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 20:03:11 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id q7sm30059452pbc.20.2014.03.23.20.03.06
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 20:03:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

ipv4_ifdown_dst does nothing after IPv4 route caches removal,
so we can remove it.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/route.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 11e4384..57527ee 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -139,11 +139,6 @@ static void		 ip_do_redirect(struct dst_entry *dst, struct sock *sk,
 					struct sk_buff *skb);
 static void		ipv4_dst_destroy(struct dst_entry *dst);
 
-static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
-			    int how)
-{
-}
-
 static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	WARN_ON(1);
@@ -162,7 +157,6 @@ static struct dst_ops ipv4_dst_ops = {
 	.mtu =			ipv4_mtu,
 	.cow_metrics =		ipv4_cow_metrics,
 	.destroy =		ipv4_dst_destroy,
-	.ifdown =		ipv4_dst_ifdown,
 	.negative_advice =	ipv4_negative_advice,
 	.link_failure =		ipv4_link_failure,
 	.update_pmtu =		ip_rt_update_pmtu,
-- 
1.7.10.4
