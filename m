From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [IPV6]: Fix tunnel list locking in ip6_tunnel.c.
Date: Sat, 05 Feb 2005 01:56:33 +0900 (JST)
Message-ID: <20050205.015633.45798306.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

We need to fix tunnel list locking in ip6_tunnel.c as well.
Noticed by jean-mickael guerin <jean-mickael.guerin@6WIND.com>.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/ip6_tunnel.c 1.27 vs edited =====
--- 1.27/net/ipv6/ip6_tunnel.c	2005-01-14 13:41:06 +09:00
+++ edited/net/ipv6/ip6_tunnel.c	2005-02-05 01:50:53 +09:00
@@ -180,10 +180,10 @@
 {
 	struct ip6_tnl **tp = ip6ip6_bucket(&t->parms);
 
-	write_lock_bh(&ip6ip6_lock);
 	t->next = *tp;
-	write_unlock_bh(&ip6ip6_lock);
+	write_lock_bh(&ip6ip6_lock);
 	*tp = t;
+	write_unlock_bh(&ip6ip6_lock);
 }
 
 /**

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
