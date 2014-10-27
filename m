From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipx: move extern sysctl_ipx_pprop_broadcasting to header file
Date: Mon, 27 Oct 2014 20:00:41 +0100
Message-ID: <1414436441-4784-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay009.isp.belgacom.be ([195.238.6.176]:51199 "EHLO
	mailrelay009.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752915AbaJ0TAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 15:00:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include ipx.h from sysctl_net_ipx.c

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 include/net/ipx.h        | 3 +++
 net/ipx/sysctl_net_ipx.c | 4 +---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/ipx.h b/include/net/ipx.h
index 0143180..320f47b 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -42,6 +42,9 @@ struct ipxhdr {
 	struct ipx_address	ipx_source __packed;
 };
 
+/* From af_ipx.c */
+extern int sysctl_ipx_pprop_broadcasting;
+
 static __inline__ struct ipxhdr *ipx_hdr(struct sk_buff *skb)
 {
 	return (struct ipxhdr *)skb_transport_header(skb);
diff --git a/net/ipx/sysctl_net_ipx.c b/net/ipx/sysctl_net_ipx.c
index ad7c03d..0dafcc5 100644
--- a/net/ipx/sysctl_net_ipx.c
+++ b/net/ipx/sysctl_net_ipx.c
@@ -9,14 +9,12 @@
 #include <linux/mm.h>
 #include <linux/sysctl.h>
 #include <net/net_namespace.h>
+#include <net/ipx.h>
 
 #ifndef CONFIG_SYSCTL
 #error This file should not be compiled without CONFIG_SYSCTL defined
 #endif
 
-/* From af_ipx.c */
-extern int sysctl_ipx_pprop_broadcasting;
-
 static struct ctl_table ipx_table[] = {
 	{
 		.procname	= "ipx_pprop_broadcasting",
-- 
1.9.1
