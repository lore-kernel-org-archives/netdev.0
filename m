From: Michael Hennerich <michael.hennerich@analog.com>
Subject: Re: [PATCH] ieee802154/adf7242: fix memory leak of firmware
Date: Thu, 7 Apr 2016 13:09:57 +0200
Message-ID: <57064005.2040801@analog.com>
References: <1460027764-27428-1-git-send-email-sudipm.mukherjee@gmail.com>
Reply-To: <michael.hennerich@analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-wpan@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Alexander Aring <aar@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460027764-27428-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/07/2016 01:16 PM, Sudip Mukherjee wrote:
> If the firmware upload or the firmware verification fails then we
> printed the error message and exited but we missed releasing the
> firmware.
>
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

Acked-by: Michael Hennerich <michael.hennerich@analog.com>

> ---
>   drivers/net/ieee802154/adf7242.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ieee802154/adf7242.c b/drivers/net/ieee802154/adf7242.c
> index 89154c0..91d4531 100644
> --- a/drivers/net/ieee802154/adf7242.c
> +++ b/drivers/net/ieee802154/adf7242.c
> @@ -1030,6 +1030,7 @@ static int adf7242_hw_init(struct adf7242_local *lp)
>   	if (ret) {
>   		dev_err(&lp->spi->dev,
>   			"upload firmware failed with %d\n", ret);
> +		release_firmware(fw);
>   		return ret;
>   	}
>
> @@ -1037,6 +1038,7 @@ static int adf7242_hw_init(struct adf7242_local *lp)
>   	if (ret) {
>   		dev_err(&lp->spi->dev,
>   			"verify firmware failed with %d\n", ret);
> +		release_firmware(fw);
>   		return ret;
>   	}
>
>


-- 
Greetings,
Michael
