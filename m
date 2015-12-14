From: Alexander Aring <alex.aring@gmail.com>
Subject: [RFC radvd 1/2] device-linux: replace ARPHRD_IEEE802154 to ARPHRD_6LOWPAN
Date: Mon, 14 Dec 2015 15:07:35 +0100
Message-ID: <1450102056-23107-2-git-send-email-alex.aring@gmail.com>
References: <1450102056-23107-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de, Alexander Aring <alex.aring@gmail.com>,
	Oleg Hahm <oliver.hahm@inria.fr>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34638 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbbLNOIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 09:08:31 -0500
In-Reply-To: <1450102056-23107-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the ARPHRD_IEEE802154 to ARPHRD_6LOWPAN. The IEEE
802.15.4 6lowpan module changed the ARPHRD_IEEE802154 type to
ARPHRD_6LOWPAN. Nowadays it's use ARPHRD_6LOWPAN which is also used by
BTLE 6LoWPAN. Both interfaces uses an EUI64 address and the handling to
get the link-layer address should be the same.

There is no backward compatibility for 802.15.4 6LoWPAN before we
changed the ARPHRD. Anyway if somebody wants that it should be patched
manually. When the ARPHRD was ARPHRD_IEEE802154 the 802.15.4 6lowpan was
anyway in a somehow unusable state.

Cc: linux-bluetooth@vger.kernel.org
Cc: linux-wpan@vger.kernel.org
Cc: Oleg Hahm <oliver.hahm@inria.fr>
Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 device-linux.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/device-linux.c b/device-linux.c
index de83f2e..7301927 100644
--- a/device-linux.c
+++ b/device-linux.c
@@ -22,6 +22,10 @@
 #define IPV6_ADDR_LINKLOCAL   0x0020U
 #endif
 
+#ifndef ARPHRD_6LOWPAN
+#define ARPHRD_6LOWPAN	825	/* IPv6 over LoWPAN */
+#endif
+
 static char const *hwstr(unsigned short sa_family);
 
 /*
@@ -79,12 +83,10 @@ int update_device_info(int sock, struct Interface *iface)
 		iface->sllao.if_maxmtu = -1;
 		break;
 #endif				/* ARPHDR_ARCNET */
-#ifdef ARPHRD_IEEE802154
-	case ARPHRD_IEEE802154:
+	case ARPHRD_6LOWPAN:
 		iface->sllao.if_hwaddr_len = 64;
 		iface->sllao.if_prefix_len = 64;
 		break;
-#endif
 	default:
 		iface->sllao.if_hwaddr_len = -1;
 		iface->sllao.if_prefix_len = -1;
@@ -382,6 +384,9 @@ static char const *hwstr(unsigned short sa_family)
 		rc = "ARPHRD_IEEE802154_PHY";
 		break;
 #endif
+	case ARPHRD_6LOWPAN:
+		rc = "ARPHRD_6LOWPAN";
+		break;
 	case ARPHRD_VOID:
 		rc = "ARPHRD_VOID";
 		break;
-- 
2.6.1
