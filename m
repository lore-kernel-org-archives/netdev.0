From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 06/12] qlcnic: 83xx data path and HW interfaces routines
Date: Mon, 10 Sep 2012 17:54:29 +0100
Message-ID: <1347296069.2823.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <1347058893-30165-1-git-send-email-sony.chacko@qlogic.com>
	 <1347058893-30165-7-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34894 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751076Ab2IJQyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 12:54:33 -0400
In-Reply-To: <1347058893-30165-7-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-07 at 19:01 -0400, Sony Chacko wrote:
> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> Modify 82xx driver to support new adapter - Qlogic 83XX CNA
> Create 83xx adapter data path and hardware interface routines
[...]
> +int qlcnic_83xx_set_pauseparam(struct qlcnic_adapter *adapter,
> +			       struct ethtool_pauseparam *pause)
> +{
> +	int status = 0;
> +	u32 config = adapter->ahw->port_config;
> +
> +	if ((pause->rx_pause) || (pause->tx_pause) || (pause->autoneg))
> +		adapter->ahw->port_config |= QLC_83XX_CFG_PAUSE_STD;
> +	else if (!(pause->rx_pause && pause->tx_pause && pause->autoneg))

Since you appear to support only all-enabled or all-disabled, this
second condition should be:

	!pause->rx_pause && !pause->tx_pause && !pause->autoneg

> +		adapter->ahw->port_config &= ~QLC_83XX_CFG_PAUSE_STD;
> +	else
> +		return -EINVAL;
[...]
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -35,28 +35,31 @@ char qlcnic_driver_name[] = "qlcnic";
[...] 
> -static int use_msi = 1;
> +int use_msi = 1;
>  module_param(use_msi, int, 0444);
>  MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled");
>  
> -static int use_msi_x = 1;
> +int use_msi_x = 1;
>  module_param(use_msi_x, int, 0444);
>  MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled");
>  
> -static int auto_fw_reset = 1;
> +int auto_fw_reset = 1;
>  module_param(auto_fw_reset, int, 0644);
>  MODULE_PARM_DESC(auto_fw_reset, "Auto firmware reset (0=disabled, 1=enabled");
>  
> -static int load_fw_file;
> +int load_fw_file;
>  module_param(load_fw_file, int, 0444);
>  MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");
[...]

All the variables being declared extern need to be renamed to have a
'qlcnic_' prefix.  (The parameters shouldn't be renamed, though - use
module_param_named().)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
