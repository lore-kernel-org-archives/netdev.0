From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ipv4: ipconfig: avoid unused ic_proto_used symbol
Date: Wed, 27 Jan 2016 14:53:58 +0100
Message-ID: <1453902853-3424272-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:52062 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145AbcA0Ny7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 08:54:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_PROC_FS, CONFIG_IP_PNP_BOOTP, CONFIG_IP_PNP_DHCP and
CONFIG_IP_PNP_RARP are all disabled, we get a warning about the
ic_proto_used variable being unused:

net/ipv4/ipconfig.c:146:12: error: 'ic_proto_used' defined but not used [-Werror=unused-variable]

This avoids the warning, but making the definition conditional on
whether a dynamic IP configuration protocol is configured. If not,
we know that the value is always zero, so we can optimize away the
variable and all code that depends on it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv4/ipconfig.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 67f7c9de0b16..2ed9dd2b5f2f 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -143,7 +143,11 @@ static char dhcp_client_identifier[253] __initdata;
 
 /* Persistent data: */
 
+#ifdef IPCONFIG_DYNAMIC
 static int ic_proto_used;			/* Protocol used, if any */
+#else
+#define ic_proto_used 0
+#endif
 static __be32 ic_nameservers[CONF_NAMESERVERS_MAX]; /* DNS Server IP addresses */
 static u8 ic_domain[64];		/* DNS (not NIS) domain name */
 
-- 
2.7.0
