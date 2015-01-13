From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] gianfar: correct the bad expression while writing
 bit-pattern
Date: Mon, 12 Jan 2015 22:01:31 -0800
Message-ID: <1421128891.4099.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B3D63B.1010608@cogentembedded.com>
	 <1421126938-16268-1-git-send-email-sanjeev_sharma@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, claudiu.manoil@freescale.com,
	peter.senna@gmail.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421126938-16268-1-git-send-email-sanjeev_sharma@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-01-13 at 10:58 +0530, Sanjeev Sharma wrote:
> This patch correct the bad expression while writing the
> bit-pattern from software's buffer to hardware registers.
> 
> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
> ---
> Changes in v2:
>   - incorporated review comment as per Sergei. 
> 
>  drivers/net/ethernet/freescale/gianfar_ethtool.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> index 3e1a9c1..347d5ee 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -1586,7 +1586,7 @@ static int gfar_write_filer_table(struct gfar_private *priv,
>  		return -EBUSY;
>  
>  	/* Fill regular entries */
> -	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
> +	for (; i < MAX_FILER_IDX - 1 && i < tab->fe[i].ctrl);
>  	     i++)
>  		gfar_write_filer(priv, i, tab->fe[i].ctrl, tab->fe[i].prop);
>  	/* Fill the rest with fall-troughs */

This makes no sense. Have you tried to compile this ?
