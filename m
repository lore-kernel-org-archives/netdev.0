From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] rearrange frto field to save space.
Date: Wed, 21 Apr 2004 11:10:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421111032.0705b605@dell_ss3.pdx.osdl.net>
References: <20040420155738.4146b5bb.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040420155738.4146b5bb.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since the frto_counter field only goes from 0 to 4, it can be moved
into a unused byte size hole to save space.

diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	Wed Apr 21 10:39:07 2004
+++ b/include/linux/tcp.h	Wed Apr 21 10:39:07 2004
@@ -255,6 +255,10 @@
 	__u8	retransmits;	/* Number of unrecovered RTO timeouts.	*/
 
 	__u8	reordering;	/* Packet reordering metric.		*/
+	__u8	frto_counter;	/* Number of new acks after RTO */
+	__u32	frto_highmark;	/* snd_nxt when RTO occurred */
+
+	__u8	unused_pad;
 	__u8	queue_shrunk;	/* Write queue has been shrunk recently.*/
 	__u8	defer_accept;	/* User waits for some data after accept() */
 
@@ -369,9 +373,6 @@
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 	int			linger2;
-
-	int                     frto_counter; /* Number of new acks after RTO */
-	__u32                   frto_highmark; /* snd_nxt when RTO occurred */
 
 	unsigned long last_synq_overflow; 
 
