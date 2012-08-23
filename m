From: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH] mwifiex: use is_zero_ether_addr() instead of memcmp()
Date: Thu, 23 Aug 2012 11:28:14 -0700
Message-ID: <477F20668A386D41ADCC57781B1F7043083B0BB9B4@SC-VEXCH1.marvell.com>
References: <CAPgLHd9iXQf3_W5b4kO1Mv68udqnmfFO8n+R-0ZqzCrhg1Z_WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org" <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPgLHd9iXQf3_W5b4kO1Mv68udqnmfFO8n+R-0ZqzCrhg1Z_WQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wei,

Thanks for the patch.

> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
> 
> Using is_zero_ether_addr() instead of directly use
> memcmp() to determine if the ethernet address is all
> zeros.
> 
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)

Apparently there are two more occurrences of zero_mac (scan.c:843) and bc_mac (sta_cmd.c:596).
But I can fix them when I get the chance.

> 
> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Acked-by: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>

Thanks,
Bing

> ---
>  drivers/net/wireless/mwifiex/sta_cmdresp.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
> index 0b09004..a2a33dc 100644
> --- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
> +++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
> @@ -17,6 +17,8 @@
>   * this warranty disclaimer.
>   */
> 
> +#include <linux/etherdevice.h>
> +
>  #include "decl.h"
>  #include "ioctl.h"
>  #include "util.h"
> @@ -736,7 +738,6 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
>  {
>  	struct host_cmd_ds_802_11_ibss_status *ibss_coal_resp =
>  					&(resp->params.ibss_coalescing);
> -	u8 zero_mac[ETH_ALEN] = { 0, 0, 0, 0, 0, 0 };
> 
>  	if (le16_to_cpu(ibss_coal_resp->action) == HostCmd_ACT_GEN_SET)
>  		return 0;
> @@ -745,7 +746,7 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
>  		"info: new BSSID %pM\n", ibss_coal_resp->bssid);
> 
>  	/* If rsp has NULL BSSID, Just return..... No Action */
> -	if (!memcmp(ibss_coal_resp->bssid, zero_mac, ETH_ALEN)) {
> +	if (is_zero_ether_addr(ibss_coal_resp->bssid)) {
>  		dev_warn(priv->adapter->dev, "new BSSID is NULL\n");
>  		return 0;
>  	}
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
