From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/13) set owner of /proc/net/atalk directory
Date: Fri, 29 Aug 2003 14:06:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829140651.4ec38b3e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Set owner to prevent problems when directory is open during
module unload.

diff -Nru a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
--- a/net/appletalk/atalk_proc.c	Fri Aug 29 13:32:04 2003
+++ b/net/appletalk/atalk_proc.c	Fri Aug 29 13:32:04 2003
@@ -275,6 +275,7 @@
 	atalk_proc_dir = proc_mkdir("atalk", proc_net);
 	if (!atalk_proc_dir)
 		goto out;
+	atalk_proc_dir->owner = THIS_MODULE;
 
 	p = create_proc_entry("interface", S_IRUGO, atalk_proc_dir);
 	if (!p)
