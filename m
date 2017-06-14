From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [PATCH net-next] net/mlxfw: fix a NULL dereference
Date: Wed, 14 Jun 2017 14:03:23 +0300
Message-ID: <9ca5d66f-3eed-444a-61c8-269f55945be7@mellanox.com>
References: <20170614104152.GM29394@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50084.outbound.protection.outlook.com ([40.107.5.84]:53600
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751771AbdFNLDb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 07:03:31 -0400
In-Reply-To: <20170614104152.GM29394@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2017 01:41 PM, Dan Carpenter wrote:
> If we hit this error path we end up returning ERR_PTR(0) which is NULL.
> The caller is not expecting that so it results in a NULL dereference.
>
> Fixes: 410ed13cae39 ("Add the mlxfw module for Mellanox firmware flash process")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c b/drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c
> index 628150d28061..993cb5ba934e 100644
> --- a/drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c
> +++ b/drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.c
> @@ -594,6 +594,7 @@ struct mlxfw_mfa2_component *
>  	if (memcmp(comp_data->buff, mlxfw_mfa2_comp_magic,
>  		   mlxfw_mfa2_comp_magic_len) != 0) {
>  		pr_err("Component has wrong magic\n");
> +		err = -EINVAL;
>  		goto err_out;
>  	}
>  


Acked-by: Yotam Gigi <yotamg@mellanox.com>
