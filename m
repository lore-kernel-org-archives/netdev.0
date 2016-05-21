From: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 22 May 2016 01:04:42 +0200
Message-ID: <5740E98A.5050803@gmx.de>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com> <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com> <573E2D0C.604@gmx.de>
 <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm>
 <20160521194733.GA30557@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>, Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160521194733.GA30557-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
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

On 21.05.2016 21:47, Francois Romieu wrote:
> Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> :
> [...]
>> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
>> index a3a9392..c2447b0 100644
>> --- a/drivers/net/ethernet/arc/emac_main.c
>> +++ b/drivers/net/ethernet/arc/emac_main.c
>> @@ -686,6 +686,9 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
>>  
>>         skb_tx_timestamp(skb);
>>  
>> +       /* Make sure timestamp is set */
>> +       smp_wmb();
> 
> Should be dma_wmb() (see davem's message).
> 
> It's completely unrelated to SMP.
> 

Its also completely unrelated to dma so I doubt that this is what davem meant.
As far as I understood he was referring to the dma descriptor.

Lino
