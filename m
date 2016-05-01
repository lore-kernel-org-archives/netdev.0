From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 10/12] net/mlx5e: Create aRFS flow tables
Date: Sat, 30 Apr 2016 19:18:48 -0700
Message-ID: <20160501021845.GA10348@ast-mbp.thefacebook.com>
References: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
 <1461883002-8912-11-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34479 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbcEACSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 22:18:54 -0400
Received: by mail-pa0-f43.google.com with SMTP id r5so61790042pag.1
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 19:18:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1461883002-8912-11-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 29, 2016 at 01:36:40AM +0300, Saeed Mahameed wrote:
> From: Maor Gottlieb <maorg@mellanox.com>
> 
> Create the following four flow tables for aRFS usage:
> 1. IPv4 TCP - filtering 4-tuple of IPv4 TCP packets.
> 2. IPv6 TCP - filtering 4-tuple of IPv6 TCP packets.
> 3. IPv4 UDP - filtering 4-tuple of IPv4 UDP packets.
> 4. IPv6 UDP - filtering 4-tuple of IPv6 UDP packets.
> 
> Each flow table has two flow groups: one for the 4-tuple
> filtering (full match)  and the other contains * rule for miss rule.
> 
> Full match rule means a hit for aRFS and packet will be forwarded
> to the dedicated RQ/Core, miss rule packets will be forwarded to
> default RSS hashing.
> 
> Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/Makefile  |    1 +
>  drivers/net/ethernet/mellanox/mlx5/core/en.h      |   41 ++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c |  251 +++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   |   23 +-
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    8 +-
>  drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |    3 +-
>  6 files changed, 313 insertions(+), 14 deletions(-)
>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
> index 4fc45ee..679e18f 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
> @@ -9,3 +9,4 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
>  		en_txrx.o en_clock.o vxlan.o en_tc.o
>  
>  mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
> +mlx5_core-$(CONFIG_RFS_ACCEL) +=  en_arfs.o

this line breaks the build when RFS is on
and CONFIG_MLX5_CORE_EN is off.
