From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH v2] socket.7: add description for SO_BUSY_POLL
Date: Wed, 10 Jul 2013 17:18:35 +0300
Message-ID: <20130710141835.15799.61657.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-man@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Micahel Kerrisk <mtk.manpages@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add description for the SO_BUSY_POLL socket option to the socket(7) manpage.

v2
fixed typos reported by Rasmus Villemoes

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 man7/socket.7 |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/man7/socket.7 b/man7/socket.7
index f2213eb..5edcb09 100644
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
+While busy polling may improve latency of some applications, care must be
+taken when using it since this will increase both CPU utilization and power usage.
+
 .SS Signals
 When writing onto a connection-oriented socket that has been shut down
 (by the local or the remote end)
