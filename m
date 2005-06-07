From: pmeda@akamai.com
Subject: [patch] devinet: cleanup if statements
Date: Tue, 7 Jun 2005 13:32:44 -0700
Message-ID: <200506072032.NAA06207@allur.sanmateo.akamai.com>
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Cleanup the devinet if statements.
 - when there is no colon, interface name is same as device.
 - ifa_label is an array, not a pointer, and so can never be null.

Signed-Off-by: Prasanna Meda <pmeda@akamai.com>

--- a/net/ipv4/devinet.c	Wed Jun  1 23:54:37 2005
+++ b/net/ipv4/devinet.c	Wed Jun  1 23:57:16 2005
@@ -636,10 +636,7 @@
 			ret = -ENOBUFS;
 			if ((ifa = inet_alloc_ifa()) == NULL)
 				break;
-			if (colon)
-				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
-			else
-				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
+			memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
 		} else {
 			ret = 0;
 			if (ifa->ifa_local == sin->sin_addr.s_addr)
@@ -746,10 +743,7 @@
 		if (len < (int) sizeof(ifr))
 			break;
 		memset(&ifr, 0, sizeof(struct ifreq));
-		if (ifa->ifa_label)
-			strcpy(ifr.ifr_name, ifa->ifa_label);
-		else
-			strcpy(ifr.ifr_name, dev->name);
+		strcpy(ifr.ifr_name, ifa->ifa_label);
 
 		(*(struct sockaddr_in *)&ifr.ifr_addr).sin_family = AF_INET;
 		(*(struct sockaddr_in *)&ifr.ifr_addr).sin_addr.s_addr =
