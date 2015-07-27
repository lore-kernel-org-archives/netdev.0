From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [net:master 41/49] drivers/net/ethernet/cadence/macb.c:164:1:
 error: macro "writel" passed 3 arguments, but takes just 2
Date: Mon, 27 Jul 2015 14:07:53 +0300
Message-ID: <1437995273.29746.84.camel@linux.intel.com>
References: <201507271704.JPi1M8WE%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6160 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088AbbG0LKE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 07:10:04 -0400
In-Reply-To: <201507271704.JPi1M8WE%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-27 at 17:03 +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20
> master
> head:   8fff755e9f8d0f70a595e79f248695ce6aef5cc3
> commit: f2ce8a9e48385f444389e75cfe293637c3eb5410 [41/49] net/macb:=20
> improve big endian CPU support
> config: arm-at91_dt_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp
> -tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout f2ce8a9e48385f444389e75cfe293637c3eb5410
>   # save the attached .config to linux build tree
>   make.cross ARCH=3Darm=20

Oh, no.

I do use compiler from Debian for AVR32, didn't check this on other
architectures.

Possible something like following will fix it:

--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -429,12 +429,12 @@
         | GEM_BF(name, value))

 /* Register access macros */
-#define macb_readl(port, reg)          (port)->readl((port),
MACB_##reg)
-#define macb_writel(port, reg, value)  (port)->writel((port),
MACB_##reg, (value))
-#define gem_readl(port, reg)           (port)->readl((port),
GEM_##reg)
-#define gem_writel(port, reg, value)   (port)->writel((port),
GEM_##reg, (value))
-#define queue_readl(queue, reg)                (queue)->bp
->readl((queue)->bp, (queue)->reg)
-#define queue_writel(queue, reg, value)        (queue)->bp
->writel((queue)->bp, (queue)->reg, (value))
+#define macb_readl(port, reg)          port->readl(port, MACB_##reg)
+#define macb_writel(port, reg, value)  port->writel(port, MACB_##reg,
(value))
+#define gem_readl(port, reg)           port->readl(port, GEM_##reg)
+#define gem_writel(port, reg, value)   port->writel(port, GEM_##reg,
(value))
+#define queue_readl(queue, reg)                queue->bp->readl(queue
->bp, queue->reg)
+#define queue_writel(queue, reg, value)        queue->bp->writel(queue
->bp, queue->reg, (value))

 /* Conditional GEM/MACB macros.  These perform the operation to the
correct
  * register dependent on whether the device is a GEM or a MACB.  For
registers



>=20
> All error/warnings (new ones prefixed by >>):
>=20
>    drivers/net/ethernet/cadence/macb.c: In function=20
> 'macb_set_hwaddr':
> > > drivers/net/ethernet/cadence/macb.c:164:1: error: macro "writel"=20
> > > passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA1B, bottom);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
> > > drivers/net/ethernet/cadence/macb.h:435:38: warning: statement=20
> > > with no effect [-Wunused-value]
>     #define gem_writel(port, reg, value) (port)->writel((port),=20
> GEM_##reg, (value))
>                                          ^
> > > drivers/net/ethernet/cadence/macb.h:447:4: note: in expansion of=20
> > > macro 'gem_writel'
>        gem_writel((__bp), __reg, __value); \
>        ^
> > > drivers/net/ethernet/cadence/macb.c:164:2: note: in expansion of=20
> > > macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA1B, bottom);
>      ^
> > > drivers/net/ethernet/cadence/macb.c:164:1: error: macro "writel"=20
> > > passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA1B, bottom);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
>    drivers/net/ethernet/cadence/macb.h:433:39: warning: statement=20
> with no effect [-Wunused-value]
>     #define macb_writel(port, reg, value) (port)->writel((port),=20
> MACB_##reg, (value))
>                                           ^
> > > drivers/net/ethernet/cadence/macb.h:449:4: note: in expansion of=20
> > > macro 'macb_writel'
>        macb_writel((__bp), __reg, __value); \
>        ^
> > > drivers/net/ethernet/cadence/macb.c:164:2: note: in expansion of=20
> > > macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA1B, bottom);
>      ^
>    drivers/net/ethernet/cadence/macb.c:166:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA1T, top);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
> > > drivers/net/ethernet/cadence/macb.h:435:38: warning: statement=20
> > > with no effect [-Wunused-value]
>     #define gem_writel(port, reg, value) (port)->writel((port),=20
> GEM_##reg, (value))
>                                          ^
> > > drivers/net/ethernet/cadence/macb.h:447:4: note: in expansion of=20
> > > macro 'gem_writel'
>        gem_writel((__bp), __reg, __value); \
>        ^
>    drivers/net/ethernet/cadence/macb.c:166:2: note: in expansion of=20
> macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA1T, top);
>      ^
>    drivers/net/ethernet/cadence/macb.c:166:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA1T, top);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
>    drivers/net/ethernet/cadence/macb.h:433:39: warning: statement=20
> with no effect [-Wunused-value]
>     #define macb_writel(port, reg, value) (port)->writel((port),=20
> MACB_##reg, (value))
>                                           ^
> > > drivers/net/ethernet/cadence/macb.h:449:4: note: in expansion of=20
> > > macro 'macb_writel'
>        macb_writel((__bp), __reg, __value); \
>        ^
>    drivers/net/ethernet/cadence/macb.c:166:2: note: in expansion of=20
> macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA1T, top);
>      ^
>    drivers/net/ethernet/cadence/macb.c:169:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA2B, 0);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
> > > drivers/net/ethernet/cadence/macb.h:435:38: warning: statement=20
> > > with no effect [-Wunused-value]
>     #define gem_writel(port, reg, value) (port)->writel((port),=20
> GEM_##reg, (value))
>                                          ^
> > > drivers/net/ethernet/cadence/macb.h:447:4: note: in expansion of=20
> > > macro 'gem_writel'
>        gem_writel((__bp), __reg, __value); \
>        ^
>    drivers/net/ethernet/cadence/macb.c:169:2: note: in expansion of=20
> macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA2B, 0);
>      ^
>    drivers/net/ethernet/cadence/macb.c:169:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA2B, 0);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
>    drivers/net/ethernet/cadence/macb.h:433:39: warning: statement=20
> with no effect [-Wunused-value]
>     #define macb_writel(port, reg, value) (port)->writel((port),=20
> MACB_##reg, (value))
>                                           ^
> > > drivers/net/ethernet/cadence/macb.h:449:4: note: in expansion of=20
> > > macro 'macb_writel'
>        macb_writel((__bp), __reg, __value); \
>        ^
>    drivers/net/ethernet/cadence/macb.c:169:2: note: in expansion of=20
> macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA2B, 0);
>      ^
>    drivers/net/ethernet/cadence/macb.c:170:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA2T, 0);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
> > > drivers/net/ethernet/cadence/macb.h:435:38: warning: statement=20
> > > with no effect [-Wunused-value]
>     #define gem_writel(port, reg, value) (port)->writel((port),=20
> GEM_##reg, (value))
>                                          ^
> > > drivers/net/ethernet/cadence/macb.h:447:4: note: in expansion of=20
> > > macro 'gem_writel'
>        gem_writel((__bp), __reg, __value); \
>        ^
>    drivers/net/ethernet/cadence/macb.c:170:2: note: in expansion of=20
> macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA2T, 0);
>      ^
>    drivers/net/ethernet/cadence/macb.c:170:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA2T, 0);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
>    drivers/net/ethernet/cadence/macb.h:433:39: warning: statement=20
> with no effect [-Wunused-value]
>     #define macb_writel(port, reg, value) (port)->writel((port),=20
> MACB_##reg, (value))
>                                           ^
> > > drivers/net/ethernet/cadence/macb.h:449:4: note: in expansion of=20
> > > macro 'macb_writel'
>        macb_writel((__bp), __reg, __value); \
>        ^
>    drivers/net/ethernet/cadence/macb.c:170:2: note: in expansion of=20
> macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA2T, 0);
>      ^
>    drivers/net/ethernet/cadence/macb.c:171:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA3B, 0);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
> > > drivers/net/ethernet/cadence/macb.h:435:38: warning: statement=20
> > > with no effect [-Wunused-value]
>     #define gem_writel(port, reg, value) (port)->writel((port),=20
> GEM_##reg, (value))
>                                          ^
> > > drivers/net/ethernet/cadence/macb.h:447:4: note: in expansion of=20
> > > macro 'gem_writel'
>        gem_writel((__bp), __reg, __value); \
>        ^
>    drivers/net/ethernet/cadence/macb.c:171:2: note: in expansion of=20
> macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA3B, 0);
>      ^
>    drivers/net/ethernet/cadence/macb.c:171:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA3B, 0);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
>    drivers/net/ethernet/cadence/macb.h:433:39: warning: statement=20
> with no effect [-Wunused-value]
>     #define macb_writel(port, reg, value) (port)->writel((port),=20
> MACB_##reg, (value))
>                                           ^
> > > drivers/net/ethernet/cadence/macb.h:449:4: note: in expansion of=20
> > > macro 'macb_writel'
>        macb_writel((__bp), __reg, __value); \
>        ^
>    drivers/net/ethernet/cadence/macb.c:171:2: note: in expansion of=20
> macro 'macb_or_gem_writel'
>      macb_or_gem_writel(bp, SA3B, 0);
>      ^
>    drivers/net/ethernet/cadence/macb.c:172:1: error: macro "writel"=20
> passed 3 arguments, but takes just 2
>      macb_or_gem_writel(bp, SA3T, 0);
>     ^
>    In file included from drivers/net/ethernet/cadence/macb.c:34:0:
> > > drivers/net/ethernet/cadence/macb.h:435:38: warning: statement=20
> > > with no effect [-Wunused-value]
>     #define gem_writel(port, reg, value) (port)->writel((port),=20
> GEM_##reg, (value))
>                                          ^
>=20
> vim +/writel +164 drivers/net/ethernet/cadence/macb.c
>=20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12   28  #include <linux/phy.h>
> b17471f5d drivers/net/ethernet/cadence/macb.c Olof Johansson        =20
>           2011-12-20   29  #include <linux/of.h>
> fb97a8466 drivers/net/ethernet/cadence/macb.c Jean-Christophe=20
> PLAGNIOL-VILLARD 2011-11-18   30  #include <linux/of_device.h>
> 148cbb53a drivers/net/ethernet/cadence/macb.c Boris BREZILLON       =20
>           2013-08-22   31  #include <linux/of_mdio.h>
> fb97a8466 drivers/net/ethernet/cadence/macb.c Jean-Christophe=20
> PLAGNIOL-VILLARD 2011-11-18   32  #include <linux/of_net.h>
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09   33 =20
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  @34  #include "macb.h"
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09   35 =20
> 1b44791ab drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2013-06-04   36  #define MACB_RX_BUFFER_SIZE	128
> 1b44791ab drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2013-06-04   37  #define RX_BUFFER_MULTIPLE	64  /* bytes=20
> */
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   38  #define RX_RING_SIZE		512 /* must=20
> be power of 2 */
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   39  #define RX_RING_BYTES		(siz
> eof(struct macb_dma_desc) * RX_RING_SIZE)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09   40 =20
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   41  #define TX_RING_SIZE		128 /* must=20
> be power of 2 */
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   42  #define TX_RING_BYTES		(siz
> eof(struct macb_dma_desc) * TX_RING_SIZE)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09   43 =20
> 909a85834 drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-11-19   44  /* level of occupied TX descriptors under=20
> which we wake up TX process */
> 909a85834 drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-11-19   45  #define MACB_TX_WAKEUP_THRESH	(3 *=20
> TX_RING_SIZE / 4)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09   46 =20
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09   47  #define MACB_RX_INT_FLAGS	(MACB_BIT(RC
> OMP) | MACB_BIT(RXUBR)	\
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09   48  				 |=20
> MACB_BIT(ISR_ROVR))
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   49  #define MACB_TX_ERR_FLAGS	(MACB_BIT(IS
> R_TUND)			\
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   50  					|=20
> MACB_BIT(ISR_RLE)		\
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   51  					|=20
> MACB_BIT(TXERR))
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   52  #define MACB_TX_INT_FLAGS	(MACB_TX_ERR
> _FLAGS | MACB_BIT(TCOMP))
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   53 =20
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-07-24   54  #define MACB_MAX_TX_LEN		((un
> signed int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-07-24   55  #define GEM_MAX_TX_LEN		((un
> signed int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
> a4c35ed3f drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-07-24   56 =20
> a5898ea09 drivers/net/ethernet/cadence/macb.c Harini Katakam        =20
>           2015-05-06   57  #define GEM_MTU_MIN_SIZE	68
> a5898ea09 drivers/net/ethernet/cadence/macb.c Harini Katakam        =20
>           2015-05-06   58 =20
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   59  /*
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   60   * Graceful stop timeouts in us. We should=
=20
> allow up to
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   61   * 1 frame time (10 Mbits/s, full-duplex,=20
> ignoring collisions)
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   62   */
> e86cd53af drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2012-10-31   63  #define MACB_HALT_TIMEOUT	1230
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09   64 =20
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   65  /* Ring buffer accessors */
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   66  static unsigned int=20
> macb_tx_ring_wrap(unsigned int index)
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   67  {
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   68  	return index & (TX_RING_SIZE - 1);
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   69  }
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   70 =20
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-12-12   71  static struct macb_dma_desc=20
> *macb_tx_desc(struct macb_queue *queue,
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-12-12   72  					=20
>  unsigned int index)
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   73  {
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-12-12   74  	return &queue
> ->tx_ring[macb_tx_ring_wrap(index)];
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   75  }
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   76 =20
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-12-12   77  static struct macb_tx_skb=20
> *macb_tx_skb(struct macb_queue *queue,
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-12-12   78  				     =20
>  unsigned int index)
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   79  {
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-12-12   80  	return &queue
> ->tx_skb[macb_tx_ring_wrap(index)];
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   81  }
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   82 =20
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-12-12   83  static dma_addr_t macb_tx_dma(struct=20
> macb_queue *queue, unsigned int index)
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   84  {
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   85  	dma_addr_t offset;
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   86 =20
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   87  	offset =3D macb_tx_ring_wrap(index) *=20
> sizeof(struct macb_dma_desc);
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   88 =20
> 02c958dd3 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2014-12-12   89  	return queue->tx_ring_dma + offset;
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   90  }
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   91 =20
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   92  static unsigned int=20
> macb_rx_ring_wrap(unsigned int index)
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   93  {
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   94  	return index & (RX_RING_SIZE - 1);
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   95  }
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   96 =20
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   97  static struct macb_dma_desc=20
> *macb_rx_desc(struct macb *bp, unsigned int index)
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   98  {
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31   99  	return &bp
> ->rx_ring[macb_rx_ring_wrap(index)];
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31  100  }
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31  101 =20
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31  102  static void *macb_rx_buffer(struct macb=20
> *bp, unsigned int index)
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31  103  {
> 1b44791ab drivers/net/ethernet/cadence/macb.c Nicolas Ferre         =20
>           2013-06-04  104  	return bp->rx_buffers + bp
> ->rx_buffer_size * macb_rx_ring_wrap(index);
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31  105  }
> 55054a16a drivers/net/ethernet/cadence/macb.c Havard Skinnemoen     =20
>           2012-10-31  106 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  107  /* I/O accessors */
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  108  static u32 hw_readl_native(struct macb=20
> *bp, int offset)
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  109  {
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  110  	return __raw_readl(bp->regs +=20
> offset);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  111  }
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  112 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  113  static void hw_writel_native(struct macb=20
> *bp, int offset, u32 value)
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  114  {
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  115  	__raw_writel(value, bp->regs +=20
> offset);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  116  }
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  117 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  118  static u32 hw_readl(struct macb *bp, int=20
> offset)
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  119  {
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  120  	return readl_relaxed(bp->regs +=20
> offset);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  121  }
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  122 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  123  static void hw_writel(struct macb *bp, int=
=20
> offset, u32 value)
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  124  {
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  125  	writel_relaxed(value, bp->regs +=20
> offset);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  126  }
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  127 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  128  /*
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  129   * Find the CPU endianness by using the=20
> loopback bit of NCR register. When the
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  130   * CPU is in big endian we need to program=
=20
> swaped mode for management
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  131   * descriptor access.
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  132   */
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  133  static bool hw_is_native_io(void __iomem=20
> *addr)
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  134  {
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  135  	u32 value =3D MACB_BIT(LLB);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  136 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  137  	__raw_writel(value, addr +=20
> MACB_NCR);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  138  	value =3D __raw_readl(addr +=20
> MACB_NCR);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  139 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  140  	/* Write 0 back to disable=20
> everything */
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  141  	__raw_writel(0, addr + MACB_NCR);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  142 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  143  	return value =3D=3D MACB_BIT(LLB);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  144  }
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  145 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  146  static bool hw_is_gem(void __iomem *addr,=20
> bool native_io)
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  147  {
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  148  	u32 id;
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  149 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  150  	if (native_io)
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  151  		id =3D __raw_readl(addr +=20
> MACB_MID);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  152  	else
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  153  		id =3D readl_relaxed(addr +=20
> MACB_MID);
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  154 =20
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  155  	return MACB_BFEXT(IDNUM, id) >=3D 0x2;
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  156  }
> f2ce8a9e4 drivers/net/ethernet/cadence/macb.c Andy Shevchenko       =20
>           2015-07-24  157 =20
> 421d9df06 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2015-03-07  158  static void macb_set_hwaddr(struct macb=20
> *bp)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  159  {
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  160  	u32 bottom;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  161  	u16 top;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  162 =20
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  163  	bottom =3D cpu_to_le32(*((u32 *)bp
> ->dev->dev_addr));
> f75ba50bd drivers/net/ethernet/cadence/macb.c Jamie Iles            =20
>           2011-11-08 @164  	macb_or_gem_writel(bp, SA1B,=20
> bottom);
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  165  	top =3D cpu_to_le16(*((u16 *)(bp->dev
> ->dev_addr + 4)));
> f75ba50bd drivers/net/ethernet/cadence/macb.c Jamie Iles            =20
>           2011-11-08  166  	macb_or_gem_writel(bp, SA1T, top);
> 3629a6ceb drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-11  167 =20
> 3629a6ceb drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-11  168  	/* Clear unused address register=20
> sets */
> 3629a6ceb drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-11  169  	macb_or_gem_writel(bp, SA2B, 0);
> 3629a6ceb drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-11  170  	macb_or_gem_writel(bp, SA2T, 0);
> 3629a6ceb drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-11  171  	macb_or_gem_writel(bp, SA3B, 0);
> 3629a6ceb drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-11  172  	macb_or_gem_writel(bp, SA3T, 0);
> 3629a6ceb drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-11  173  	macb_or_gem_writel(bp, SA4B, 0);
> 3629a6ceb drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-11 @174  	macb_or_gem_writel(bp, SA4T, 0);
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  175  }
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  176 =20
> 421d9df06 drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2015-03-07  177  static void macb_get_hwaddr(struct macb=20
> *bp)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  178  {
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  179  	struct macb_platform_data *pdata;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  180  	u32 bottom;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  181  	u16 top;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  182  	u8 addr[6];
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  183  	int i;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  184 =20
> c607a0d99 drivers/net/ethernet/cadence/macb.c Jingoo Han            =20
>           2013-08-30  185  	pdata =3D dev_get_platdata(&bp->pdev
> ->dev);
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  186 =20
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  187  	/* Check all 4 address register for=20
> vaild address */
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  188  	for (i =3D 0; i < 4; i++) {
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07 @189  		bottom =3D=20
> macb_or_gem_readl(bp, SA1B + i * 8);
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  190  		top =3D macb_or_gem_readl(bp,=20
> SA1T + i * 8);
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  191 =20
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  192  		if (pdata && pdata
> ->rev_eth_addr) {
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  193  			addr[5] =3D bottom &=20
> 0xff;
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  194  			addr[4] =3D (bottom >>=20
> 8) & 0xff;
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  195  			addr[3] =3D (bottom >>=20
> 16) & 0xff;
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  196  			addr[2] =3D (bottom >>=20
> 24) & 0xff;
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  197  			addr[1] =3D top &=20
> 0xff;
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  198  			addr[0] =3D (top &=20
> 0xff00) >> 8;
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  199  		} else {
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  200  			addr[0] =3D bottom &=20
> 0xff;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  201  			addr[1] =3D (bottom >>=20
> 8) & 0xff;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  202  			addr[2] =3D (bottom >>=20
> 16) & 0xff;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  203  			addr[3] =3D (bottom >>=20
> 24) & 0xff;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  204  			addr[4] =3D top &=20
> 0xff;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  205  			addr[5] =3D (top >> 8)=20
> & 0xff;
> d25e78aaf drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  206  		}
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  207 =20
> d1d5741d8 drivers/net/macb.c                  Sven Schnelle         =20
>           2008-06-09  208  		if=20
> (is_valid_ether_addr(addr)) {
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  209  			memcpy(bp->dev
> ->dev_addr, addr, sizeof(addr));
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  210  			return;
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  211  		}
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  212  	}
> 17b8bb3e2 drivers/net/ethernet/cadence/macb.c Joachim Eastwood      =20
>           2012-11-07  213 =20
> c220f8cd0 drivers/net/ethernet/cadence/macb.c Jamie Iles            =20
>           2011-03-08  214  	netdev_info(bp->dev, "invalid hw=20
> address, using random\n");
> f2cedb63d drivers/net/ethernet/cadence/macb.c Danny Kukawka         =20
>           2012-02-15  215  	eth_hw_addr_random(bp->dev);
> d1d5741d8 drivers/net/macb.c                  Sven Schnelle         =20
>           2008-06-09  216  }
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  217 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  218  static int macb_mdio_read(struct mii_bus=20
> *bus, int mii_id, int regnum)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  219  {
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  220  	struct macb *bp =3D bus->priv;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  221  	int value;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  222 =20
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09 @223  	macb_writel(bp, MAN, (MACB_BF(SOF,=20
> MACB_MAN_SOF)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  224  			      | MACB_BF(RW,=20
> MACB_MAN_READ)
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  225  			      |=20
> MACB_BF(PHYA, mii_id)
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  226  			      |=20
> MACB_BF(REGA, regnum)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09 @227  			      |=20
> MACB_BF(CODE, MACB_MAN_CODE)));
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  228 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  229  	/* wait for end of transfer */
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12 @230  	while (!MACB_BFEXT(IDLE,=20
> macb_readl(bp, NSR)))
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  231  		cpu_relax();
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  232 =20
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  233  	value =3D MACB_BFEXT(DATA,=20
> macb_readl(bp, MAN));
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  234 =20
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  235  	return value;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  236  }
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  237 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  238  static int macb_mdio_write(struct mii_bus=20
> *bus, int mii_id, int regnum,
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  239  			   u16 value)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  240  {
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  241  	struct macb *bp =3D bus->priv;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  242 =20
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  243  	macb_writel(bp, MAN, (MACB_BF(SOF,=20
> MACB_MAN_SOF)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  244  			      | MACB_BF(RW,=20
> MACB_MAN_WRITE)
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  245  			      |=20
> MACB_BF(PHYA, mii_id)
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  246  			      |=20
> MACB_BF(REGA, regnum)
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  247  			      |=20
> MACB_BF(CODE, MACB_MAN_CODE)
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  248  			      |=20
> MACB_BF(DATA, value)));
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  249 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  250  	/* wait for end of transfer */
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12 @251  	while (!MACB_BFEXT(IDLE,=20
> macb_readl(bp, NSR)))
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  252  		cpu_relax();
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  253 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  254  	return 0;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  255  }
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  256 =20
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  257  /**
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  258   * macb_set_tx_clk() - Set a clock to a=20
> new frequency
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  259   * @clk		Pointer to the clock=20
> to change
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  260   * @rate	New frequency in Hz
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  261   * @dev		Pointer to the=20
> struct net_device
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  262   */
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  263  static void macb_set_tx_clk(struct clk=20
> *clk, int speed, struct net_device *dev)
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  264  {
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  265  	long ferr, rate, rate_rounded;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  266 =20
> 93b31f48b drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2015-03-07  267  	if (!clk)
> 93b31f48b drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2015-03-07  268  		return;
> 93b31f48b drivers/net/ethernet/cadence/macb.c Cyrille Pitchen       =20
>           2015-03-07  269 =20
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  270  	switch (speed) {
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  271  	case SPEED_10:
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  272  		rate =3D 2500000;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  273  		break;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  274  	case SPEED_100:
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  275  		rate =3D 25000000;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  276  		break;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  277  	case SPEED_1000:
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  278  		rate =3D 125000000;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  279  		break;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  280  	default:
> 9319e47c1 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  281  		return;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  282  	}
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  283 =20
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  284  	rate_rounded =3D clk_round_rate(clk,=20
> rate);
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  285  	if (rate_rounded < 0)
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  286  		return;
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  287 =20
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  288  	/* RGMII allows 50 ppm frequency=20
> error. Test and warn if this limit
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  289  	 * is not satisfied.
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  290  	 */
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  291  	ferr =3D abs(rate_rounded - rate);
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  292  	ferr =3D DIV_ROUND_UP(ferr, rate /=20
> 100000);
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  293  	if (ferr > 5)
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  294  		netdev_warn(dev, "unable to=20
> generate target frequency: %ld Hz\n",
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  295  				rate);
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  296 =20
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  297  	if (clk_set_rate(clk, rate_rounded))
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  298  		netdev_err(dev, "adjusting=20
> tx_clk failed.\n");
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  299  }
> e1824dfe0 drivers/net/ethernet/cadence/macb.c Soren Brinkmann       =20
>           2013-12-10  300 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  301  static void macb_handle_link_change(struct=
=20
> net_device *dev)
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  302  {
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  303  	struct macb *bp =3D netdev_priv(dev);
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  304  	struct phy_device *phydev =3D bp
> ->phy_dev;
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  305  	unsigned long flags;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  306 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  307  	int status_change =3D 0;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  308 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  309  	spin_lock_irqsave(&bp->lock, flags);
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  310 =20
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  311  	if (phydev->link) {
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  312  		if ((bp->speed !=3D phydev
> ->speed) ||
> 6c36a7074 drivers/net/macb.c                  frederic RODO         =20
>           2007-07-12  313  		    (bp->duplex !=3D phydev
> ->duplex)) {
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  314  			u32 reg;
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  315 =20
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09 @316  			reg =3D macb_readl(bp,=20
> NCFGR);
> 89e5785fc drivers/net/macb.c                  Haavard Skinnemoen    =20
>           2006-11-09  317  			reg &=3D=20
> ~(MACB_BIT(SPD) | MACB_BIT(FD));
> 140b7552f drivers/net/ethernet/cadence/macb.c Patrice Vilchez       =20
>           2012-10-31  318  			if (macb_is_gem(bp))
> 140b7552f drivers/net/ethernet/cadence/macb.c Patrice Vilchez       =20
>           2012-10-31  319  				reg &=3D=20
> ~GEM_BIT(GBE);
>=20
> :::::: The code at line 164 was first introduced by commit
> :::::: f75ba50bdc2bcfab591bdf903312557033d0ac68 macb: initial support=
=20
> for Cadence GEM
>=20
> :::::: TO: Jamie Iles <jamie.iles@mathembedded.com>
> :::::: CC: Jamie Iles <jamie@jamieiles.com>
>=20
> ---
> 0-DAY kernel test infrastructure                Open Source=20
> Technology Center
> https://lists.01.org/pipermail/kbuild-all=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0Intel Cor
> poration

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
