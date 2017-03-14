From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/7] ath9k: ahb: Add OF support
Date: Tue, 14 Mar 2017 14:17:27 +0300
Message-ID: <df4caf97-d6b5-a8a8-250e-94dc41624c12@cogentembedded.com>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
 <1489439116-4233-2-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Crispin <john@phrozen.org>, Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alban <albeu@free.fr>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489439116-4233-2-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 3/14/2017 12:05 AM, Alban wrote:

> Allow registering ath9k AHB devices defined in DT. This just add the
> compatible strings to allow matching the driver and setting the proper
> device ID.
>
> Signed-off-by: Alban <albeu@free.fr>
> ---
>  drivers/net/wireless/ath/ath9k/ahb.c | 47 +++++++++++++++++++++++++++++++++---
>  1 file changed, 43 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath9k/ahb.c b/drivers/net/wireless/ath/ath9k/ahb.c
> index 2bd982c..36a2645 100644
> --- a/drivers/net/wireless/ath/ath9k/ahb.c
> +++ b/drivers/net/wireless/ath/ath9k/ahb.c
[...]
> @@ -79,10 +107,20 @@ static int ath_ahb_probe(struct platform_device *pdev)
>  	int ret = 0;
>  	struct ath_hw *ah;
>  	char hw_name[64];
> +	u16 devid;
>
> -	if (!dev_get_platdata(&pdev->dev)) {
> -		dev_err(&pdev->dev, "no platform data specified\n");
> -		return -EINVAL;
> +	if (id) {
> +		devid = id->driver_data;
> +	} else {
> +		const struct of_device_id *match;
> +
> +		match = of_match_device(ath_ahb_of_match, &pdev->dev);
> +		if (!match) {
> +			dev_err(&pdev->dev, "no device match found\n");
> +			return -EINVAL;
> +		}
> +
> +		devid = (u16)(unsigned long)match->data;

    of_device_get_match_data() instead of the above perhaps?

[...]

MBR, Sergei
