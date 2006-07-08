From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv4/netfilter/: fix SYSCTL=n compile
Date: Sat, 8 Jul 2006 22:20:23 +0200
Message-ID: <20060708202023.GE5020@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:57095 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1030323AbWGHUUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 16:20:22 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following compile error with CONFIG_SYSCTL=n 
introduced by commit 39a27a35c5c1b5be499a0576a35c45a011788bf8:

<--  snip  -->

...
  LD      .tmp_vmlinux1
net/built-in.o: In function `tcp_error':
ip_conntrack_proto_tcp.c:(.text+0x77af6): undefined reference to `ip_conntrack_checksum'
net/built-in.o: In function `udp_error':
ip_conntrack_proto_udp.c:(.text+0x78456): undefined reference to `ip_conntrack_checksum'
net/built-in.o: In function `icmp_error':
ip_conntrack_proto_icmp.c:(.text+0x7868f): undefined reference to `ip_conntrack_checksum'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/ipv4/netfilter/ip_conntrack_standalone.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.17-mm6-full/net/ipv4/netfilter/ip_conntrack_standalone.c.old	2006-07-08 15:32:32.000000000 +0200
+++ linux-2.6.17-mm6-full/net/ipv4/netfilter/ip_conntrack_standalone.c	2006-07-08 15:33:30.000000000 +0200
@@ -534,6 +534,8 @@
 
 /* Sysctl support */
 
+int ip_conntrack_checksum = 1;
+
 #ifdef CONFIG_SYSCTL
 
 /* From ip_conntrack_core.c */
@@ -568,8 +570,6 @@
 static int log_invalid_proto_min = 0;
 static int log_invalid_proto_max = 255;
 
-int ip_conntrack_checksum = 1;
-
 static struct ctl_table_header *ip_ct_sysctl_header;
 
 static ctl_table ip_ct_sysctl_table[] = {

