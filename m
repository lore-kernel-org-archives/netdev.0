From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11447] New: /proc/sys/net/ipv4/route/flush
 not found
Date: Thu, 28 Aug 2008 13:29:35 -0700 (PDT)
Message-ID: <20080828.132935.193700612.davem@davemloft.net>
References: <bug-11447-10286@http.bugzilla.kernel.org/>
	<20080828131824.49352fa0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: francois.valenduc@tvcablenet.be, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60832
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755977AbYH1U3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 16:29:40 -0400
In-Reply-To: <20080828131824.49352fa0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 28 Aug 2008 13:18:24 -0700

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

Should be fixed in Linus's tree as of an hour ago, it was a
permissions issue:

commit d994af0d50efc96b2077978fe9f066992639d525
Author: Hugh Dickins <hugh@veritas.com>
Date:   Wed Aug 27 02:35:18 2008 -0700

    ipv4: mode 0555 in ipv4_skeleton
    
    vpnc on today's kernel says Cannot open "/proc/sys/net/ipv4/route/flush":
    d--------- 0 root root 0 2008-08-26 11:32 /proc/sys/net/ipv4/route
    d--------- 0 root root 0 2008-08-26 19:16 /proc/sys/net/ipv4/neigh
    
    Signed-off-by: Hugh Dickins <hugh@veritas.com>
    Acked-by: Al Viro <viro@zeniv.linux.org.uk>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e91bafe..6ee5354 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3121,9 +3121,9 @@ static struct ctl_table empty[1];
 static struct ctl_table ipv4_skeleton[] =
 {
 	{ .procname = "route", .ctl_name = NET_IPV4_ROUTE,
-	  .child = ipv4_route_table},
+	  .mode = 0555, .child = ipv4_route_table},
 	{ .procname = "neigh", .ctl_name = NET_IPV4_NEIGH,
-	  .child = empty},
+	  .mode = 0555, .child = empty},
 	{ }
 };
 
