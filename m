From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next] spectrum: acl_tcam: Fix catchall prio value
Date: Tue, 7 Feb 2017 14:33:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB027DE02@AcuExch.aculab.com>
References: <1486477643-5920-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "eladr@mellanox.com" <eladr@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>
To: 'Jiri Pirko' <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:61351 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754159AbdBGOeF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:34:05 -0500
In-Reply-To: <1486477643-5920-1-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
> Sent: 07 February 2017 14:27
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This fixes an issue reported by smatch:
> mlxsw_sp_acl_tcam_chunk_create() warn: impossible condition '(priority == (-1)) => (0-u32max ==
> u64max)'
...
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
> b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
> index a0a968e..1ec3dd0 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
> @@ -561,7 +561,7 @@ mlxsw_sp_acl_tcam_region_entry_remove(struct mlxsw_sp *mlxsw_sp,
>  	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptce2), ptce2_pl);
>  }
> 
> -#define MLXSW_SP_ACL_TCAM_CATCHALL_PRIO (-1UL)
> +#define MLXSW_SP_ACL_TCAM_CATCHALL_PRIO (-1U)

Either (-1) or (~0u) is probably better.

	David
