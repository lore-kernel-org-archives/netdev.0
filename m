From: Amitkumar Karwar <akarwar@marvell.com>
Subject: RE: [PATCH 04/12] mwifiex: use ktime_get_real for timestamping
Date: Fri, 9 Oct 2015 11:36:44 +0000
Message-ID: <89eb0939d50045ff8d248e6f8fd87d1a@SC-EXCH04.marvell.com>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <1443612402-3000775-5-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "y2038@lists.linaro.org" <y2038@lists.linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443612402-3000775-5-git-send-email-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Wednesday, September 30, 2015 4:57 PM
> To: netdev@vger.kernel.org
> Cc: y2038@lists.linaro.org; linux-kernel@vger.kernel.org; David S.
> Miller; Arnd Bergmann; Amitkumar Karwar; Nishant Sarmukadam; Kalle Valo;
> linux-wireless@vger.kernel.org
> Subject: [PATCH 04/12] mwifiex: use ktime_get_real for timestamping
> 
> The mwifiex_11n_aggregate_pkt() function creates a ktime_t from a
> timeval returned by do_gettimeofday, which is slow and causes an
> overflow in 2038 on 32-bit architectures.
> 
> This solves both problems by using the appropriate ktime_get_real()
> function.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Amitkumar Karwar <akarwar@marvell.com>
> Cc: Nishant Sarmukadam <nishants@marvell.com>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: linux-wireless@vger.kernel.org
> ---
>  drivers/net/wireless/mwifiex/11n_aggr.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/11n_aggr.c
> b/drivers/net/wireless/mwifiex/11n_aggr.c
> index f7c717253a66..78853c51774d 100644
> --- a/drivers/net/wireless/mwifiex/11n_aggr.c
> +++ b/drivers/net/wireless/mwifiex/11n_aggr.c
> @@ -173,7 +173,6 @@ mwifiex_11n_aggregate_pkt(struct mwifiex_private
> *priv,
>  	int pad = 0, aggr_num = 0, ret;
>  	struct mwifiex_tx_param tx_param;
>  	struct txpd *ptx_pd = NULL;
> -	struct timeval tv;
>  	int headroom = adapter->iface_type == MWIFIEX_USB ? 0 :
> INTF_HEADER_LEN;
> 
>  	skb_src = skb_peek(&pra_list->skb_head); @@ -203,8 +202,7 @@
> mwifiex_11n_aggregate_pkt(struct mwifiex_private *priv,
>  	tx_info_aggr->flags |= MWIFIEX_BUF_FLAG_AGGR_PKT;
>  	skb_aggr->priority = skb_src->priority;
> 
> -	do_gettimeofday(&tv);
> -	skb_aggr->tstamp = timeval_to_ktime(tv);
> +	skb_aggr->tstamp = ktime_get_real();
> 
>  	do {
>  		/* Check if AMSDU can accommodate this MSDU */
> --
> 2.1.0.rc2

Looks good.

Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Regards,
Amitkumar
