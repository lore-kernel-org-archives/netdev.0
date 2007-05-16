From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [patch 1/7] CAN: Allocate protocol numbers for PF_CAN
Date: Wed, 16 May 2007 16:51:01 +0200
Message-ID: <20070516145120.29877.1@janus.isnogud.escape.de>
References: <20070516145100.29877.0@janus.isnogud.escape.de>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:58939 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756709AbXEPPUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 11:20:16 -0400
Content-Disposition: inline; filename=01-can-proto-numbers.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a protocol/address family number, ARP hardware type,
ethernet packet type, and a line discipline number for the SocketCAN
implementation.

Signed-Off-By: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Signed-Off-By: Urs Thuermann <urs.thuermann@volkswagen.de>

---
 include/linux/if_arp.h   |    1 +
 include/linux/if_ether.h |    1 +
 include/linux/socket.h   |    2 ++
 include/linux/tty.h      |    3 ++-
 4 files changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6.22-rc1-git4/include/linux/if_arp.h
===================================================================
--- linux-2.6.22-rc1-git4.orig/include/linux/if_arp.h	2007-05-16 09:33:50.000000000 +0200
+++ linux-2.6.22-rc1-git4/include/linux/if_arp.h	2007-05-16 09:34:18.000000000 +0200
@@ -52,6 +52,7 @@
 #define ARPHRD_ROSE	270
 #define ARPHRD_X25	271		/* CCITT X.25			*/
 #define ARPHRD_HWX25	272		/* Boards with X.25 in firmware	*/
+#define ARPHRD_CAN	280		/* Controller Area Network      */
 #define ARPHRD_PPP	512
 #define ARPHRD_CISCO	513		/* Cisco HDLC	 		*/
 #define ARPHRD_HDLC	ARPHRD_CISCO
Index: linux-2.6.22-rc1-git4/include/linux/if_ether.h
===================================================================
--- linux-2.6.22-rc1-git4.orig/include/linux/if_ether.h	2007-05-16 09:33:50.000000000 +0200
+++ linux-2.6.22-rc1-git4/include/linux/if_ether.h	2007-05-16 09:34:18.000000000 +0200
@@ -89,6 +89,7 @@
 #define ETH_P_WAN_PPP   0x0007          /* Dummy type for WAN PPP frames*/
 #define ETH_P_PPP_MP    0x0008          /* Dummy type for PPP MP frames */
 #define ETH_P_LOCALTALK 0x0009		/* Localtalk pseudo type 	*/
+#define ETH_P_CAN	0x000C		/* Controller Area Network      */
 #define ETH_P_PPPTALK	0x0010		/* Dummy type for Atalk over PPP*/
 #define ETH_P_TR_802_2	0x0011		/* 802.2 frames 		*/
 #define ETH_P_MOBITEX	0x0015		/* Mobitex (kaz@cafe.net)	*/
Index: linux-2.6.22-rc1-git4/include/linux/socket.h
===================================================================
--- linux-2.6.22-rc1-git4.orig/include/linux/socket.h	2007-05-16 09:33:50.000000000 +0200
+++ linux-2.6.22-rc1-git4/include/linux/socket.h	2007-05-16 09:34:18.000000000 +0200
@@ -185,6 +185,7 @@
 #define AF_PPPOX	24	/* PPPoX sockets		*/
 #define AF_WANPIPE	25	/* Wanpipe API Sockets */
 #define AF_LLC		26	/* Linux LLC			*/
+#define AF_CAN		29	/* Controller Area Network      */
 #define AF_TIPC		30	/* TIPC sockets			*/
 #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
 #define AF_IUCV		32	/* IUCV sockets			*/
@@ -220,6 +221,7 @@
 #define PF_PPPOX	AF_PPPOX
 #define PF_WANPIPE	AF_WANPIPE
 #define PF_LLC		AF_LLC
+#define PF_CAN		AF_CAN
 #define PF_TIPC		AF_TIPC
 #define PF_BLUETOOTH	AF_BLUETOOTH
 #define PF_IUCV		AF_IUCV
Index: linux-2.6.22-rc1-git4/include/linux/tty.h
===================================================================
--- linux-2.6.22-rc1-git4.orig/include/linux/tty.h	2007-05-16 09:33:50.000000000 +0200
+++ linux-2.6.22-rc1-git4/include/linux/tty.h	2007-05-16 09:34:18.000000000 +0200
@@ -24,7 +24,7 @@
 #define NR_PTYS	CONFIG_LEGACY_PTY_COUNT   /* Number of legacy ptys */
 #define NR_UNIX98_PTY_DEFAULT	4096      /* Default maximum for Unix98 ptys */
 #define NR_UNIX98_PTY_MAX	(1 << MINORBITS) /* Absolute limit */
-#define NR_LDISCS		17
+#define NR_LDISCS		18
 
 /* line disciplines */
 #define N_TTY		0
@@ -45,6 +45,7 @@
 #define N_SYNC_PPP	14	/* synchronous PPP */
 #define N_HCI		15	/* Bluetooth HCI UART */
 #define N_GIGASET_M101	16	/* Siemens Gigaset M101 serial DECT adapter */
+#define N_SLCAN		17	/* Serial / USB serial CAN Adaptors */
 
 /*
  * This character is the same as _POSIX_VDISABLE: it cannot be used as

--
