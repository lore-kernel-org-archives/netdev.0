From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] can: ti_hecc: add missing prepare and unprepare of the clock
Date: Wed, 18 Jan 2017 11:05:46 +0100
Message-ID: <CAGm1_kuwtnF6nAyb=X9=4zeAhC+5mi3_RC7YFAYciHpKnDgULw@mail.gmail.com>
References: <1484732616-4461-1-git-send-email-yegorslists@googlemail.com> <5ccf750a-e468-5c4b-eb26-1e248b712a93@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Wolfgang Grandegger <wg@grandegger.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:34598 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbdARKMm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 05:12:42 -0500
In-Reply-To: <5ccf750a-e468-5c4b-eb26-1e248b712a93@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 11:01 AM, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> On 01/18/2017 10:43 AM, yegorslists@googlemail.com wrote:
>> From: Yegor Yefremov <yegorslists@googlemail.com>
>>
>> In order to make the driver work with the common clock framework, this
>> patch converts the clk_enable()/clk_disable() to
>> clk_prepare_enable()/clk_disable_unprepare().
>>
>
> Can you add the missing error checking for the prepare_enable call?

Will do.

Yegor

>> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
>> ---
>>  drivers/net/can/ti_hecc.c | 9 +++++----
>>  1 file changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
>> index 680d1ff..0448cb5 100644
>> --- a/drivers/net/can/ti_hecc.c
>> +++ b/drivers/net/can/ti_hecc.c
>> @@ -948,7 +948,8 @@ static int ti_hecc_probe(struct platform_device *pdev)
>>       netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>>               HECC_DEF_NAPI_WEIGHT);
>>
>> -     clk_enable(priv->clk);
>> +     clk_prepare_enable(priv->clk);
>> +
>>       err = register_candev(ndev);
>>       if (err) {
>>               dev_err(&pdev->dev, "register_candev() failed\n");
>> @@ -981,7 +982,7 @@ static int ti_hecc_remove(struct platform_device *pdev)
>>       struct ti_hecc_priv *priv = netdev_priv(ndev);
>>
>>       unregister_candev(ndev);
>> -     clk_disable(priv->clk);
>> +     clk_disable_unprepare(priv->clk);
>>       clk_put(priv->clk);
>>       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>       iounmap(priv->base);
>> @@ -1006,7 +1007,7 @@ static int ti_hecc_suspend(struct platform_device *pdev, pm_message_t state)
>>       hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>>       priv->can.state = CAN_STATE_SLEEPING;
>>
>> -     clk_disable(priv->clk);
>> +     clk_disable_unprepare(priv->clk);
>>
>>       return 0;
>>  }
>> @@ -1016,7 +1017,7 @@ static int ti_hecc_resume(struct platform_device *pdev)
>>       struct net_device *dev = platform_get_drvdata(pdev);
>>       struct ti_hecc_priv *priv = netdev_priv(dev);
>>
>> -     clk_enable(priv->clk);
>> +     clk_prepare_enable(priv->clk);
>>
>>       hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>>       priv->can.state = CAN_STATE_ERROR_ACTIVE;
>>
>
>
> --
> Pengutronix e.K.                  | Marc Kleine-Budde           |
> Industrial Linux Solutions        | Phone: +49-231-2826-924     |
> Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
> Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
>
