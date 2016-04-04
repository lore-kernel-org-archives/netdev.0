From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 09/15] wcn36xx: Parse trigger_ba response properly
Date: Mon, 4 Apr 2016 15:24:36 +0300
Message-ID: <57025D04.80605@cogentembedded.com>
References: <1459721806-11817-1-git-send-email-bjorn.andersson@linaro.org>
 <1459721806-11817-9-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>, wcn36xx@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459721806-11817-9-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 4/4/2016 1:16 AM, Bjorn Andersson wrote:

> From: Pontus Fuchs <pontus.fuchs@gmail.com>
>
> This message does not follow the canonical format and needs it's own
> parser.
>
> Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> ---
>   drivers/net/wireless/ath/wcn36xx/smd.c | 14 ++++++++++++--
>   1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
> index 76c6856ed932..7f315d098f52 100644
> --- a/drivers/net/wireless/ath/wcn36xx/smd.c
> +++ b/drivers/net/wireless/ath/wcn36xx/smd.c
> @@ -1968,6 +1968,17 @@ out:
>   	return ret;
>   }
>
> +static int wcn36xx_smd_trigger_ba_rsp(void *buf, int len)
> +{
> +	struct wcn36xx_hal_trigger_ba_rsp_msg *rsp;
> +
> +	if (len < sizeof(*rsp))
> +		return -EINVAL;
> +
> +	rsp = (struct wcn36xx_hal_trigger_ba_rsp_msg *) buf;

    Casts from 'void *' to other pointer types are automatic, no need for the 
explicit cast.

[...]

MBR, Sergei
