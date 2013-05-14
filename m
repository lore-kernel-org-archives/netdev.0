From: Andreas Larsson <andreas@gaisler.com>
Subject: Re: [PATCH] drivers: net: can: grcan: use devm_ioremap_resource()
Date: Tue, 14 May 2013 10:49:32 +0200
Message-ID: <5191FA9C.50200@gaisler.com>
References: <1368458871-7402-1-git-send-email-laurent.navet@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Laurent Navet <laurent.navet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1368458871-7402-1-git-send-email-laurent.navet@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013-05-13 17:27, Laurent Navet wrote:
> Replace a call to deprecated devm_request_and_ioremap by devm_ioremap_resource.
> dev_err() message is no more needed since it's already displayed in
> devm_ioremap_resource().
>
> Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
> ---
>   drivers/net/can/grcan.c |    7 +++----
>   1 file changed, 3 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
> index 17fbc7a..9e9d0d6 100644
> --- a/drivers/net/can/grcan.c
> +++ b/drivers/net/can/grcan.c
> @@ -1683,10 +1683,9 @@ static int grcan_probe(struct platform_device *ofdev)
>   	}
>
>   	res = platform_get_resource(ofdev, IORESOURCE_MEM, 0);
> -	base = devm_request_and_ioremap(&ofdev->dev, res);
> -	if (!base) {
> -		dev_err(&ofdev->dev, "couldn't map IO resource\n");
> -		err = -EADDRNOTAVAIL;
> +	base = devm_ioremap_resource(&ofdev->dev, res);
> +	if (IS_ERR(base)) {
> +		err = PTR_ERR(base);
>   		goto exit_error;
>   	}

Acked-by: Andreas Larsson <andreas@gaisler.com>

