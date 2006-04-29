From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 2/3] Eleminate HZ from NET/ROM kernel interfaces
Date: Sat, 29 Apr 2006 15:16:13 +0100
Message-ID: <20060429141613.GA2811@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:26249 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750778AbWD2Sre
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 14:47:34 -0400
Received: from localhost.localdomain ([127.0.0.1]:59333 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133564AbWD2Sre (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Sat, 29 Apr 2006 19:47:34 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert all NET/ROM sysctl time values from jiffies to ms as units.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

--

 include/net/netrom.h   |    8 ++++----
 net/netrom/af_netrom.c |   15 ++++++++++-----
 2 files changed, 14 insertions(+), 9 deletions(-)

Index: linux-net.git/include/net/netrom.h
===================================================================
--- linux-net.git.orig/include/net/netrom.h	2006-04-29 01:43:48.000000000 +0100
+++ linux-net.git/include/net/netrom.h	2006-04-29 11:37:27.000000000 +0100
@@ -42,11 +42,11 @@ enum {
 #define	NR_COND_PEER_RX_BUSY		0x04
 #define	NR_COND_OWN_RX_BUSY		0x08
 
-#define NR_DEFAULT_T1			(120 * HZ)	/* Outstanding frames - 120 seconds */
-#define NR_DEFAULT_T2			(5   * HZ)	/* Response delay     - 5 seconds */
+#define NR_DEFAULT_T1			120000		/* Outstanding frames - 120 seconds */
+#define NR_DEFAULT_T2			5000		/* Response delay     - 5 seconds */
 #define NR_DEFAULT_N2			3		/* Number of Retries - 3 */
-#define	NR_DEFAULT_T4			(180 * HZ)	/* Busy Delay - 180 seconds */
-#define	NR_DEFAULT_IDLE			(0 * 60 * HZ)	/* No Activity Timeout - none */
+#define	NR_DEFAULT_T4			180000		/* Busy Delay - 180 seconds */
+#define	NR_DEFAULT_IDLE			0		/* No Activity Timeout - none */
 #define	NR_DEFAULT_WINDOW		4		/* Default Window Size - 4 */
 #define	NR_DEFAULT_OBS			6		/* Default Obsolescence Count - 6 */
 #define	NR_DEFAULT_QUAL			10		/* Default Neighbour Quality - 10 */
Index: linux-net.git/net/netrom/af_netrom.c
===================================================================
--- linux-net.git.orig/net/netrom/af_netrom.c	2006-04-29 01:54:21.000000000 +0100
+++ linux-net.git/net/netrom/af_netrom.c	2006-04-29 11:37:27.000000000 +0100
@@ -425,11 +425,16 @@ static int nr_create(struct socket *sock
 
 	nr_init_timers(sk);
 
-	nr->t1     = sysctl_netrom_transport_timeout;
-	nr->t2     = sysctl_netrom_transport_acknowledge_delay;
-	nr->n2     = sysctl_netrom_transport_maximum_tries;
-	nr->t4     = sysctl_netrom_transport_busy_delay;
-	nr->idle   = sysctl_netrom_transport_no_activity_timeout;
+	nr->t1     =
+		msecs_to_jiffies(sysctl_netrom_transport_timeout);
+	nr->t2     =
+		msecs_to_jiffies(sysctl_netrom_transport_acknowledge_delay);
+	nr->n2     =
+		msecs_to_jiffies(sysctl_netrom_transport_maximum_tries);
+	nr->t4     =
+		msecs_to_jiffies(sysctl_netrom_transport_busy_delay);
+	nr->idle   =
+		msecs_to_jiffies(sysctl_netrom_transport_no_activity_timeout);
 	nr->window = sysctl_netrom_transport_requested_window_size;
 
 	nr->bpqext = 1;
