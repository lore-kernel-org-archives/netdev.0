From: Olaf Hering <olh@suse.de>
Subject: comment about struct tcp_tw_bucket in struct sock
Date: Tue, 13 May 2003 23:05:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030513210541.GA4415@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo@conectiva.com.br>,
   "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

we just hit this one. struct tcp_tw_bucket and stuct sock must match.

Please apply.



--- linux-2.4/include/net/sock.h	2003-04-24 17:11:20.000000000 +0200
+++ linux-2.4.21-rc2/include/net/sock.h	2003-05-13 23:00:32.000000000 +0200
@@ -498,6 +498,10 @@ do {	spin_lock_init(&((__sk)->lock.slock
 } while(0)
 
 struct sock {
+	/* These _must_ match the beginning of struct tcp_tw_bucket precisely.
+	 * XXX Yes I know this is gross, but I'd have to edit every single
+	 * XXX networking file if I created a "struct sock_header". -DaveM
+	 */
 	/* Socket demultiplex comparisons on incoming packets. */
 	__u32			daddr;		/* Foreign IPv4 addr			*/
 	__u32			rcv_saddr;	/* Bound local IPv4 addr		*/

-- 
USB is for mice, FireWire is for men!
