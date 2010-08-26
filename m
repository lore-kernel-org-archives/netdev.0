From: Bernard F6BVP <f6bvp@free.fr>
Subject: [PATCH] [AX25] missplaced sock_put(sk)
Date: Thu, 26 Aug 2010 21:34:32 +0200
Message-ID: <4C76C1C8.6060007@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040202080800070901050500"
Cc: davem@davemloft.net, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, bpidoux@free.fr
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040202080800070901050500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

[PATCH] [AX25] missplaced sock_put(sk)

This patch moves a missplaced sock_put(sk) after
bh_unlock_sock(sk)
like in other parts of AX25 driver.

Bernard Pidoux



--------------040202080800070901050500
Content-Type: text/x-patch;
 name="ax25_ds_timer.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ax25_ds_timer.patch"

--- linux/net/ax25/ax25_ds_timer.c	2010-08-13 22:44:56.000000000 +0200
+++ linux/net/ax25/ax25_ds_timer.c	2010-08-26 19:55:13.000000000 +0200
@@ -112,8 +112,8 @@
 			if (sk) {
 				sock_hold(sk);
 				ax25_destroy_socket(ax25);
-				sock_put(sk);
 				bh_unlock_sock(sk);
+				sock_put(sk);
 			} else
 				ax25_destroy_socket(ax25);
 			return;

--------------040202080800070901050500--
