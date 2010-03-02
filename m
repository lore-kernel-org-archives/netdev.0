From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/12] ipv6: addrconf timer changes
Date: Tue, 02 Mar 2010 15:32:54 -0800
Message-ID: <20100302234003.624262891@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58967 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754711Ab0CBXrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:47:42 -0500
Content-Disposition: inline; filename=addrconf-timer.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For addrconf timer:
  * use round_jiffies since this timer doesn't need to happen sub-second
  * use mod_timer for safer timer modification

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ipv6/addrconf.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv6/addrconf.c	2010-03-02 14:46:40.529202001 -0800
+++ b/net/ipv6/addrconf.c	2010-03-02 14:46:44.709576675 -0800
@@ -3202,7 +3202,7 @@ restart:
 		}
 	}
 
-	addr_chk_timer.expires = time_before(next, jiffies + HZ) ? jiffies + HZ : next;
+	addr_chk_timer.expires = round_jiffies(next);
 	add_timer(&addr_chk_timer);
 	spin_unlock(&addrconf_verify_lock);
 	rcu_read_unlock_bh();

-- 

