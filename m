From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Wed, 24 May 2017 09:51:01 -0700
Message-ID: <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-5-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        jsorensen-b10kYP2dOMg@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170523114404.20387-5-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 02:44:02PM +0300, Saeed Mahameed wrote:
> From: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> Mellanox Innova is a NIC with ConnectX and an FPGA on the same
> board. The FPGA is a bump-on-the-wire and thus affects operation of
> the mlx5_core driver on the ConnectX ASIC.
> 
> Add basic support for Innova in mlx5_core.
> 
> This allows using the Innova card as a regular NIC, by detecting
> the FPGA capability bit, and verifying its load state before
> initializing ConnectX interfaces.

That doesn't sound like cx4/cx5 hw that mlx5 driver suppose to support.

> Also detect FPGA fatal runtime failures and enter error state if
> they ever happen.
> 
> All new FPGA-related logic is placed in its own subdirectory 'fpga',
> which may be built by selecting CONFIG_MLX5_FPGA.
> This prepares for further support of various Innova features in later
> patchsets.
> Additional details about hardware architecture will be provided as
> more features get submitted.
> 
> Signed-off-by: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Reviewed-by: Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> ---
>  MAINTAINERS                                        |  10 +
>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |  10 +
>  drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   3 +
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  11 ++
>  drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.c |  64 +++++++
>  drivers/net/ethernet/mellanox/mlx5/core/fpga/cmd.h |  59 ++++++
>  .../net/ethernet/mellanox/mlx5/core/fpga/core.c    | 202 +++++++++++++++++++++
>  .../net/ethernet/mellanox/mlx5/core/fpga/core.h    |  99 ++++++++++
>  drivers/net/ethernet/mellanox/mlx5/core/main.c     |  19 +-
>  include/linux/mlx5/device.h                        |   6 +
>  include/linux/mlx5/driver.h                        |   5 +
>  include/linux/mlx5/mlx5_ifc.h                      |  11 +-
>  include/linux/mlx5/mlx5_ifc_fpga.h                 | 144 +++++++++++++++
>  13 files changed, 640 insertions(+), 3 deletions(-)

Can you put it into different driver? Dumping everything into by far
the biggest nic driver already is already huge headache in terms on
maintainability, debugging and back ports.
Look at how intel splits their drivers.
ixgb, ixgbe, ixgbevf are different drivers thought they have a lot in
common. On one side it's a bit of copy paste, but on the other side
it makes drivers much easier to develop and maintain independently.
ConnectX-6 code and any future hw support doesn't belong to
mlx5 driver at all.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
