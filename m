From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH] ipv6: Fix Makefile offload objects
Date: Sun, 16 Dec 2012 16:47:50 +0000
Message-ID: <50CDFB36.1020604@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following commit breaks IPv6 TCP transmission for me:
	Commit 75fe83c32248d99e6d5fe64155e519b78bb90481
	Author: Vlad Yasevich <vyasevic@redhat.com>
	Date:   Fri Nov 16 09:41:21 2012 +0000
	ipv6: Preserve ipv6 functionality needed by NET

This patch fixes the typo "ipv6_offload" which should be
"ipv6-offload".

I don't know why not including the offload modules should
break TCP. Disabling all offload options on the NIC didn't
help. Outgoing pulseaudio traffic kept stalling.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 net/ipv6/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2068ac4..4ea2448 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -41,6 +41,6 @@ obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 
 obj-y += addrconf_core.o exthdrs_core.o
-obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6_offload)
+obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
-- 
1.7.8.rc3

-- 
Simon Arlott
