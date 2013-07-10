From: Eliezer Tamir <eliezer.tamir-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH] socket.7: add description for SO_BUSY_POLL
Date: Wed, 10 Jul 2013 15:17:45 +0300
Message-ID: <20130710121745.13118.86907.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eliezer Tamir <eliezer-rsSRdLmRgNEQhDRD3CWCHA@public.gmane.org>
To: Micahel Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add description for the SO_BUSY_POLL socket option to the socket(7) manpage.

Signed-off-by: Eliezer Tamir <eliezer.tamir-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---

 man7/socket.7 |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/man7/socket.7 b/man7/socket.7
index f2213eb..27603c9 100644
--- a/man7/socket.7
+++ b/man7/socket.7
@@ -694,6 +694,31 @@ for details on control messages.
 Gets the socket type as an integer (e.g.,
 .BR SOCK_STREAM ).
 This socket option is read-only.
+.TP
+.B SO_BUSY_POLL
+Sets the approximate time in microseconds to busy poll on a blocking receive
+when there is no data. Increasing this value requires
+.BR CAP_NET_ADMIN . 
+The default for this option is controlled by the
+.I /proc/sys/net/core/busy_read
+file. 
+
+The value in the  
+.I /proc/sys/net/core/busy_poll
+file determines how long 
+.BR select (2)
+and 
+.BR poll (2)
+will busy poll when they operate on sockets with 
+.BR SO_BUSY_POLL
+set and no events to report are found.
+
+In both cases busy polling will only be done when the socket last received data
+from a network device that supports this option.
+
+While busy polling my improve latency of some application, care must be
+taken when using it since this will increase both CPU utilization power usage.
+
 .SS Signals
 When writing onto a connection-oriented socket that has been shut down
 (by the local or the remote end)

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
