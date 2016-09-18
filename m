From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net 1/3] net/mlx5: Fix flow counter bulk command out
 mailbox allocation
Date: Sun, 18 Sep 2016 21:02:23 +0300
Message-ID: <20160918180223.GM2923@leon.nu>
References: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
 <1474212029-1052-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="1R6ZDISWaA1muLP0"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Tariq Toukan <tariqt@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:45676 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754847AbcIRSCb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 14:02:31 -0400
Content-Disposition: inline
In-Reply-To: <1474212029-1052-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1R6ZDISWaA1muLP0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 18, 2016 at 06:20:27PM +0300, Or Gerlitz wrote:
> From: Roi Dayan <roid@mellanox.com>
>
> The FW command output length should be only the length of struct
> mlx5_cmd_fc_bulk out field. Failing to do so will cause the memcpy
> call which is invoked later in the driver to write over wrong memory
> address and corrupt kernel memory which results in random crashes.
>
> This bug was found using the kernel address sanitizer (kasan).
>
> Fixes: a351a1b03bf1 ('net/mlx5: Introduce bulk reading of flow counters')
> Signed-off-by: Roi Dayan <roid@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
> index 9134010..287ade1 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
> @@ -425,11 +425,11 @@ struct mlx5_cmd_fc_bulk *
>  mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u16 id, int num)
>  {
>  	struct mlx5_cmd_fc_bulk *b;
> -	int outlen = sizeof(*b) +
> +	int outlen =
>  		MLX5_ST_SZ_BYTES(query_flow_counter_out) +
>  		MLX5_ST_SZ_BYTES(traffic_counter) * num;
>
> -	b = kzalloc(outlen, GFP_KERNEL);
> +	b = kzalloc(sizeof(*b) + outlen, GFP_KERNEL);
>  	if (!b)
>  		return NULL;
                  ^^^^^^^^^ very controversial decision.
The code flow mlx5_fc_stats_query->mlx5_cmd_fc_bulk_alloc->kzalloc
failure is the same for success scenario too.

It is not related to the proposed patch.

>
> --
> 2.3.7
>

--1R6ZDISWaA1muLP0
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX3tavAAoJEORje4g2clinib0QAJgxE3/aO4NnKNmkaAsCk/e3
g7Gw2FpCa8hUdk7Ch7ypo2YKeWxYPWL+FtRDOB9Ttls4GO29o5SWHkULzoYaUIpd
27yg7a6bhLQza2lxlqM3MI7IK0PImSriK403OPCfKWyFp10LwcMgY/CEqJnmgyOg
tswm+DFVfHyQ/yRo3mc7Ycuk3wIbV+MNTiAlxnic46YSuS4m1+1IKaITrr3DU24c
hZzu7x1xH+EL4W4Go2CI69gXmGrsYjRmdMSWYAYCs0Gp73HfbKilQPy045Wb02l/
aq7yMl4cxk6EE8aVo/HYhh/THpzRLdkHPApRfYTIb8P4rQj0Sd+Ym94n2wFWPg7E
0CYyzOYP9haV9Gw9auOJWt5ZUdvZNhcR6ZF+zSgpehFhFfgdIu3Cf6Zb2sBIC83S
hAJC0TsoBO3IE4hyQL/SglC1UkfJnGPUNvpbo6zutXphWR1+Ce+MrZtvFXqzm1Hh
H30N7PIHb65YOHmjApQns55q0fwjX6b9A+/jpHd0hYfPckycxAWF8h9cKB2X//1t
VkQbRn7yBGtKzb86WSi6DyHmFLLagdTphfgFBjMWdsm1arpXymD38FobTLDPDjK+
F0HZWRjQBqjkwR1OlTY5hAWgYcbKqtGD1VnsjuIHLmrqRHd1QEfk6fYPJdFdAVAi
lTOoigIQCozBksZo3XuO
=+Q/6
-----END PGP SIGNATURE-----

--1R6ZDISWaA1muLP0--
