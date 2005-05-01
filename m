From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/2] [XFRM] Prevent off-by-one access to xfrm_dispatch
Date: Sun, 1 May 2005 20:47:31 +0200
Message-ID: <20050501184731.GJ577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Makes the type > XFRM_MSG_MAX check behave correctly to
protect access to xfrm_dispatch.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.12-rc3.orig/include/linux/xfrm.h	2005-04-30 20:22:19.000000000 +0200
+++ linux-2.6.12-rc3/include/linux/xfrm.h	2005-05-01 11:53:30.000000000 +0200
@@ -140,8 +140,9 @@
 	XFRM_MSG_FLUSHPOLICY,
 #define XFRM_MSG_FLUSHPOLICY XFRM_MSG_FLUSHPOLICY
 
-	XFRM_MSG_MAX
+	__XFRM_MSG_MAX
 };
+#define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
 
 struct xfrm_user_tmpl {
 	struct xfrm_id		id;
