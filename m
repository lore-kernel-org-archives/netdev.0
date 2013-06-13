From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: Re: [PATCH 09/15] net: can: Convert to use devm_ioremap_resource
Date: Thu, 13 Jun 2013 11:11:09 +0530
Message-ID: <CAK9yfHzAkca-YxFoSv=vyxgOQMyi8adgeABi3ZHW=Jiw2Z51dg@mail.gmail.com>
References: <1370864113-17895-1-git-send-email-tushar.behera@linaro.org>
	<1370864113-17895-10-git-send-email-tushar.behera@linaro.org>
	<51B958D8.2070804@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, thierry.reding@gmail.com,
	patches@linaro.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Tushar Behera <tushar.behera@linaro.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <51B958D8.2070804@linaro.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13 June 2013 11:00, Tushar Behera <tushar.behera@linaro.org> wrote:
> On 06/10/2013 05:05 PM, Tushar Behera wrote:
>> Commit 75096579c3ac ("lib: devres: Introduce devm_ioremap_resource()")
>> introduced devm_ioremap_resource() and deprecated the use of
>> devm_request_and_ioremap().
>>
>> Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
>> CC: netdev@vger.kernel.org
>> CC: linux-can@vger.kernel.org
>> CC: Marc Kleine-Budde <mkl@pengutronix.de>
>> CC: Wolfgang Grandegger <wg@grandegger.com>
>> ---
>>  drivers/net/can/c_can/c_can_platform.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
>> index 6b6130b..b918c73 100644
>> --- a/drivers/net/can/c_can/c_can_platform.c
>> +++ b/drivers/net/can/c_can/c_can_platform.c
>> @@ -201,8 +201,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
>>                       priv->instance = pdev->id;
>>
>>               res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
>> -             priv->raminit_ctrlreg = devm_request_and_ioremap(&pdev->dev, res);
>> -             if (!priv->raminit_ctrlreg || priv->instance < 0)
>> +             priv->raminit_ctrlreg = devm_ioremap_resource(&pdev->dev, res);
>> +             if (IS_ERR(priv->raminit_ctrlreg) || priv->instance < 0)
>>                       dev_info(&pdev->dev, "control memory is not used for raminit\n");
>>               else
>>                       priv->raminit = c_can_hw_raminit;
>>
>
> IS_ERR() check on the return value of devm_ioremap_resource produces
> following sparse warning. This is because of the __iomem address space
> attribute. How should we fix this?
>
> drivers/net/can/c_can/c_can_platform.c:205:32: warning: incorrect type
> in argument 1 (different address spaces)
> drivers/net/can/c_can/c_can_platform.c:205:32:    expected void const *ptr
> drivers/net/can/c_can/c_can_platform.c:205:32:    got unsigned int
> [noderef] [usertype] <asn:2>*raminit_ctrlreg
>

This is a known issue since the time devm_ioremap_resource was
introduced. Thierry had already submitted some fixes for this.
I am not sure if they have been applied yet.
More details here:
https://patchwork.kernel.org/patch/2071361/

-- 
With warm regards,
Sachin
