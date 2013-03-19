From: Martin Fuzzey <mfuzzey@parkeon.com>
Subject: [PATCH] NET: ipconfig: Fix newline handling in log message.
Date: Tue, 19 Mar 2013 19:19:29 +0100
Message-ID: <20130319181929.10606.24517.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta1.parkeon.com ([91.121.43.66]:58131 "EHLO mta1.parkeon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755387Ab3CSTBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 15:01:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using ipconfig the logs currently look like:

Single name server:
[    3.467270] IP-Config: Complete:
[    3.470613]      device=eth0, hwaddr=ac:de:48:00:00:01, ipaddr=172.16.42.2, mask=255.255.255.0, gw=172.16.42.1
[    3.480670]      host=infigo-1, domain=, nis-domain=(none)
[    3.486166]      bootserver=172.16.42.1, rootserver=172.16.42.1, rootpath=
[    3.492910]      nameserver0=172.16.42.1[    3.496853] ALSA device list:

Three name servers:
[    3.496949] IP-Config: Complete:
[    3.500293]      device=eth0, hwaddr=ac:de:48:00:00:01, ipaddr=172.16.42.2, mask=255.255.255.0, gw=172.16.42.1
[    3.510367]      host=infigo-1, domain=, nis-domain=(none)
[    3.515864]      bootserver=172.16.42.1, rootserver=172.16.42.1, rootpath=
[    3.522635]      nameserver0=172.16.42.1, nameserver1=172.16.42.100
[    3.529149] , nameserver2=172.16.42.200

Fix newline handling for these cases

Signed-off-by: Martin Fuzzey <mfuzzey@parkeon.com>
---
 net/ipv4/ipconfig.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 98cbc68..bf6c5cf 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1522,7 +1522,8 @@ static int __init ip_auto_config(void)
 		}
 	for (i++; i < CONF_NAMESERVERS_MAX; i++)
 		if (ic_nameservers[i] != NONE)
-			pr_cont(", nameserver%u=%pI4\n", i, &ic_nameservers[i]);
+			pr_cont(", nameserver%u=%pI4", i, &ic_nameservers[i]);
+	pr_cont("\n");
 #endif /* !SILENT */
 
 	return 0;
