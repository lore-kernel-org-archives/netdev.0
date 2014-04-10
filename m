From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: [PATCH iproute2] ip: officially support flag mngtmpaddr also for
 "ip addr del"
Date: Thu, 10 Apr 2014 21:16:45 +0200
Message-ID: <5346EE1D.2070305@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:51067 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964944AbaDJTRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 15:17:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel is being extended to support flag IFA_F_MANAGETEMPADDR also for
deletion of addresses. This will allow a userspace application to indicate
that for a global address the kernel should delete all related temporary
addresses as well.

"ip addr del" internally calls ipaddr_modify which silently accepts
any flag provided on the command line already, independent of the
actual command.
Therefore only the usage documentation needs to be extended.

Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 14d1720..5a31a7c 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -69,7 +69,7 @@ static void usage(void)
 	}
 	fprintf(stderr, "Usage: ip addr {add|change|replace} IFADDR dev STRING [ LIFETIME ]\n");
 	fprintf(stderr, "                                                      [ CONFFLAG-LIST ]\n");
-	fprintf(stderr, "       ip addr del IFADDR dev STRING\n");
+	fprintf(stderr, "       ip addr del IFADDR dev STRING [mngtmpaddr]\n");
 	fprintf(stderr, "       ip addr {show|save|flush} [ dev STRING ] [ scope SCOPE-ID ]\n");
 	fprintf(stderr, "                            [ to PREFIX ] [ FLAG-LIST ] [ label PATTERN ] [up]\n");
 	fprintf(stderr, "       ip addr {showdump|restore}\n");
-- 
1.9.1.315.g3f09db0.dirty
