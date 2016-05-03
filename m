From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] gre6: add Kconfig dependency for NET_IPGRE_DEMUX
Date: Tue,  3 May 2016 17:19:57 +0200
Message-ID: <1462288817-721172-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <tom@herbertland.com>,
	Thomas Egerer <hakke_007@gmx.de>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ipv6 gre implementation was cleaned up to share more code
with the ipv4 version, but it can be enabled even when NET_IPGRE_DEMUX
is disabled, resulting in a link error:

net/built-in.o: In function `gre_rcv':
:(.text+0x17f5d0): undefined reference to `gre_parse_header'
ERROR: "gre_parse_header" [net/ipv6/ip6_gre.ko] undefined!

This adds a Kconfig dependency to prevent that now invalid
configuration.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 308edfdf1563 ("gre6: Cleanup GREv6 receive path, call common GRE functions")
---
 net/ipv6/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 11e875ffd7ac..3f8411328de5 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -218,6 +218,7 @@ config IPV6_GRE
 	tristate "IPv6: GRE tunnel"
 	select IPV6_TUNNEL
 	select NET_IP_TUNNEL
+	depends on NET_IPGRE_DEMUX
 	---help---
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
-- 
2.7.0
