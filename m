From: Heiko Schocher <hs@denx.de>
Subject: Re: [PATCH] net, can, ti_hecc: fix a run time warn_on.
Date: Mon, 19 Oct 2015 08:51:00 +0200
Message-ID: <562492D4.2060600@denx.de>
References: <1445235739-26537-1-git-send-email-hs@denx.de>
 <56248EE3.4000103@pengutronix.de>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56248EE3.4000103@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Marc,

Am 19.10.2015 um 08:34 schrieb Marc Kleine-Budde:
> On 10/19/2015 08:22 AM, Heiko Schocher wrote:
>> This patch fixes a warning in clk_enable by calling
>> clk_prepare_enable instead.
>
> What about the corresponding clk_disable_unprepare()?

Yes, that should be fixed too, do this in a v2, thanks!

bye,
Heiko
>
> Marc
>
>>
>> Signed-off-by: Heiko Schocher <hs@denx.de>
>> ---
>>
>>   drivers/net/can/ti_hecc.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
>> index cf345cb..c08e8ea 100644
>> --- a/drivers/net/can/ti_hecc.c
>> +++ b/drivers/net/can/ti_hecc.c
>> @@ -951,7 +951,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
>>   	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>>   		HECC_DEF_NAPI_WEIGHT);
>>
>> -	clk_enable(priv->clk);
>> +	clk_prepare_enable(priv->clk);
>>   	err = register_candev(ndev);
>>   	if (err) {
>>   		dev_err(&pdev->dev, "register_candev() failed\n");
>>
>
>

-- 
DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
