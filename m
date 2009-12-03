From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v8 0/7] TCPCT part 1: cookie option
 exchange
Date: Wed, 02 Dec 2009 22:19:47 -0800 (PST)
Message-ID: <20091202.221947.155143844.davem@davemloft.net>
References: <4B1738C7.7090101@gmail.com>
	<20091202.221349.38327679.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbZLCGTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:19:41 -0500
In-Reply-To: <20091202.221349.38327679.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 02 Dec 2009 22:13:49 -0800 (PST)

> I had to apply the following fix on top to cure a warning on 64-bit.

I also had to apply another patch to fix build failures:

tcp: sysctl_tcp_cookie_size needs to be exported to modules.

Otherwise:

ERROR: "sysctl_tcp_cookie_size" [net/ipv6/ipv6.ko] undefined!
make[1]: *** [__modpost] Error 1

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_output.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c08e06d..93316a9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -60,6 +60,7 @@ int sysctl_tcp_base_mss __read_mostly = 512;
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
+EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
 
 /* Account for new data that has been sent to the network. */
-- 
1.6.5

