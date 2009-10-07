From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH][RESEND 3] IPv6: 6rd tunnel mode
Date: Wed, 7 Oct 2009 16:18:32 +0200
Message-ID: <20091007141832.GE15653@secunet.com>
References: <20090922220251.GA22874@lnxos.staff.proxad.net> <20090923184314.a2a2701d.yoshfuji@linux-ipv6.org> <20091007.012436.74941374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, acassen@freebox.fr, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:41489 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394AbZJGOxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 10:53:07 -0400
Content-Disposition: inline
In-Reply-To: <20091007.012436.74941374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 07, 2009 at 01:24:36AM -0700, David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Wed, 23 Sep 2009 18:43:14 +0900
> 
> > Subject: [PATCH] ipv6 sit: 6rd (IPv6 Rapid Deployment) Support.
> > 

I'm getting the following compile error after applying this patch:

  CC      net/ipv6/ip6_tunnel.o
 In file included from
/home/klassert/git/linux-sinafe-2.6/net/ipv6/ip6_tunnel.c:30:
 /home/klassert/git/linux-sinafe-2.6/include/linux/if_tunnel.h:59:
error: field 'prefix' has incomplete type
 make[3]: *** [net/ipv6/ip6_tunnel.o] Error 1

We probaply missing include/linux/in6.h in include/linux/if_tunnel.h
The patch below adds the missing include.

---  

Subject: [PATCH] if_tunnel.h: Add missing include

This patch fixes the following compile error:

  CC      net/ipv6/ip6_tunnel.o
 In file included from /home/klassert/git/linux-sinafe-2.6/net/ipv6/ip6_tunnel.c:30:
 /home/klassert/git/linux-sinafe-2.6/include/linux/if_tunnel.h:59: error: field 'prefix' has incomplete type
 make[3]: *** [net/ipv6/ip6_tunnel.o] Error 1

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/if_tunnel.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index c53c8e0..8d76cb4 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -5,6 +5,7 @@
 
 #ifdef __KERNEL__
 #include <linux/ip.h>
+#include <linux/in6.h>
 #endif
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
-- 
1.5.4.2

