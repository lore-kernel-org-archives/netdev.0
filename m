From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 7/7] mlxsw: core: Add support for reload
Date: Wed, 25 Oct 2017 09:31:46 -0600
Message-ID: <d7482076-0a8d-ea12-a53a-731f5364c2df@cumulusnetworks.com>
References: <20171024092245.1386-1-jiri@resnulli.us>
 <20171024092245.1386-8-jiri@resnulli.us>
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
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:44871 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750982AbdJYPbt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 11:31:49 -0400
Received: by mail-pg0-f67.google.com with SMTP id j3so268083pga.1
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 08:31:49 -0700 (PDT)
In-Reply-To: <20171024092245.1386-8-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/17 3:22 AM, Jiri Pirko wrote:
> @@ -980,7 +998,7 @@ static const struct devlink_ops mlxsw_devlink_ops = {
>  
>  int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
>  				   const struct mlxsw_bus *mlxsw_bus,
> -				   void *bus_priv)
> +				   void *bus_priv, bool reload)
>  {
>  	const char *device_kind = mlxsw_bus_info->device_kind;
>  	struct mlxsw_core *mlxsw_core;
> @@ -992,11 +1010,14 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
>  	mlxsw_driver = mlxsw_core_driver_get(device_kind);
>  	if (!mlxsw_driver)
>  		return -EINVAL;
> -	alloc_size = sizeof(*mlxsw_core) + mlxsw_driver->priv_size;
> -	devlink = devlink_alloc(&mlxsw_devlink_ops, alloc_size);
> -	if (!devlink) {
> -		err = -ENOMEM;
> -		goto err_devlink_alloc;
> +
> +	if (!reload) {
> +		alloc_size = sizeof(*mlxsw_core) + mlxsw_driver->priv_size;
> +		devlink = devlink_alloc(&mlxsw_devlink_ops, alloc_size);
> +		if (!devlink) {
> +			err = -ENOMEM;
> +			goto err_devlink_alloc;
> +		}
>  	}
>  
>  	mlxsw_core = devlink_priv(devlink);

devlink is not set if reload is true, yet is used in the line above.
