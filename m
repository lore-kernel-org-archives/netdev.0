From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 5/7] mlxsw: Register KVD resources with
 devlink
Date: Wed, 25 Oct 2017 10:40:03 -0600
Message-ID: <7fd8216f-4f86-9039-d4e3-99e6855ecc2c@cumulusnetworks.com>
References: <20171024092245.1386-1-jiri@resnulli.us>
 <20171024092245.1386-6-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:48574 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdJYQkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 12:40:06 -0400
Received: by mail-pf0-f195.google.com with SMTP id b79so376570pfk.5
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 09:40:06 -0700 (PDT)
In-Reply-To: <20171024092245.1386-6-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/17 3:22 AM, Jiri Pirko wrote:
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
> index 12b6ac4..565f94e 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
> @@ -3864,7 +3864,6 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
>  	mlxsw_sp_fids_fini(mlxsw_sp);
>  	mlxsw_sp_kvdl_fini(mlxsw_sp);
>  }
> -
>  static const struct mlxsw_config_profile mlxsw_sp_config_profile = {
>  	.used_max_vepa_channels		= 1,
>  	.max_vepa_channels		= 0,

Why remove the spacer line?

> @@ -3897,6 +3896,95 @@ static const struct mlxsw_config_profile mlxsw_sp_config_profile = {
>  	.resource_query_enable		= 1,
>  };
>  
> +int mlxsw_sp_resource_kvd_size_validate(void *priv, u64 size)
> +{
> +	/* KVD total size cannot be set*/
> +	return -EINVAL;

-EOPNOTSUPP? There is nothing wrong with the value; it's the action that
is not supported.

> +}
> +
> +int mlxsw_sp_resource_kvd_sub_size_validate(void *priv, u64 size)
> +{
> +	const struct mlxsw_config_profile *profile;
> +
> +	profile = &mlxsw_sp_config_profile;
> +	if (size % profile->kvd_hash_granularity)
> +		return -EINVAL;

devlink needs extack capability to return messages to the user.
