From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [net-2.6.24] forcedeth does not compile without
	CONFIG_FORCEDETH_NAPI set
Date: Sun, 12 Aug 2007 16:28:53 +0300
Message-ID: <20070812132853.GA3851@sortiz.org>
References: <46BCA18B.80603@hartkopp.net>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.126]:23164 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902AbXHLN3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 09:29:01 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2316.orange.fr (SMTP Server) with ESMTP id 321C8700008C
	for <netdev@vger.kernel.org>; Sun, 12 Aug 2007 15:28:55 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <46BCA18B.80603@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

On Fri, Aug 10, 2007 at 07:34:03PM +0200, Oliver Hartkopp wrote:
> Checking some other source with the current net-2.6.24 GIT, i just
> discovered this:
> 
>   CC      drivers/net/mii.o
>   CC      drivers/net/Space.o
>   CC      drivers/net/loopback.o
>   CC      drivers/net/b44.o
>   CC      drivers/net/forcedeth.o
> drivers/net/forcedeth.c: In function nv_nic_irq:
> drivers/net/forcedeth.c:3017: error: RX_WORK_PER_LOOP undeclared (first
> use in this function)
> drivers/net/forcedeth.c:3017: error: (Each undeclared identifier is
> reported only once
> drivers/net/forcedeth.c:3017: error: for each function it appears in.)
> make[2]: *** [drivers/net/forcedeth.o] Error 1
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
> 
> This only occurs the CONFIG_FORCEDETH_NAPI is _disabled_.
This fixes the build:

--
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

 drivers/net/forcedeth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 37732f9..90eef4a 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2973,6 +2973,8 @@ static void nv_link_irq(struct net_device *dev)
 	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
 }
 
+#define TX_WORK_PER_LOOP  64
+#define RX_WORK_PER_LOOP  64
 static irqreturn_t nv_nic_irq(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -3083,8 +3085,6 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 	return IRQ_RETVAL(i);
 }
 
-#define TX_WORK_PER_LOOP  64
-#define RX_WORK_PER_LOOP  64
 /**
  * All _optimized functions are used to help increase performance
  * (reduce CPU and increase throughput). They use descripter version 3,



