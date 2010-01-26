From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/ariadne.c:165: error: 'set_multicast_list'
 undeclared here (not in a function)
Date: Tue, 26 Jan 2010 05:18:17 -0800 (PST)
Message-ID: <20100126.051817.215651254.davem@davemloft.net>
References: <10f740e81001260057h37f3494dvefa3a37b2e1453a5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <10f740e81001260057h37f3494dvefa3a37b2e1453a5@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 26 Jan 2010 09:57:05 +0100

> http://kisskb.ellerman.id.au/kisskb/buildresult/2076964/
> 
> drivers/net/ariadne.c:165: error: 'set_multicast_list' undeclared here
> (not in a function)
> 
> Seems to be broken by:

I'll fix this with the patch below.

Alexey, please go through at least drivers/net and look at the
other stale references to these HAVE_* macros.

For example I still see a bunch of HAVE_POLL_CONTROLLER stuff.

Thanks.

ariadne: Fix build.

References removed HAVE_MULTICAST.

Reporeted-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ariadne.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index c35af3e..e2c2024 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -123,9 +123,7 @@ static void ariadne_reset(struct net_device *dev);
 static irqreturn_t ariadne_interrupt(int irq, void *data);
 static int ariadne_close(struct net_device *dev);
 static struct net_device_stats *ariadne_get_stats(struct net_device *dev);
-#ifdef HAVE_MULTICAST
 static void set_multicast_list(struct net_device *dev);
-#endif
 
 
 static void memcpyw(volatile u_short *dest, u_short *src, int len)
-- 
1.6.6.1
