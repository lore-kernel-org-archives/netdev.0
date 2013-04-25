From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/4] net/cpsw: optimize the for_each_slave_macro()
Date: Thu, 25 Apr 2013 12:01:24 +0530
Message-ID: <5178CDBC.8030208@ti.com>
References: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de> <1366829305-9752-4-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tglx@linutronix.de>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:47113 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab3DYGcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 02:32:01 -0400
In-Reply-To: <1366829305-9752-4-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/2013 12:18 AM, Sebastian Andrzej Siewior wrote:
>   text    data     bss     dec     hex filename
> 15530      92       4   15626    3d0a cpsw.o.before
> 15478      92       4   15574    3cd6 cpsw.o.after
>
> 52 bytes smaller, 13 for each invocation.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |    9 ++++++---
>   1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 1983f23..8b643d9 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -355,12 +355,15 @@ struct cpsw_priv {
>   #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
>   #define for_each_slave(priv, func, arg...)				\
>   	do {								\
> -		int idx;						\
> +		struct cpsw_slave *slave;				\
> +		int n;							\
>   		if (priv->data.dual_emac)				\
>   			(func)((priv)->slaves + priv->emac_port, ##arg);\
>   		else							\
> -			for (idx = 0; idx < (priv)->data.slaves; idx++)	\
> -				(func)((priv)->slaves + idx, ##arg);	\
> +			for (n = (priv)->data.slaves,			\
> +					slave = (priv)->slaves;		\
> +					n; n--)				\
> +				(func)(slave++, ##arg);			\
>   	} while (0)
>   #define cpsw_get_slave_ndev(priv, __slave_no__)				\
>   	(priv->slaves[__slave_no__].ndev)

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
