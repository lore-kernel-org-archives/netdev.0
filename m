From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 1/2] ethtool: make validate_speed accept all
 speeds between 0 and INT_MAX
Date: Sun, 7 Feb 2016 23:26:18 +0200
Message-ID: <20160207232613-mutt-send-email-mst@redhat.com>
References: <1454878344-21730-1-git-send-email-razor@blackwall.org>
 <1454878344-21730-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58650 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754026AbcBGV0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2016 16:26:22 -0500
Content-Disposition: inline
In-Reply-To: <1454878344-21730-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 07, 2016 at 09:52:23PM +0100, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Devices these days can have any speed and as was recently pointed out
> any speed from 0 to INT_MAX is valid so adjust speed validation to
> accept such values.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  include/uapi/linux/ethtool.h | 19 +------------------
>  1 file changed, 1 insertion(+), 18 deletions(-)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 19676a420fe3..0c608192a4ef 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1321,24 +1321,7 @@ enum ethtool_sfeatures_retval_bits {
>  
>  static inline int ethtool_validate_speed(__u32 speed)
>  {
> -	switch (speed) {
> -	case SPEED_10:
> -	case SPEED_100:
> -	case SPEED_1000:
> -	case SPEED_2500:
> -	case SPEED_5000:
> -	case SPEED_10000:
> -	case SPEED_20000:
> -	case SPEED_25000:
> -	case SPEED_40000:
> -	case SPEED_50000:
> -	case SPEED_56000:
> -	case SPEED_100000:
> -	case SPEED_UNKNOWN:
> -		return 1;
> -	}
> -
> -	return 0;
> +	return speed <= INT_MAX || speed == SPEED_UNKNOWN;
>  }
>  
>  /* Duplex, half or full. */
> -- 
> 2.4.3
