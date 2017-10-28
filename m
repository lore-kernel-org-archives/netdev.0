From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net-next] bnxt_en: Fix randconfig build errors.
Date: Sat, 28 Oct 2017 14:05:04 +0800
Message-ID: <427d0d07-2bb6-da88-d562-05f1a7f5f6f3@huawei.com>
References: <1509170170-14847-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kubakici@wp.pl>, <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:9465 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdJ1GFT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 02:05:19 -0400
In-Reply-To: <1509170170-14847-1-git-send-email-michael.chan@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Michael

On 2017/10/28 13:56, Michael Chan wrote:
> Fix undefined symbols when CONFIG_VLAN_8021Q or CONFIG_INET is not set.
> 
> Fixes: 8c95f773b4a3 ("bnxt_en: add support for Flower based vxlan encap/decap offload")
> Reported-by: Jakub Kicinski <kubakici@wp.pl>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
> index 798d139..d5031f4 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
> @@ -904,6 +904,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
>  				       struct bnxt_tc_l2_key *l2_info,
>  				       struct net_device *real_dst_dev)
>  {
> +#ifdef CONFIG_INET

Can we use #if IS_ENABLED(CONFIG_INET) here too?

I am not familiar with IS_ENABLED, just thought it would be
good to be constistent because you are using IS_ENABLED below.

Best Regards
Yunsheng Lin

>  	struct flowi4 flow = { {0} };
>  	struct net_device *dst_dev;
>  	struct neighbour *nbr;
> @@ -925,6 +926,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
>  	 */
>  	dst_dev = rt->dst.dev;
>  	if (is_vlan_dev(dst_dev)) {
> +#if IS_ENABLED(CONFIG_VLAN_8021Q)
>  		struct vlan_dev_priv *vlan = vlan_dev_priv(dst_dev);
>  
>  		if (vlan->real_dev != real_dst_dev) {
> @@ -938,6 +940,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
>  		l2_info->inner_vlan_tci = htons(vlan->vlan_id);
>  		l2_info->inner_vlan_tpid = vlan->vlan_proto;
>  		l2_info->num_vlans = 1;
> +#endif
>  	} else if (dst_dev != real_dst_dev) {
>  		netdev_info(bp->dev,
>  			    "dst_dev(%s) for %pI4b is not PF-if(%s)",
> @@ -966,6 +969,9 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
>  put_rt:
>  	ip_rt_put(rt);
>  	return rc;
> +#else
> +	return -EOPNOTSUPP;
> +#endif
>  }
>  
>  static int bnxt_tc_get_decap_handle(struct bnxt *bp, struct bnxt_tc_flow *flow,
> 
