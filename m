From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 0/12] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Mon, 10 Sep 2012 21:19:51 -0400
Message-ID: <1347326403-1705-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22905 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756649Ab2IKBhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 21:37:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> Re: [PATCH 06/12] qlcnic: 83xx data path and HW interface routines

> -static int load_fw_file;
> +int load_fw_file;
> module_param(load_fw_file, int, 0444); MODULE_PARM_DESC(load_fw_file, 
> "Load firmware from (0=flash, 1=file");

> All the variables being declared extern need to be renamed to have a 'qlcnic_' prefix.
> (The parameters shouldn't be renamed, though - use module_param_named().)

> +int qlcnic_83xx_set_pauseparam(struct qlcnic_adapter *adapter,
> +			       struct ethtool_pauseparam *pause) {
> +	int status = 0;
> +	u32 config = adapter->ahw->port_config;
> +
> +	if ((pause->rx_pause) || (pause->tx_pause) || (pause->autoneg))
> +		adapter->ahw->port_config |= QLC_83XX_CFG_PAUSE_STD;
> +	else if (!(pause->rx_pause && pause->tx_pause && pause->autoneg))

> Since you appear to support only all-enabled or all-disabled,
> this second condition should be:
> !pause->rx_pause && !pause->tx_pause && !pause->autoneg

We have updated the patches.
Please apply the updated 12 patch series to net-next.

Thanks,
Sony
