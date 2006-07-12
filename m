From: Tetsuo Takata <takata.tetsuo@oss.ntt.co.jp>
Subject: Re: [PATCH] bonding: enhance the IP address check of arp_ip_target
Date: Wed, 12 Jul 2006 18:30:40 +0900
Message-ID: <44B4C140.5040403@oss.ntt.co.jp>
References: <E1G0X8h-0003Tg-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	takatatt@intellilink.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.oss.ntt.co.jp ([222.151.198.98]:42903 "EHLO
	serv1.oss.ntt.co.jp") by vger.kernel.org with ESMTP
	id S1751061AbWGLJan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 05:30:43 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1G0X8h-0003Tg-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


Thank you for the comments.


>> Why not just use sscanf?
Here's a fixed version of the previous patch, that uses sscanf.

> 
> Better yet, use a better interface like netlink rather than module
> parameters.
Wouldn't that be overkill?


best regards,

---
Signed-off-by: Tetsuo Takata <takatatt@intellilink.co.jp>

--- linux-2.6.17.4/drivers/net/bonding/bond_main.c	2006-06-18 10:49:35.000000000 +0900
+++ linux-2.6.17.4-enhance-ipcheck/drivers/net/bonding/bond_main.c	2006-07-12 17:20:39.000000000 +0900
@@ -4455,7 +4455,36 @@ static int bond_check_params(struct bond
 	     arp_ip_count++) {
 		/* not complete check, but should be good enough to
 		   catch mistakes */
-		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
+		int ip1, ip2, ip3, ip4, notip = 0;
+		char dummy;
+
+		/* notip's number means error code for debug purpose */
+		do {
+			if (sscanf(arp_ip_target[arp_ip_count], "%d.%d.%d.%d%c",
+					 	&ip1, &ip2, &ip3, &ip4, &dummy) != 4) {
+				notip = 1;
+				break;
+			} else {
+				if (ip1 < 0 || ip1 > 255) {
+					notip = 1;
+					break;
+				}
+				if (ip2 < 0 || ip2 > 255) {
+					notip = 1;
+					break;
+				}
+				if (ip3 < 0 || ip3 > 255) {
+					notip = 1;
+					break;
+				}
+				if (ip4 < 0 || ip4 > 255) {
+					notip = 1;
+					break;
+				}
+			}
+		} while(0);
+
+		if (notip) {
 			printk(KERN_WARNING DRV_NAME
 			       ": Warning: bad arp_ip_target module parameter "
 			       "(%s), ARP monitoring will not be performed\n",

