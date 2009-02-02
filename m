From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Mon, 02 Feb 2009 13:24:50 -0800 (PST)
Message-ID: <20090202.132450.21504465.davem@davemloft.net>
References: <4986CC6D.4090904@walrond.org>
	<20090202.120507.152093960.davem@davemloft.net>
	<498761E7.3080006@walrond.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, sam@ravnborg.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: andrew@walrond.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39397
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753502AbZBBVYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:24:53 -0500
In-Reply-To: <498761E7.3080006@walrond.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Walrond <andrew@walrond.org>
Date: Mon, 02 Feb 2009 21:13:11 +0000

> What exactly is the purpose of the kernel headers? Are there some
> definitions in the kernel headers that will never be available from
> glibc? Is it perhaps possible to work towards exporting kernel
> headers for the sole purpose of building glibc, and all other
> packages should be able to build against glibc's headers?

To a certain extent they are supposed to be able to
co-exist.

We weren't careful in the past in some cases, to the point
where the conflicts often very difficult to resolve.  That's
the kind of situation we have here.

I guess I'll put in the following hack for now:

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index aeab2cb..82c4362 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -2,7 +2,10 @@
 #define _IF_TUNNEL_H_
 
 #include <linux/types.h>
+
+#ifdef __KERNEL__
 #include <linux/ip.h>
+#endif
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)

