From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Fix warning/error in hamradio/scc.c
Date: Sat, 27 Sep 2003 21:01:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030927210149.667dbe50.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 gcc 3.3 complains that scc.c is trying to compare TIMER_OFF (65536U)
with mintime (unsigned char).  Looks like the driver writer
should have used an unsigned short instead.

diff -Nru a/include/linux/scc.h b/include/linux/scc.h
--- a/include/linux/scc.h	Sat Sep 27 20:57:30 2003
+++ b/include/linux/scc.h	Sat Sep 27 20:57:30 2003
@@ -200,7 +200,7 @@
 	unsigned char fulldup;		/* Full Duplex mode 0=CSMA 1=DUP 2=ALWAYS KEYED */
 	unsigned char waittime;		/* Waittime before any transmit attempt */
 	unsigned int  maxkeyup;		/* Maximum time to transmit (seconds) */
-	unsigned char mintime;		/* Minimal offtime after MAXKEYUP timeout (seconds) */
+	unsigned short mintime;		/* Minimal offtime after MAXKEYUP timeout (seconds) */
 	unsigned int  idletime;		/* Maximum idle time in ALWAYS KEYED mode (seconds) */
 	unsigned int  maxdefer;		/* Timer for CSMA channel busy limit */
 	unsigned char tx_inhibit;	/* Transmit is not allowed when set */	
