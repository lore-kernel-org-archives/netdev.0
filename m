From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH v2 3/3] ipgre: capture inner headers during
 encapsulation
Date: Mon, 12 Nov 2012 13:20:05 +0200
Message-ID: <1352719205.5201.7.camel@lb-tlvb-dmitry.il.broadcom.com>
References: <1352709418-28996-1-git-send-email-joseph.gasparakis@intel.com>
 <1352709418-28996-4-git-send-email-joseph.gasparakis@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>
To: "Joseph Gasparakis" <joseph.gasparakis@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352709418-28996-4-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My last comment was rejected by the lists due to html tag.
Resending it in plain text. Sorry for the spam.
On Mon, 2012-11-12 at 00:36 -0800, Joseph Gasparakis wrote:
> Populating the inner header pointers of skb for ipgre
> This patch has been compile-tested only.
> 
> Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---
>  net/ipv4/ip_gre.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 7240f8e..e35ed52 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -766,8 +766,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  	int    gre_hlen;
>  	__be32 dst;
>  	int    mtu;
> +	unsigned int offset;
>  
> -	if (skb->ip_summed == CHECKSUM_PARTIAL &&
> +	if (!(skb->dev->features & NETIF_F_HW_CSUM_ENC_BIT) &&
> +	    skb->ip_summed == CHECKSUM_PARTIAL &&
>  	    skb_checksum_help(skb))
>  		goto tx_error;
Gre device currently has constant features set, which does not include
CSUM_ENC bit. Do you plan to propagate it from underlying physical
device?
Thanks.
