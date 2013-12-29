From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net: mlx4: slight optimization of addr compare
Date: Sun, 29 Dec 2013 15:29:56 +0200
Message-ID: <20131229132944.GA2944@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <52BD22C3.9070908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:45274 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab3L2NaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 08:30:04 -0500
Content-Disposition: inline
In-Reply-To: <52BD22C3.9070908@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/12/13 14:48 +0800, Ding Tianhong wrote:
> Use possibly more efficient ether_addr_equal
> to instead of memcmp.
> 
> Cc: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c        | 4 ++--
>  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 6f92090..7e43858 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -782,7 +782,7 @@ static void update_mclist_flags(struct mlx4_en_priv *priv,
>  	list_for_each_entry(dst_tmp, dst, list) {
>  		found = false;
>  		list_for_each_entry(src_tmp, src, list) {
> -			if (!memcmp(dst_tmp->addr, src_tmp->addr, ETH_ALEN)) {
> +			if (ether_addr_equal(dst_tmp->addr, src_tmp->addr)) {
>  				found = true;
>  				break;
>  			}
> @@ -797,7 +797,7 @@ static void update_mclist_flags(struct mlx4_en_priv *priv,
>  	list_for_each_entry(src_tmp, src, list) {
>  		found = false;
>  		list_for_each_entry(dst_tmp, dst, list) {
> -			if (!memcmp(dst_tmp->addr, src_tmp->addr, ETH_ALEN)) {
> +			if (ether_addr_equal(dst_tmp->addr, src_tmp->addr)) {
>  				dst_tmp->action = MCLIST_NONE;
>  				found = true;
>  				break;
> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> index 2f3f2bc..2e3232c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> @@ -3634,7 +3634,7 @@ static int validate_eth_header_mac(int slave, struct _rule_hw *eth_header,
>  	    !is_broadcast_ether_addr(eth_header->eth.dst_mac)) {
>  		list_for_each_entry_safe(res, tmp, rlist, list) {
>  			be_mac = cpu_to_be64(res->mac << 16);
> -			if (!memcmp(&be_mac, eth_header->eth.dst_mac, ETH_ALEN))
> +			if (ether_addr_equal((u8 *)&be_mac, eth_header->eth.dst_mac))
>  				return 0;
>  		}
>  		pr_err("MAC %pM doesn't belong to VF %d, Steering rule rejected\n",
> -- 
> 1.8.0
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Acked-By: Amir Vadai <amirv@mellanox.com>
