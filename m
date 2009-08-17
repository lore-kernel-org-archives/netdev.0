From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] phonet: fix build when PROC_FS is disabled
Date: Mon, 17 Aug 2009 13:35:49 -0700
Message-ID: <4A89BF25.9010404@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix phonet build when PROC_FS is not enabled:

net/built-in.o: In function `pn_sock_open':
socket.c:(.text+0x23c649): undefined reference to `seq_open_net'
net/built-in.o:(.rodata+0x21018): undefined reference to `seq_release_net'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/phonet/socket.c |    2 ++
 1 file changed, 2 insertions(+)

--- linux-next-20090817.orig/net/phonet/socket.c
+++ linux-next-20090817/net/phonet/socket.c
@@ -413,6 +413,7 @@ found:
 }
 EXPORT_SYMBOL(pn_sock_get_port);
 
+#ifdef CONFIG_PROC_FS
 static struct sock *pn_sock_get_idx(struct seq_file *seq, loff_t pos)
 {
 	struct net *net = seq_file_net(seq);
@@ -509,3 +510,4 @@ const struct file_operations pn_sock_seq
 	.llseek = seq_lseek,
 	.release = seq_release_net,
 };
+#endif



-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
