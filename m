From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 4/7] net:ethernet:aquantia: Fix for MCP state
 change.
Date: Wed, 23 Aug 2017 22:17:17 -0700 (PDT)
Message-ID: <20170823.221717.808276378249736288.davem@davemloft.net>
References: <cover.1503496727.git.pavel.belous@aquantia.com>
        <daa58e36851b90b099ade078270bff7cf2872787.1503496727.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darcari@redhat.com,
        Igor.Russkikh@aquantia.com, Nadezhda.Krupnina@aquantia.com,
        simon.edelhaus@aquantia.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751140AbdHXFRS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 01:17:18 -0400
In-Reply-To: <daa58e36851b90b099ade078270bff7cf2872787.1503496727.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Wed, 23 Aug 2017 17:05:05 +0300

> diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
> index a66aee5..fc69408a 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
> +++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_utils.h
> @@ -160,6 +160,19 @@ enum hal_atl_utils_fw_state_e {
>  	MPI_POWER = 4,
>  };
>  
> +union hal_atl_utils_hw_mpi_state_reg {
> +	u32 val;
> +	struct {
> +		u8 e_state;
> +		u8 reserved1;
> +		u8 u_speed;
> +		u8 reserved2:1;
> +		u8 disable_dirty_wake:1;
> +		u8 reserved3:2;
> +		u8 u_downshift:4;
> +	};
> +};
> +

You need to consider endianness when declaring bitfields in C.

Seriously, I'd rather you simply fixed the shifts and masks into the
u32 value than going down this route.
