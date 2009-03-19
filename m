From: Richard Kennedy <richard@rsk.demon.co.uk>
Subject: [PATCH] ipv6: reorder struct inet6_ifaddr to remove padding on 64
 bit builds
Date: Thu, 19 Mar 2009 15:32:40 +0000
Message-ID: <1237476760.3266.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: yoshfuji@linux-ipv6.org, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-2.mail.demon.net ([195.173.77.133]:45994 "EHLO
	anchor-post-2.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752424AbZCSPco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 11:32:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reorder struct inet6_ifaddr to remove padding on 64 bit builds
    
remove 8 bytes of padding so inet6_ifaddr becomes 192 bytes & fits into
a smaller slab.
    
Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
----
patch against v2.6.29-rc8

I've compiled & booted with this patch, modules ipv6 & ip6_tables load
successfully, but I've not run any other tests.

regards
Richard
 



diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index c8effa4..38b7813 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -39,8 +39,6 @@ struct inet6_ifaddr
 	
 	__u32			valid_lft;
 	__u32			prefered_lft;
-	unsigned long		cstamp;	/* created timestamp */
-	unsigned long		tstamp; /* updated timestamp */
 	atomic_t		refcnt;
 	spinlock_t		lock;
 
@@ -49,6 +47,9 @@ struct inet6_ifaddr
 
 	__u16			scope;
 
+	unsigned long		cstamp;	/* created timestamp */
+	unsigned long		tstamp; /* updated timestamp */
+
 	struct timer_list	timer;
 
 	struct inet6_dev	*idev;


