From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: ixp4xx eth broken in 3.7.0/3.8-rc5?
Date: Wed, 30 Jan 2013 01:11:08 +0100
Message-ID: <20744.25884.660535.514911@pilspetsen.it.uu.se>
References: <20744.9777.937924.822371@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Imre Kaloz <kaloz@openwrt.org>,
 Xi Wang <xi.wang@gmail.com>, linux-arm-kernel@lists.infradead.org,
 Krzysztof Halasa <khc@pm.waw.pl>
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20744.9777.937924.822371@pilspetsen.it.uu.se>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Mikael Pettersson writes:
 > When I try to update my ixp4xx machine to a 3.8-rc5 kernel it boots
 > Ok but the network (CONFIG_IXP4XX_ETH=y) fails to come up, with the
 > following in the kernel log:
 > 
 > net eth0: coherent DMA mask is unset
 > 
 > With a 3.7.0 kernel the situation is similar, except that the "net
 > eth0: coherent DMA mask is unset" message repeats itself endlessly
 > and I can't even get in on the serial console.
 > 
 > With the 3.6.0 kernel everything works perfectly.

A git bisect identified the following as the culprit:

 > From 1a4901177574083c35fafc24c4d151c2a7c7647c Mon Sep 17 00:00:00 2001
 > From: Xi Wang <xi.wang@gmail.com>
 > Date: Sat, 17 Nov 2012 20:25:09 +0000
 > Subject: [PATCH] ixp4xx_eth: avoid calling dma_pool_create() with NULL dev
 > 
 > Use &port->netdev->dev instead of NULL since dma_pool_create() doesn't
 > allow NULL dev.
 > 
 > Signed-off-by: Xi Wang <xi.wang@gmail.com>
 > Cc: Andrew Morton <akpm@linux-foundation.org>
 > Signed-off-by: David S. Miller <davem@davemloft.net>
 > ---
 >  drivers/net/ethernet/xscale/ixp4xx_eth.c |    8 +++++---
 >  1 files changed, 5 insertions(+), 3 deletions(-)

Reverting this unbreaks ixp4xx_eth on my ixp4xx machine with kernels
3.7.0 and 3.8-rc5.

(Added cc: author and netdev.)

/Mikael
