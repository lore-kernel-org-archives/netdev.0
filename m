From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] ne: eliminate unused var. warning
Date: Mon, 23 Feb 2004 13:39:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223133926.4301ef22.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.3-current.

--
~Randy


From: Stephen Hemminger <shemminger@osdl.org>



On Mon, 16 Feb 2004 15:36:21 -0800
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> On Mon, 9 Feb 2004 15:02:17 -0800 Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> | Get rid of unused variable warning.
> | 
> | diff -Nru a/drivers/net/ne.c b/drivers/net/ne.c
> | --- a/drivers/net/ne.c	Mon Feb  9 14:23:27 2004
> | +++ b/drivers/net/ne.c	Mon Feb  9 14:23:27 2004
> | @@ -165,7 +165,6 @@
> |  static int __init do_ne_probe(struct net_device *dev)
> |  {
> |  	unsigned int base_addr = dev->base_addr;
> | -	int irq = dev->irq;
> |  
> |  	SET_MODULE_OWNER(dev);
> |  
> 
> <irq> is used 18 lines later #ifndef MODULE.

diff -Nru a/drivers/net/ne.c b/drivers/net/ne.c


 linux-263-kj1-rddunlap/drivers/net/ne.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/ne.c~net_ne_unused2 drivers/net/ne.c
--- linux-263-kj1/drivers/net/ne.c~net_ne_unused2	2004-02-18 14:45:33.000000000 -0800
+++ linux-263-kj1-rddunlap/drivers/net/ne.c	2004-02-18 14:45:33.000000000 -0800
@@ -165,7 +165,9 @@ static void ne_block_output(struct net_d
 static int __init do_ne_probe(struct net_device *dev)
 {
 	unsigned int base_addr = dev->base_addr;
-	int irq = dev->irq;
+#ifndef MODULE
+	int orig_irq = dev->irq;
+#endif
 
 	SET_MODULE_OWNER(dev);
 
@@ -183,7 +185,7 @@ static int __init do_ne_probe(struct net
 	/* Last resort. The semi-risky ISA auto-probe. */
 	for (base_addr = 0; netcard_portlist[base_addr] != 0; base_addr++) {
 		int ioaddr = netcard_portlist[base_addr];
-		dev->irq = irq;
+		dev->irq = orig_irq;
 		if (ne_probe1(dev, ioaddr) == 0)
 			return 0;
 	}

_
