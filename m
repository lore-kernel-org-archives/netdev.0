From: Chris Wright <chrisw@osdl.org>
Subject: [PATCH] trivial ipmr pim_protocol compile fix
Date: Thu, 11 Mar 2004 18:01:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040311180121.B21045@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

pim_protocol is defined but never used if !CONFIG_IP_PIMSM_V2

  CC      net/ipv4/ipmr.o
net/ipv4/ipmr.c:112: warning: `pim_protocol' defined but not used

I hate adding more ifdefs to this file, but here goes the simplest fix.

===== net/ipv4/ipmr.c 1.37 vs edited =====
--- 1.37/net/ipv4/ipmr.c	Mon Feb 23 15:09:54 2004
+++ edited/net/ipv4/ipmr.c	Thu Mar 11 17:55:40 2004
@@ -109,7 +109,9 @@
 static int ipmr_cache_report(struct sk_buff *pkt, vifi_t vifi, int assert);
 static int ipmr_fill_mroute(struct sk_buff *skb, struct mfc_cache *c, struct rtmsg *rtm);
 
+#ifdef CONFIG_IP_PIMSM_V2
 static struct inet_protocol pim_protocol;
+#endif
 
 static struct timer_list ipmr_expire_timer;
 
