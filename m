From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] missing owner field entry on pppoe /proc
Date: Thu, 19 Jun 2003 12:20:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619122024.3d21c0ec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Michal Ostrowski
 <mostrows@styx.uwaterloo.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The /proc file operations for PPPOE is missing an owner entry.   This means that
if someone has /proc file open, it is still possible to unload the module.

Patch against 2.5.72 

diff -Nru a/drivers/net/pppoe.c b/drivers/net/pppoe.c
--- a/drivers/net/pppoe.c	Thu Jun 19 12:17:27 2003
+++ b/drivers/net/pppoe.c	Thu Jun 19 12:17:28 2003
@@ -1061,6 +1061,7 @@
 }
 
 static struct file_operations pppoe_seq_fops = {
+	.owner		= THIS_MODULE,
 	.open		= pppoe_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
