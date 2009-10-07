From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: Fix 6RD build error
Date: Wed, 07 Oct 2009 11:01:26 -0400
Message-ID: <4ACCAD46.2020800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:38489 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757626AbZJGPCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 11:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix build error introduced in commit fa857afcf - ipv6 sit: 6rd
(IPv6 Rapid Deployment) Support.  Struct in6_addr is the issue.
I'm only seeing this on x86_64 systems, not on 32-bit with same
IPv6 config options, so it could be there's a missing forward
declaration somewhere, but including the correct header file
fixes the problem too.

  CC [M]  net/ipv6/ip6_tunnel.o
In file included from net/ipv6/ip6_tunnel.c:31:
include/linux/if_tunnel.h:59: error: field =91prefix=92 has incomplete =
type
make[2]: *** [net/ipv6/ip6_tunnel.o] Error 1
make[1]: *** [net/ipv6] Error 2

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index c53c8e0..8d76cb4 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -5,6 +5,7 @@
=20
 #ifdef __KERNEL__
 #include <linux/ip.h>
+#include <linux/in6.h>
 #endif
=20
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
