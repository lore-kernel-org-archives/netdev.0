From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Tue, 28 Sep 2010 22:38:50 -0700 (PDT)
Message-ID: <20100928.223850.104051485.davem@davemloft.net>
References: <1285734295.22570.25.camel@edumazet-laptop>
	<20100929043642.GA3660@gondor.apana.org.au>
	<20100928.214132.226782961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751358Ab0I2Fi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 01:38:29 -0400
In-Reply-To: <20100928.214132.226782961.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 28 Sep 2010 21:41:32 -0700 (PDT)

> Eric, please cook up a patch which does this, I think the
> magic Kconfig dependency formula for this is:
> 
> 	depends on IPV6 || IPV6=n
> 
> Thanks!

Nevermind, I took care of it :-)

--------------------
ip_gre: Fix dependencies wrt. ipv6.

The GRE tunnel driver needs to invoke icmpv6 helpers in the
ipv6 stack when ipv6 support is enabled.

Therefore if IPV6 is enabled, we have to enforce that GRE's
enabling (modular or static) matches that of ipv6.

Reported-by: Patrick McHardy <kaber@trash.net>
Reported-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 571f895..72380a3 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -217,6 +217,7 @@ config NET_IPIP
 
 config NET_IPGRE
 	tristate "IP: GRE tunnels over IP"
+	depends on IPV6 || IPV6=n
 	help
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
-- 
1.7.3

