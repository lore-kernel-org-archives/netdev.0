From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: Re: [RESEND PATCH net 02/10] net: ethernet: mediatek: fix incorrect
Date: Fri, 26 Aug 2016 13:22:13 +0800
Message-ID: <1472188934-21923-1-git-send-email-sean.wang@mediatek.com>
References: <e1e9ca7a-c33b-3a9e-fd47-48f80bb10a32@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <e1e9ca7a-c33b-3a9e-fd47-48f80bb10a32-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
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

On Date: Thu, 25 Aug 2016 15:49:10 +0200, John Crispin wrote:
>On 25/08/2016 12:44, Sean Wang wrote:
>> If the return value of devm_clk_get is EPROBE_DEFER, we should
>> defer probing the driver. The change is verified and works based
>> on 4.8-rc1 staying with the latest clk-next code for MT7623.
>> 
>> Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
>> ---
>>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 11 +++++++++--
>>  1 file changed, 9 insertions(+), 2 deletions(-)
...
>> +		    PTR_ERR(eth->clk_gp2) == -EPROBE_DEFER)
>> +			return -EPROBE_DEFER;
>> +		else
>> +			return -ENODEV;
>> +	}
>
>Hi Sean,
>
>this looks a bit tedious. maybe a better solution would be to add an
>array to struct mtk_eth for the clocks and an enum for the index
>mapping. that would allow the usage of loops to work out if all clocks
>are fine. the following code calling clk_prepare_enable() could then
>also be turned into a loop
>
>	John

The suggestion is better, so I will use your suggested way to 
to implement the logic in the next version.

>
>>  
>>  	clk_prepare_enable(eth->clk_ethif);
>>  	clk_prepare_enable(eth->clk_esw);
>> 
