From: Peter Chubb <peterc@gelato.unsw.edu.au>
Subject: [PATCH] Fix fallout from CONFIG_IPV6_PRIVACY
Date: Wed, 9 Nov 2005 11:16:58 +1100
Message-ID: <17265.16378.77270.7493@berry.gelato.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030448AbVKIARD@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Trying to build today's 2.6.14+git snapshot gives undefined references
to use_tempaddr

Looks like an ifdef got left out.

Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

 net/ipv6/addrconf.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6-import/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-import.orig/net/ipv6/addrconf.c	2005-11-09 11:11:42.137993239 +1100
+++ linux-2.6-import/net/ipv6/addrconf.c	2005-11-09 11:12:39.857561898 +1100
@@ -1022,6 +1022,7 @@ int ipv6_dev_get_saddr(struct net_device
 					continue;
 			}
 
+#ifdef CONFIG_IPV6_PRIVACY
 			/* Rule 7: Prefer public address
 			 * Note: prefer temprary address if use_tempaddr >= 2
 			 */
@@ -1043,7 +1044,7 @@ int ipv6_dev_get_saddr(struct net_device
 				if (hiscore.attrs & IPV6_SADDR_SCORE_PRIVACY)
 					continue;
 			}
-
+#endif
 			/* Rule 8: Use longest matching prefix */
 			if (hiscore.rule < 8)
 				hiscore.matchlen = ipv6_addr_diff(&ifa_result->addr, daddr);
