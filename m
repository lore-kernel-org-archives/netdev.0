From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] net/mlx5e: Fix del vxlan port command
Date: Wed, 20 Jul 2016 09:15:18 -0700
Message-ID: <20160720161517.GC76501@ast-mbp.thefacebook.com>
References: <1469026128-15975-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matthew Finlay <matt@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33922 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbcGTQPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 12:15:23 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so3743875pfb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 09:15:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469026128-15975-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 05:48:48PM +0300, Saeed Mahameed wrote:
> mlx5e_vxlan_core_del_port_cmd cleared the wrong address, the address of
> the pointer of the buffer rather than clearing the buffer itself.
> 
> This can lead to a serious stack corruption.

The change is fine, but commit log is complete nonsense.
Nacking to make sure it's adjusted.
We cannot have such commits in the git history.

> Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/vxlan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
> index 05de772..e25a73ed 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
> @@ -72,8 +72,8 @@ static int mlx5e_vxlan_core_del_port_cmd(struct mlx5_core_dev *mdev, u16 port)
>  	u32 in[MLX5_ST_SZ_DW(delete_vxlan_udp_dport_in)];
>  	u32 out[MLX5_ST_SZ_DW(delete_vxlan_udp_dport_out)];
>  
> -	memset(&in, 0, sizeof(in));
> -	memset(&out, 0, sizeof(out));
> +	memset(in, 0, sizeof(in));
> +	memset(out, 0, sizeof(out));
>  
>  	MLX5_SET(delete_vxlan_udp_dport_in, in, opcode,
>  		 MLX5_CMD_OP_DELETE_VXLAN_UDP_DPORT);
> -- 
> 2.8.0
> 
