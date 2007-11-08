From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 02/05] ipv6: RFC4214 Support (2)
Date: Thu, 08 Nov 2007 12:41:39 -0800
Message-ID: <47337483.3080309@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp124.plus.mail.mud.yahoo.com ([209.191.106.155]:26729 "HELO
	smtp124.plus.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1760872AbXKHUlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 15:41:42 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <osprey67@yahoo.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.24-rc2
kernel distribution.

Signed-off-by: Fred L. Templin <osprey67@yahoo.com>

---

--- linux-2.6.24-rc2/include/net/addrconf.h.orig        2007-11-08 12:06:17.000000000 -0800
+++ linux-2.6.24-rc2/include/net/addrconf.h     2007-11-08 08:27:24.000000000 -0800
@@ -241,6 +241,37 @@ static inline int ipv6_addr_is_ll_all_ro
                 addr->s6_addr32[3] == htonl(0x00000002));
  }

+#if defined(CONFIG_IPV6_ISATAP)
+static inline int ipv6_isatap_eui64(u8 *eui, __be32 addr)
+{
+
+       /* RFC3330 Special-Use IPv4 Addresses */
+       eui[0] = (((addr & htonl(0xFF000000)) == htonl(0x00000000)) ||
+                 ((addr & htonl(0xFF000000)) == htonl(0x0A000000)) ||
+                 ((addr & htonl(0xFF000000)) == htonl(0x0D000000)) ||
+                 ((addr & htonl(0xFF000000)) == htonl(0x18000000)) ||
+                 ((addr & htonl(0xFF000000)) == htonl(0x7F000000)) ||
+                 ((addr & htonl(0xFFFF0000)) == htonl(0xA9FE0000)) ||
+                 ((addr & htonl(0xFFF00000)) == htonl(0xAC100000)) ||
+                 ((addr & htonl(0xFFFFFF00)) == htonl(0xC0000200)) ||
+                 ((addr & htonl(0xFFFFFF00)) == htonl(0xC0586300)) ||
+                 ((addr & htonl(0xFFFF0000)) == htonl(0xC0A80000)) ||
+                 ((addr & htonl(0xFFFE0000)) == htonl(0xC6120000)) ||
+                 ((addr & htonl(0xF0000000)) == htonl(0xE0000000)) ||
+                 ((addr & htonl(0xF0000000)) == htonl(0xF0000000))) ?
+                       0x00 : 0x02;
+
+       eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
+       memcpy (eui+4, &addr, 4);
+       return 0;
+}
+
+static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
+{
+       return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
+}
+#endif
+
  #ifdef CONFIG_PROC_FS
  extern int if6_proc_init(void);
  extern void if6_proc_exit(void);
