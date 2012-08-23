From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 12/13] igb: Correct PTP support query from ethtool.
Date: Thu, 23 Aug 2012 13:24:26 +0200
Message-ID: <20120823112426.GD2238@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:39491 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054Ab2HWLYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 07:24:31 -0400
Received: by wgbdr13 with SMTP id dr13so527090wgb.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 04:24:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1345715813-20757-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 02:56:52AM -0700, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> Update ethtool_get_ts_info to not report any supported functionality on
> 82575 and add support for V2 Sync and V2 Delay packets. In the case
> where CONFIG_IGB_PTP is not defined, we should be reporting default
> values.

> diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c

...

> +#endif /* CONFIG_IGB_PTP */
> +	default:
> +		return ethtool_op_get_ts_info(dev, info);

This is wrong. Using this function advertises that you support SW TX
time stamps, which you do not.

Thanks,
Richard

> +		break;
> +	}
>  
>  	return 0;
>  }
> -#endif /* CONFIG_IGB_PTP */
>  
>  static int igb_ethtool_begin(struct net_device *netdev)
>  {
> @@ -2351,9 +2368,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
>  	.get_ethtool_stats      = igb_get_ethtool_stats,
>  	.get_coalesce           = igb_get_coalesce,
>  	.set_coalesce           = igb_set_coalesce,
> -#ifdef CONFIG_IGB_PTP
>  	.get_ts_info            = igb_get_ts_info,
> -#endif /* CONFIG_IGB_PTP */
>  	.begin			= igb_ethtool_begin,
>  	.complete		= igb_ethtool_complete,
>  };
> -- 
> 1.7.11.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
