From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 8/9] qlcnic: Enhanced channel configuration logs
Date: Sun, 14 Apr 2013 12:55:56 +0200
Message-ID: <20130414105556.GF30385@electric-eye.fr.zoreil.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
 <1365874114-6759-9-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Manish Chopra <manish.chopra@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44090 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036Ab3DNK4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 06:56:12 -0400
Content-Disposition: inline
In-Reply-To: <1365874114-6759-9-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shahed Shaikh <shahed.shaikh@qlogic.com> :
[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 2a72c4f..ae1b555 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -3276,22 +3276,45 @@ qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
>  	return err;
>  }
>  
> -int qlcnic_validate_max_rss(u8 max_hw, u8 val)
> +int qlcnic_validate_max_rss(struct qlcnic_adapter *adapter,
> +			    __u32 val)
>  {
>  	u32 max_allowed;
> +	u8 max_hw = adapter->ahw->max_rx_ques;
>  
> -	if (max_hw > QLC_MAX_SDS_RINGS) {
> -		max_hw = QLC_MAX_SDS_RINGS;
> -		pr_info("max rss reset to %d\n", QLC_MAX_SDS_RINGS);
> +	if (val > QLC_MAX_SDS_RINGS) {
> +		netdev_err(adapter->netdev,

Please consider a local variable for adapter->netdev.

-- 
Ueimor
