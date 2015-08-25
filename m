From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC 1/5] net: add IFF_L2_ONLY flag
Date: Tue, 25 Aug 2015 15:50:11 -0700
Message-ID: <1440543015-14693-2-git-send-email-f.fainelli@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36119 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049AbbHYWxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:53:49 -0400
Received: by pacgr6 with SMTP id gr6so4824365pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:53:48 -0700 (PDT)
In-Reply-To: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow network device drivers to flag specific network devices as being
L2 only, that is, no IPv4/v6 configuration will be allowed on these
interfaces, yet they are still usable as configuration endpoints for
ethtool interfaces.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/uapi/linux/if.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 9cf2394f0bcf..2de818930edf 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -87,6 +87,7 @@ enum net_device_flags {
 	IFF_LOWER_UP			= 1<<16, /* volatile */
 	IFF_DORMANT			= 1<<17, /* volatile */
 	IFF_ECHO			= 1<<18, /* volatile */
+	IFF_L2_ONLY			= 1<<19, /* volatile */
 };
 
 #define IFF_UP				IFF_UP
@@ -108,9 +109,11 @@ enum net_device_flags {
 #define IFF_LOWER_UP			IFF_LOWER_UP
 #define IFF_DORMANT			IFF_DORMANT
 #define IFF_ECHO			IFF_ECHO
+#define IFF_L2_ONLY			IFF_L2_ONLY
 
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|IFF_ECHO|\
-		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
+		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT|\
+		IFF_L2_ONLY)
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
-- 
2.1.0
