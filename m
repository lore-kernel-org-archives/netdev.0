From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v2 1/2] ethtool: add speed/duplex validation
 functions
Date: Tue, 2 Feb 2016 16:35:20 +0200
Message-ID: <20160202163510-mutt-send-email-mst@redhat.com>
References: <1454423620-2855-1-git-send-email-razor@blackwall.org>
 <1454423620-2855-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754865AbcBBOfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 09:35:23 -0500
Content-Disposition: inline
In-Reply-To: <1454423620-2855-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 02, 2016 at 03:33:39PM +0100, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Add functions which check if the speed/duplex are defined.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> v2: new patch
> 
>  include/uapi/linux/ethtool.h | 34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
> 
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 57fa39005e79..b2e180181629 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1319,11 +1319,45 @@ enum ethtool_sfeatures_retval_bits {
>  
>  #define SPEED_UNKNOWN		-1
>  
> +static inline int ethtool_validate_speed(__u32 speed)
> +{
> +	switch (speed) {
> +	case SPEED_10:
> +	case SPEED_100:
> +	case SPEED_1000:
> +	case SPEED_2500:
> +	case SPEED_5000:
> +	case SPEED_10000:
> +	case SPEED_20000:
> +	case SPEED_25000:
> +	case SPEED_40000:
> +	case SPEED_50000:
> +	case SPEED_56000:
> +	case SPEED_100000:
> +	case SPEED_UNKNOWN:
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> +
>  /* Duplex, half or full. */
>  #define DUPLEX_HALF		0x00
>  #define DUPLEX_FULL		0x01
>  #define DUPLEX_UNKNOWN		0xff
>  
> +static inline int ethtool_validate_duplex(__u8 duplex)
> +{
> +	switch (duplex) {
> +	case DUPLEX_HALF:
> +	case DUPLEX_FULL:
> +	case DUPLEX_UNKNOWN:
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> +
>  /* Which connector port. */
>  #define PORT_TP			0x00
>  #define PORT_AUI		0x01
> -- 
> 2.4.3
