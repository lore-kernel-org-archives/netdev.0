From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix ipchains/ipfw modules
Date: Fri, 24 Sep 2004 16:44:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3fz57915u.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, coreteam@netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ipchains didn't load anymore because it had a undefined symbol,
which was satisfied by ipconntrack. This caused ipconntrack to be
loaded first by modprobe, but the second ipconntrack init in ipchains
would fail, causing the ipchains load to fail.

ipfw had the same problem.

Declare the missing variable.

Signed-off-by: Andi Kleen <ak@muc.de>

diff -u linux/net/ipv4/netfilter/ip_fw_compat.c-IPC linux/net/ipv4/netfilter/ip_fw_compat.c
--- linux/net/ipv4/netfilter/ip_fw_compat.c-IPC	2004-06-16 14:07:34.000000000 +0200
+++ linux/net/ipv4/netfilter/ip_fw_compat.c	2004-09-24 15:56:55.000000000 +0200
@@ -28,6 +28,8 @@
 
 static struct firewall_ops *fwops;
 
+unsigned int ip_ct_log_invalid;
+
 #ifdef CONFIG_IP_VS
 /* From ip_vs_core.c */
 extern unsigned int
