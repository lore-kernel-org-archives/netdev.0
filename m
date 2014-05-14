From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 01/11] ixgbe: fix detection of SFP+ capable interfaces
Date: Wed, 14 May 2014 16:26:27 +0400
Message-ID: <537360F3.9000000@cogentembedded.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com> <1400057663-4578-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:60558 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbaENM01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 08:26:27 -0400
Received: by mail-la0-f51.google.com with SMTP id gf5so1342729lab.24
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 05:26:25 -0700 (PDT)
In-Reply-To: <1400057663-4578-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 14-05-2014 12:54, Jeff Kirsher wrote:

> From: Emil Tantilov <emil.s.tantilov@intel.com>

> In cases where the driver is loaded while there are no SFP+ modules in
> the cage the interface was not being detected as SFP capable. To account
> for this the driver called identify_sfp in ixgbe_get_settings to make
> sure the data is correct. However when there is no SFP+ module in the cage
> the driver waits for the I2C reads to time out which can take more than a
> second and will cause issues with tools (like net-snmp) that may poll
> for that information.

> This patch resolves the issue by identifying 82599 based NIC with no PHY
> type set as SFP capable which allows the driver to detect the SFP module
> when the interface is brought up. As result of this we can also remove the
> identify_sfp call from ixgbe_get_settings.

> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

[...]

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 8089ea9..e44c42a 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -4660,6 +4660,10 @@ static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
>   	case ixgbe_phy_nl:
>   		if (hw->mac.type == ixgbe_mac_82598EB)
>   			return true;
> +	/* ixgbe_phy_none is set when no SFP module is present */
> +	case ixgbe_phy_none:
> +		if (hw->mac.type == ixgbe_mac_82599EB)
> +			return true;

    Shouldn't it just be combined with the previous case?

>   	default:
>   		return false;
>   	}

WBR, Sergei
