From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v6 1/1] ipv6: add support of equal cost
 multipath (ECMP)
Date: Tue, 02 Oct 2012 18:14:27 +0200
Message-ID: <1349194467.12401.810.camel@edumazet-glaptop>
References: <1349110077.7740.23.camel@joe-AO722>
	 <1349193767-3992-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1349193767-3992-2-git-send-email-nicolas.dichtel@6wind.com>
	 <506B1104.7030908@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, bernat@luffy.cx, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49056 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951Ab2JBQOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 12:14:31 -0400
Received: by bkcjk13 with SMTP id jk13so5613742bkc.19
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 09:14:30 -0700 (PDT)
In-Reply-To: <506B1104.7030908@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-02 at 18:06 +0200, Nicolas Dichtel wrote:

> I forget to run checkpatch.pl, some lines are over 80 columns. I will fix it in 
> the v7 with other comments (if any).
> --

Yep, please reorder :

@@ -98,6 +100,15 @@ struct rt6_info {
        struct fib6_node                *rt6i_node;
 
        struct in6_addr                 rt6i_gateway;
+#ifdef CONFIG_IPV6_MULTIPATH
+       /*
+        * siblings is a list of rt6_info that have the the same metric/weight,
+        * destination, but not the same gateway. nsiblings is just a cache
+        * to speed up lookup.
+        */
+       unsigned int                    rt6i_nsiblings;
+       struct list_head                rt6i_siblings;
+#endif
 
        atomic_t                        rt6i_ref;
 
@@ -318,4 +329,43 @@ static inline void              fib6_rules_cleanup(void)
        return ;
 }

to :

@@ -98,6 +100,15 @@ struct rt6_info {
        struct fib6_node                *rt6i_node;
 
        struct in6_addr                 rt6i_gateway;
+#ifdef CONFIG_IPV6_MULTIPATH
+       /*
+        * siblings is a list of rt6_info that have the the same metric/weight,
+        * destination, but not the same gateway. nsiblings is just a cache
+        * to speed up lookup.
+        */
+       struct list_head                rt6i_siblings;
+       unsigned int                    rt6i_nsiblings;
+#endif
 
        atomic_t                        rt6i_ref;
 
@@ -318,4 +329,43 @@ static inline void              fib6_rules_cleanup(void)
        return ;
 }
