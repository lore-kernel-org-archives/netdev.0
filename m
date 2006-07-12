From: Tetsuo Takata <takata.tetsuo@oss.ntt.co.jp>
Subject: [PATCH] bonding: enhance the IP address check of arp_ip_target
Date: Wed, 12 Jul 2006 13:25:52 +0900
Message-ID: <44B479D0.5080204@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, takatatt@intellilink.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv1.oss.ntt.co.jp ([222.151.198.98]:54675 "EHLO
	serv1.oss.ntt.co.jp") by vger.kernel.org with ESMTP id S932413AbWGLEZ5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 00:25:57 -0400
To: bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


I found this in drivers/net/bonding/bond_main.c.
> /* not complete check, but should be good enough to
>     catch mistakes */

I made a patch which I believe is little bit better than this,
I hope...


best regards,

---
Signed-off-by: Tetsuo Takata <takatatt@intellilink.co.jp>

--- linux-2.6.17.3/drivers/net/bonding/bond_main.c	2006-07-01 02:37:38.000000000 +0900
+++ linux-2.6.17.3-bonding-ipcheck/drivers/net/bonding/bond_main.c	2006-07-12 09:51:12.000000000 +0900
@@ -4455,7 +4455,113 @@ static int bond_check_params(struct bond
 	     arp_ip_count++) {
 		/* not complete check, but should be good enough to
 		   catch mistakes */
-		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
+		int i, notip = 0;
+		char *cp;
+
+		cp = arp_ip_target[arp_ip_count];
+
+		/* notip's number is the error code for debug purpose */
+		do {
+			if (cp == NULL) {
+				notip = 1;
+				break;
+			}
+
+			/* check digit */
+			for (i = 0; isdigit(*cp); i++) {
+				if ((i < 0) || (i >= 3)) {
+					notip = 2;
+					break;
+				}
+				cp++;
+			}
+			if (notip)
+				break;
+
+			if (i == 0) {
+				notip = 3;
+				break;
+			}
+
+			/* check delimiter */
+			if (*cp != '.') {
+				notip = 4;
+				break;
+			}
+			cp++;
+
+			/* check digit */
+			for (i = 0; isdigit(*cp); i++) {
+				if ((i < 0) || (i >= 3)) {
+					notip = 5;
+					break;
+				}
+				cp++;
+			}
+			if (notip)
+				break;
+
+			if (i == 0) {
+				notip = 6;
+				break;
+			}
+
+			/* check delimiter */
+			if (*cp != '.') {
+				notip = 7;
+				break;
+			}
+			cp++;
+
+			/* check digit */
+			for (i = 0; isdigit(*cp); i++) {
+				if ((i < 0) || (i >= 3)) {
+					notip = 8;
+					break;
+				}
+				cp++;
+			}
+			if (notip)
+				break;
+
+			if (i == 0) {
+				notip = 9;
+				break;
+			}
+
+			/* check delimiter */
+			if (*cp != '.') {
+				notip = 10;
+				break;
+			}
+			cp++;
+
+			/* check digit */
+			for (i = 0; isdigit(*cp); i++) {
+				if ((i < 0) || (i >= 3)) {
+					notip = 11;
+					break;
+				}
+				cp++;
+			}
+			if (notip)
+				break;
+
+			if (i == 0) {
+				notip = 12;
+				break;
+			}
+
+
+			/* check EOS */
+			if (*cp != '\0') {
+				notip = 13;
+				break;
+			}
+
+		} while(0);
+
+		if (notip) {
 			printk(KERN_WARNING DRV_NAME
 			       ": Warning: bad arp_ip_target module parameter "
 			       "(%s), ARP monitoring will not be performed\n",

