From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 5/7] net: wireless: wcn36xx: swallow two wcn3620 IND messages
Date: Sun, 18 Jan 2015 14:47:08 +0300
Message-ID: <54BB9D3C.90306@cogentembedded.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net> <20150118051105.31866.43889.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150118051105.31866.43889.stgit-FDDIDLfWL9/T9rR/E2HzMujRB4CPm7EUkgzjau31qRg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 1/18/2015 8:11 AM, Andy Green wrote:

> WCN3620 can asynchronously send two new kinds of indication message,
> since we can't handle them just accept them quietly.

> Signed-off-by: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>   drivers/net/wireless/ath/wcn36xx/smd.c |    6 ++++++
>   1 file changed, 6 insertions(+)

> diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
> index 6398693..819741c 100644
> --- a/drivers/net/wireless/ath/wcn36xx/smd.c
> +++ b/drivers/net/wireless/ath/wcn36xx/smd.c
[...]
> @@ -2107,6 +2109,10 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
>   	msg_header = (struct wcn36xx_hal_msg_header *)hal_ind_msg->msg;
>
>   	switch (msg_header->msg_type) {
> +	case WCN36XX_HAL_COEX_IND:
> +		break;
> +	case WCN36XX_HAL_AVOID_FREQ_RANGE_IND:
> +		break;

    Can't you merge these 2 cases, so that there's only one *break*?

[...]

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
