From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] netfilter: Fix build for NETFILTER_XT_TARGET_REDIRECT
Date: Sat,  6 Dec 2014 01:41:59 -0800
Message-ID: <1417858919-10576-1-git-send-email-linux@roeck-us.net>
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix:

ERROR: "nf_nat_redirect_ipv6" [net/netfilter/xt_REDIRECT.ko] undefined!

Seen if NETFILTER_XT_TARGET_REDIRECT is configured but NF_NAT_IPV6
is not, since code compiled with NF_NAT_REDIRECT_IPV6 is used
unconditionally by code enabled with NETFILTER_XT_TARGET_REDIRECT.
This means that NETFILTER_XT_TARGET_REDIRECT depends on NF_NAT_IPV6
and must always select NF_NAT_REDIRECT_IPV6.

Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Seen in and applies to -next. See various qemu test failures
reported at http://server.roeck-us.net:8010/builders,

 net/netfilter/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 57f15a9..2134ef0 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -843,9 +843,9 @@ config NETFILTER_XT_TARGET_RATEEST
 
 config NETFILTER_XT_TARGET_REDIRECT
 	tristate "REDIRECT target support"
-	depends on NF_NAT
+	depends on NF_NAT && NF_NAT_IPV6
 	select NF_NAT_REDIRECT_IPV4 if NF_NAT_IPV4
-	select NF_NAT_REDIRECT_IPV6 if NF_NAT_IPV6
+	select NF_NAT_REDIRECT_IPV6
 	---help---
 	REDIRECT is a special case of NAT: all incoming connections are
 	mapped onto the incoming interface's address, causing the packets to
-- 
1.9.1

