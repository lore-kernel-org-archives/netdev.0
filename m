From: Tom Lendacky <toml@us.ibm.com>
Subject: [PATCH] (Updated) IPSec: IPv6 source address not set correctly in
	xfrm_state
Date: 21 Mar 2003 11:39:50 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1048268391.1244.2.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, toml@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Here is the updated patch.

Thanks,
Tom

--- linux-2.5.65-orig/net/ipv4/xfrm_state.c	2003-03-17 15:44:21.000000000 -0600
+++ linux-2.5.65/net/ipv4/xfrm_state.c	2003-03-21 10:51:53.000000000 -0600
@@ -404,7 +404,7 @@
 			memcpy(&x->id.daddr, daddr, sizeof(x->sel.daddr));
 		memcpy(&x->props.saddr, &tmpl->saddr, sizeof(x->props.saddr));
 		if (ipv6_addr_any((struct in6_addr*)&x->props.saddr))
-			memcpy(&x->props.saddr, &saddr, sizeof(x->sel.saddr));
+			memcpy(&x->props.saddr, saddr, sizeof(x->props.saddr));
 		x->props.mode = tmpl->mode;
 		x->props.reqid = tmpl->reqid;
 		x->props.family = AF_INET6;
