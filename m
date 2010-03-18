From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/9] ipv6: addrconf timer changes
Date: Wed, 17 Mar 2010 23:31:14 -0700
Message-ID: <20100318063123.232844056@vyatta.com>
References: <20100318063108.109693694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:33125 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753125Ab0CRGg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 02:36:29 -0400
Content-Disposition: inline; filename=addrconf-timer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For addrconf timer use round_jiffies to round off to next interval
(rather than manual rounding).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ipv6/addrconf.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv6/addrconf.c	2010-03-15 16:10:25.069213714 -0700
+++ b/net/ipv6/addrconf.c	2010-03-15 16:10:25.709836446 -0700
@@ -3194,7 +3194,7 @@ restart:
 		}
 	}
 
-	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
+	addr_chk_timer.expires = round_jiffies(next);
 	add_timer(&addr_chk_timer);
 	spin_unlock(&addrconf_verify_lock);
 	rcu_read_unlock_bh();

-- 

