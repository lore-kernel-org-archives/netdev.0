From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: smc91x: propagate irq return code
Date: Mon, 1 Feb 2016 15:36:29 +0300
Message-ID: <56AF514D.6010608@cogentembedded.com>
References: <1454280377-25697-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>,
	Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454280377-25697-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/1/2016 1:46 AM, Robert Jarzmik wrote:

> The smc91x driver doesn't honor the probe deferral mechanism when the
> interrupt source is not yet available, such as one provided by a gpio
> controller not probed.
>
> Fix this by propagating the platform_get_irq() error code as the probe
> return value.
>
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> ---
>   drivers/net/ethernet/smsc/smc91x.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
> index 0e2fc1a844ab..43ab7aa31a79 100644
> --- a/drivers/net/ethernet/smsc/smc91x.c
> +++ b/drivers/net/ethernet/smsc/smc91x.c
> @@ -2343,7 +2343,7 @@ static int smc_drv_probe(struct platform_device *pdev)
>
>   	ndev->irq = platform_get_irq(pdev, 0);
>   	if (ndev->irq <= 0) {
> -		ret = -ENODEV;
> +		ret = ndev->irq;

    What if 'ndev->irq' does equal 0?

MBR, Sergei
