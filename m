From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: Re: [RESEND PATCH net 06/10] net: ethernet: mediatek: fix the loss
Date: Fri, 26 Aug 2016 11:33:39 +0800
Message-ID: <1472182419-17998-1-git-send-email-sean.wang@mediatek.com>
References: <20160825133034.GA25046@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160825133034.GA25046-g2DYL2Zd6BY@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Aug 2016 15:30:34 +0200, Andrew Lunn wrote:
>On Thu, Aug 25, 2016 at 06:44:57PM +0800, Sean Wang wrote:
>> ommited the setting about pin-mux which results in incorrect signals
>> being routed on GMAC2.
>
>Hi Sean
>
>Please could you explain this some more. I don't know too much about
>pinctrl, but i've never seen a driver have to do anything with it. The
>core driver code handles it all, selecting the default state. See
>seeing this here makes me wonder if it is correct.
>
>Thanks
>	Andrew
>
>>

Hi Andrew,

Here pinctrl is used to setup what function the group of the pins is for.

The group of the pins could be configured for the function provided 
by the SoC, such as general purpose I/O or specific function such as
ethernet depending on what products or boards you design for various 
customers or vendors. Thanks for device tree introducing, it is easy 
to find what resources the board needs including the pins usage is 
also defined here.
 
Pins are limited resource that is also meant for the cost 
so that it is common way seen on embedded system.

thanks,
Sean

>> +	eth->pins = devm_pinctrl_get(&pdev->dev);
>> +	if (IS_ERR(eth->pins)) {
>> +		dev_err(&pdev->dev, "cannot get pinctrl\n");
>> +		return PTR_ERR(eth->pins);
>> +	}
>> +
>> +	eth->ephy_default =
>> +		pinctrl_lookup_state(eth->pins, "default");
>> +	if (IS_ERR(eth->ephy_default)) {
>> +		dev_err(&pdev->dev, "cannot get pinctrl state\n");
>> +		return PTR_ERR(eth->ephy_default);
>> +	}
>> +
>>  	clk_prepare_enable(eth->clk_ethif);
>>  	clk_prepare_enable(eth->clk_esw);
>>  	clk_prepare_enable(eth->clk_gp1);
>> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> index f82e3ac..13d3f1b 100644
>> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
>> @@ -404,6 +404,9 @@ struct mtk_eth {
>>  	struct clk			*clk_esw;
>>  	struct clk			*clk_gp1;
>>  	struct clk			*clk_gp2;
>> +	struct pinctrl			*pins;
>> +	struct pinctrl_state		*ephy_default;
>> +
>>  	struct mii_bus			*mii_bus;
>>  	struct work_struct		pending_work;
>>  };
>> -- 
>> 1.9.1
