From: Andre Tomt <andre@tomt.net>
Subject: [PATCH] Fix a gcc-3.4 build failure and gcc-3.3 build warnings with
 TCP_DEBUG disabled in tcp.h
Date: Sat, 12 Mar 2005 07:10:12 +0100
Message-ID: <423287C4.60701@tomt.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040309010906010804090708"
To: Netdev <netdev@oss.sgi.com>, davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040309010906010804090708
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Fix a gcc-3.4 build failure and gcc-3.3 build warnings with TCP_DEBUG 
disabled in tcp.h

Patch (with description and signed-off-by) attached due to braindamaged MUA.

--------------040309010906010804090708
Content-Type: text/x-patch;
 name="fix-tcp-non-debug-build.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-tcp-non-debug-build.patch"

Fix a gcc-3.4 build failure and gcc-3.3 build warnings with TCP_DEBUG
disabled in tcp.h

TCP_DEBUG is default on, but it should work with it off anyway.

With gcc-3.4:
  CC      net/core/sock.o
In file included from net/core/sock.c:127:
include/net/tcp.h: In function `tcp_reset_xmit_timer':
include/net/tcp.h:1042: error: label at end of compound statement
make[3]: *** [net/core/sock.o] Error 1
make[2]: *** [net/core] Error 2
make[1]: *** [net] Error 2
make[1]: Leaving directory `/build/kernel/linux-2.6.11-s3'
make: *** [stamp-build] Error 2

With gcc-3.3:
In file included from net/ipv4/icmp.c:84:
include/net/tcp.h: In function `tcp_reset_xmit_timer':
include/net/tcp.h:1042: warning: deprecated use of label at end of compound statement
(times everywhere tcp.h is included)

Signed-off-by: Andre Tomt <andre@tomt.net>

diff -Naur linux-2.6.11/include/net/tcp.h linux-2.6.11-1.1/include/net/tcp.h
--- linux-2.6.11/include/net/tcp.h	2005-03-02 08:37:48.000000000 +0100
+++ linux-2.6.11-1.1/include/net/tcp.h	2005-03-12 07:00:52.000000000 +0100
@@ -1039,6 +1039,7 @@
 #ifdef TCP_DEBUG
 		printk(tcp_timer_bug_msg);
 #endif
+		return;
 	};
 }
 

--------------040309010906010804090708--
