From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v7 3/7 RFC] TCPCT part 1c:
 sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
Date: Sat, 21 Nov 2009 11:22:49 -0800 (PST)
Message-ID: <20091121.112249.67550818.davem@davemloft.net>
References: <20091120.092408.208010931.davem@davemloft.net>
	<4B081A81.5000602@gmail.com>
	<20091121.111844.54272535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60794
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753373AbZKUTWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 14:22:32 -0500
In-Reply-To: <20091121.111844.54272535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 21 Nov 2009 11:18:44 -0800 (PST)

> From: William Allen Simpson <william.allen.simpson@gmail.com>
> Date: Sat, 21 Nov 2009 11:51:13 -0500
> 
>> This code was based on net/ipv4/tcp_minisocks.c for syncookies.
>> Apparently, default for syncookies has been controversial.
> 
> I'll have to change that, it doesn't make any sense.  Thanks
> for pointing it out.

Ok, here's what I'll push out to net-next-2.6, thanks again.

tcp: Don't make syn cookies initial setting depend on CONFIG_SYSCTL

That's extremely non-intuitive, noticed by William Allen Simpson.

And let's make the default be on, it's been suggested by a lot of
people so we'll give it a try.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_minisocks.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 4be2228..ab32c18 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -26,13 +26,7 @@
 #include <net/inet_common.h>
 #include <net/xfrm.h>
 
-#ifdef CONFIG_SYSCTL
-#define SYNC_INIT 0 /* let the user enable it */
-#else
-#define SYNC_INIT 1
-#endif
-
-int sysctl_tcp_syncookies __read_mostly = SYNC_INIT;
+int sysctl_tcp_syncookies __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_syncookies);
 
 int sysctl_tcp_abort_on_overflow __read_mostly;
-- 
1.6.5.3

