From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] sctp: fix missing label when PROC_FS=n
Date: Thu, 27 Nov 2008 12:18:24 -0800
Message-ID: <20081127121824.5b3515c9.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net
To: linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix missing label when CONFIG_PROC_FS=n:

net/sctp/protocol.c: In function 'sctp_proc_init':
net/sctp/protocol.c:106: error: label 'out_nomem' used but not defined
make[3]: *** [net/sctp/protocol.o] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/sctp/protocol.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-next-20081127.orig/net/sctp/protocol.c
+++ linux-next-20081127/net/sctp/protocol.c
@@ -139,11 +139,12 @@ out_snmp_proc_init:
 	}
 out_free_percpu:
 	percpu_counter_destroy(&sctp_sockets_allocated);
-out_nomem:
-	return -ENOMEM;
 #else
 	return 0;
 #endif /* CONFIG_PROC_FS */
+
+out_nomem:
+	return -ENOMEM;
 }
 
 /* Clean up the proc fs entry for the SCTP protocol.
