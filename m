From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Tue, 24 May 2016 21:02:35 +0200
Message-ID: <20160524190235.GA31006@electric-eye.fr.zoreil.com>
References: <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm> <5740E82F.8040903@gmx.de>
 <20160522091742.GA8681@debian-dorm> <57419853.9050701@gmx.de>
 <20160522223659.GB5086@electric-eye.fr.zoreil.com>
 <5743A9DD.8010202@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, al.kochet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5743A9DD.8010202-Mmb7MZpHnFY@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org> :
[...]
> I dont agree here. A dma_wmb would have an effect to "data" and "info", yes,
> but it would have absolutely no effect to skb_tx_timestamp(), since there
> is no dma access involved here. In fact skb_tx_timestamp() could probably
> be even reordered to appear after the dma_wmb.
>
> Anyway, there is the wmb() directly after the assignment to "info". _This_
> barrier  should ensure that skb_tx_timestamp() (along with a flush of data
> and info to DMA) is executed before "txbd_curr" is advanced.
> This means that the corresponding skb cant be freed prematurely by tx_clean().

The concern here is about sending adequate PTP payload on the network.

skb_tx_timestamp() is used for network clock synchronization. Some extra
information must be transmitted. Be it through direct payload change
or through indirect control, it _is_ related to dma.

Several (most ?) skb_tx_timestamp() misuses blur the picture: CPU vs device
sync is of course way below the radar when the driver crashes because of
plain use-after-free skb_tx_timestamp() :o/

-- 
Ueimor
