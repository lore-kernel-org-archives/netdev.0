From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: kill 2 warnings in net/ipv6/ip6_tunnel.c
Date: Wed, 18 Jun 2003 00:07:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618.000728.77526626.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This patch kills 2 warnings in net/ipv6/ip6_tunnel.c.

Thanks.

Index: linux25-LINUS/net/ipv6/ip6_tunnel.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ip6_tunnel.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 ip6_tunnel.c
--- linux25-LINUS/net/ipv6/ip6_tunnel.c	10 Jun 2003 13:21:55 -0000	1.1.1.1
+++ linux25-LINUS/net/ipv6/ip6_tunnel.c	17 Jun 2003 14:47:00 -0000
@@ -230,8 +230,6 @@
 	dev->init = ip6ip6_tnl_dev_init;
 	memcpy(&t->parms, p, sizeof (*p));
 	t->parms.name[IFNAMSIZ - 1] = '\0';
-	if (t->parms.hop_limit > 255)
-		t->parms.hop_limit = -1;
 	strcpy(dev->name, t->parms.name);
 	if (!dev->name[0]) {
 		int i = 0;
@@ -952,7 +950,7 @@
 	ipv6_addr_copy(&t->parms.laddr, &p->laddr);
 	ipv6_addr_copy(&t->parms.raddr, &p->raddr);
 	t->parms.flags = p->flags;
-	t->parms.hop_limit = (p->hop_limit <= 255 ? p->hop_limit : -1);
+	t->parms.hop_limit = p->hop_limit;
 	t->parms.encap_limit = p->encap_limit;
 	t->parms.flowinfo = p->flowinfo;
 	ip6ip6_tnl_link_config(t);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
