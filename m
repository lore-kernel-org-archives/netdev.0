From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/6) tr - mcast_addr need not be on stack
Date: Wed, 20 Aug 2003 17:09:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820170911.7e3e5471.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Multicast address value is put on stack and can just be static const.

Patch against 2.6.0-test3 bk latest.

diff -Nru a/net/802/tr.c b/net/802/tr.c
--- a/net/802/tr.c	Wed Aug 20 15:51:56 2003
+++ b/net/802/tr.c	Wed Aug 20 15:51:56 2003
@@ -235,7 +235,8 @@
 	unsigned int hash;
 	struct rif_cache_s *entry;
 	unsigned char *olddata;
-	unsigned char mcast_func_addr[] = {0xC0,0x00,0x00,0x04,0x00,0x00};
+	static const unsigned char mcast_func_addr[] 
+		= {0xC0,0x00,0x00,0x04,0x00,0x00};
 	
 	spin_lock_bh(&rif_lock);
 
