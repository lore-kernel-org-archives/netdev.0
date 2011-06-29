From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Wed, 29 Jun 2011 16:01:33 +1000
Message-ID: <20110629160133.372e53ed.sfr@canb.auug.org.au>
References: <20110623152535.e9ec4ad2.sfr@canb.auug.org.au>
	<20110627153522.8884b125.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110627153522.8884b125.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On Mon, 27 Jun 2011 15:35:22 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> On Thu, 23 Jun 2011 15:25:35 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > After merging the final tree, today's linux-next build (powerpc
> > allyesconfig) failed like this:
> > 
> > drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_read_reg':
> > drivers/net/can/sja1000/sja1000_of_platform.c:61:2: error: implicit declaration of function 'in_8'
> > drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_write_reg':
> > drivers/net/can/sja1000/sja1000_of_platform.c:67:2: error: implicit declaration of function 'out_8'
> > drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_remove':
> > drivers/net/can/sja1000/sja1000_of_platform.c:81:2: error: implicit declaration of function 'iounmap'
> > drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_probe':
> > drivers/net/can/sja1000/sja1000_of_platform.c:113:2: error: implicit declaration of function 'ioremap_nocache'
> > drivers/net/can/sja1000/sja1000_of_platform.c:113:7: warning: assignment makes pointer from integer without a cast
> > 
> > Since this file has not been changed recently, I suspect that this was
> > caused by commit b7f080cfe223 ("net: remove mm.h inclusion from
> > netdevice.h").
> > 
> > I have left the build broken for now since it is also broken for other
> > reasons.
> 
> I am still getting these, is there a fix pending?

I have to wonder why this has taken so long to be fixed ...

I have applied this patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 29 Jun 2011 15:52:00 +1000
Subject: [PATCH] net: include io.h in for iounmap etc

fixes these build errors:

drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_read_reg':
drivers/net/can/sja1000/sja1000_of_platform.c:61:2: error: implicit declaration of function 'in_8'
drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_write_reg':
drivers/net/can/sja1000/sja1000_of_platform.c:67:2: error: implicit declaration of function 'out_8'
drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_remove':
drivers/net/can/sja1000/sja1000_of_platform.c:81:2: error: implicit declaration of function 'iounmap'
drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_probe':
drivers/net/can/sja1000/sja1000_of_platform.c:113:2: error: implicit declaration of function 'ioremap_nocache'
drivers/net/can/sja1000/sja1000_of_platform.c:113:7: warning: assignment makes pointer from integer without a cast

Caused by commit b7f080cfe223 ("net: remove mm.h inclusion from
netdevice.h").

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/can/sja1000/sja1000_of_platform.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 9793df6..cee6ba2 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -38,6 +38,7 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/delay.h>
+#include <linux/io.h>
 #include <linux/can/dev.h>
 
 #include <linux/of_platform.h>
-- 
1.7.5.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
