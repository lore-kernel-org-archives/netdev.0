From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] ipv6: clean up rt6_clean_expires
Date: Mon, 16 Apr 2012 15:35:41 +0200
Message-ID: <20120416133541.GC18159@midget.suse.cz>
References: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1333707190-14075-1-git-send-email-gaofeng@cn.fujitsu.com>
 <20120413.125851.894792528374368454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54717 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343Ab2DPNfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 09:35:43 -0400
Content-Disposition: inline
In-Reply-To: <20120413.125851.894792528374368454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functionally, this change is a NOP.

Semantically, rt6_clean_expires() wants to do rt->dst.from = NULL instead of
rt->dst.expires = 0. It is clearing the RTF_EXPIRES flag, so the union is going
to be treated as a pointer (dst.from) not a long (dst.expires).

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index c64778f..ad4126f 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -129,7 +129,7 @@ static inline void rt6_clean_expires(struct rt6_info *rt)
 		dst_release(rt->dst.from);
 
 	rt->rt6i_flags &= ~RTF_EXPIRES;
-	rt->dst.expires = 0;
+	rt->dst.from = NULL;
 }
 
 static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
