From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6 NET] Catch wrong RTATTR_MAX with BUG()
Date: Thu, 9 Sep 2004 18:43:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909164346.GA18994@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Catches outdated/invalid RTATTR_MAX and therefore avoids possible stack
corruption.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc1-bk15.orig/net/core/rtnetlink.c	2004-09-08 18:33:42.000000000 +0200
+++ linux-2.6.9-rc1-bk15/net/core/rtnetlink.c	2004-09-09 18:18:22.000000000 +0200
@@ -450,6 +450,9 @@
 	sz_idx = type>>2;
 	kind = type&3;
 
+	if (RTATTR_MAX < rta_max[sz_idx])
+		BUG();
+
 	if (kind != 2 && security_netlink_recv(skb)) {
 		*errp = -EPERM;
 		return -1;
