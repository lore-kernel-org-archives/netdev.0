From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/21] netfilter: ipset: Fix ext_*() macros
Date: Mon, 18 May 2015 18:25:15 +0200
Message-ID: <1431966324-4494-13-git-send-email-pablo@netfilter.org>
References: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44022 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932399AbbERQUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 12:20:48 -0400
In-Reply-To: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ua>

So pointers returned by these macros could be
referenced with -> directly.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 34b1723..f88be72 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -122,13 +122,13 @@ struct ip_set_skbinfo {
 struct ip_set;
 
 #define ext_timeout(e, s)	\
-(unsigned long *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_TIMEOUT])
+((unsigned long *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_TIMEOUT]))
 #define ext_counter(e, s)	\
-(struct ip_set_counter *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COUNTER])
+((struct ip_set_counter *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COUNTER]))
 #define ext_comment(e, s)	\
-(struct ip_set_comment *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COMMENT])
+((struct ip_set_comment *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COMMENT]))
 #define ext_skbinfo(e, s)	\
-(struct ip_set_skbinfo *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_SKBINFO])
+((struct ip_set_skbinfo *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_SKBINFO]))
 
 typedef int (*ipset_adtfn)(struct ip_set *set, void *value,
 			   const struct ip_set_ext *ext,
-- 
1.7.10.4
