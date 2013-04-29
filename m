From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: [PATCH net-next] tg3: shows HW time stamping support only
 if ptp_capable is present
Date: Mon, 29 Apr 2013 11:09:39 -0700
Message-ID: <517EB763.8090009@broadcom.com>
References: <1367255287-2664-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, "Jiri Benc" <jbenc@redhat.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Flavio Leitner" <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2559 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752235Ab3D2SJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 14:09:48 -0400
In-Reply-To: <1367255287-2664-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/29/2013 10:08 AM, Flavio Leitner wrote:
> Current tg3 shows hardware timestamping support for all devices
> when that is true only for the hardware with PTP_CAPABLE flag
> present.
>
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>   drivers/net/ethernet/broadcom/tg3.c | 11 +++++++----
>   1 file changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index ac83c87..ef0b8a6 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -5992,10 +5992,13 @@ static int tg3_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
>
>   	info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
>   				SOF_TIMESTAMPING_RX_SOFTWARE |
> -				SOF_TIMESTAMPING_SOFTWARE    |
> -				SOF_TIMESTAMPING_TX_HARDWARE |
> -				SOF_TIMESTAMPING_RX_HARDWARE |
> -				SOF_TIMESTAMPING_RAW_HARDWARE;
> +				SOF_TIMESTAMPING_SOFTWARE;
> +
> +	if (tg3_flag(tp, PTP_CAPABLE)) {
> +		info->so_timestamping = SOF_TIMESTAMPING_TX_HARDWARE |
> +					SOF_TIMESTAMPING_RX_HARDWARE |
> +					SOF_TIMESTAMPING_RAW_HARDWARE;
> +	}
>
>   	if (tp->ptp_clock)
>   		info->phc_index = ptp_clock_index(tp->ptp_clock);
>

Thanks Flavio.

Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>
