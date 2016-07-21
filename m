From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net V2] net/mlx5e: Fix del vxlan port command buffer
 memset
Date: Wed, 20 Jul 2016 17:53:55 -0700
Message-ID: <20160721005350.GB85017@ast-mbp>
References: <1469050793-29235-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matthew Finlay <matt@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35200 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbcGUAyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 20:54:00 -0400
Received: by mail-yw0-f193.google.com with SMTP id c13so4556610ywh.2
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 17:54:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469050793-29235-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 12:39:53AM +0300, Saeed Mahameed wrote:
> memset the command buffers rather than the pointers to them.

that is still wrong commit log.
This patch makes zero difference to generated code.
'&in' is the same as 'in'

> Fixes: b3f63c3d5e2c ("net/mlx5e: Add netdev support for VXLAN tunneling")
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
> 
> V2:
>  - Improved log message.
> 
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
