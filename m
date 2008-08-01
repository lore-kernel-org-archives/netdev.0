From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] net/ipv4/route.c: fix build error
Date: Fri, 01 Aug 2008 09:40:59 +0800
Message-ID: <489269AB.8050706@cn.fujitsu.com>
References: <20080727075933.GB28946@ZenIV.linux.org.uk> <20080727.044118.102038262.davem@davemloft.net> <20080727213905.GA4499@elte.hu> <20080727214250.GA5917@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, viro@ZenIV.linux.org.uk,
	NETDEV <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63008 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbYHABm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 21:42:57 -0400
In-Reply-To: <20080727214250.GA5917@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, the build error keeps showing several days.


From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 27 Jul 2008 23:51:45 +0200
Subject: [PATCH] net/ipv4/route.c: fix build error

fix:

net/ipv4/route.c: In function 'ip_static_sysctl_init':
net/ipv4/route.c:3225: error: 'ipv4_route_path' undeclared (first use in this function)
net/ipv4/route.c:3225: error: (Each undeclared identifier is reported only once
net/ipv4/route.c:3225: error: for each function it appears in.)
net/ipv4/route.c:3225: error: 'ipv4_route_table' undeclared (first use in this function)

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 net/ipv4/route.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 380d647..d7bf056 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3222,7 +3222,9 @@ int __init ip_rt_init(void)
  */
 void __init ip_static_sysctl_init(void)
 {
+#ifdef CONFIG_SYSCTL
 	register_sysctl_paths(ipv4_route_path, ipv4_route_table);
+#endif
 }
 
 EXPORT_SYMBOL(__ip_select_ident);
--

