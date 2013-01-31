From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx eth broken in 3.7.0/3.8-rc5?
Date: Thu, 31 Jan 2013 22:54:54 +0100
Message-ID: <m3622duifl.fsf@intrepid.localdomain>
References: <20744.9777.937924.822371@pilspetsen.it.uu.se>
 <20744.25884.660535.514911@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Imre Kaloz <kaloz@openwrt.org>,
 Xi Wang <xi.wang@gmail.com>, linux-arm-kernel@lists.infradead.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20744.25884.660535.514911@pilspetsen.it.uu.se> (Mikael
 Pettersson's message of "Wed, 30 Jan 2013 01:11:08 +0100")
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

Mikael Pettersson <mikpe@it.uu.se> writes:

>  > When I try to update my ixp4xx machine to a 3.8-rc5 kernel it boots
>  > Ok but the network (CONFIG_IXP4XX_ETH=y) fails to come up, with the
>  > following in the kernel log:
>  >
>  > net eth0: coherent DMA mask is unset
>
> A git bisect identified the following as the culprit:
>
>  > From 1a4901177574083c35fafc24c4d151c2a7c7647c Mon Sep 17 00:00:00 2001
>  > From: Xi Wang <xi.wang@gmail.com>
>  > Date: Sat, 17 Nov 2012 20:25:09 +0000
>  > Subject: [PATCH] ixp4xx_eth: avoid calling dma_pool_create() with NULL dev
>  >
>  > Use &port->netdev->dev instead of NULL since dma_pool_create() doesn't
>  > allow NULL dev.

IIRC NULL dev in dma_pool_create() meant the usual IXP4xx mask (64MB)
was used. Perhaps devices don't get a mask by default anymore. I will
look at this in few days.
-- 
Krzysztof Halasa
