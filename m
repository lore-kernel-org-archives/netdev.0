From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Add support for 20G link speed
Date: Wed, 01 Jun 2011 23:15:00 +0100
Message-ID: <1306966500.2758.48.camel@bwh-desktop>
References: <1306157880.20872.102.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eilong@broadcom.com
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51097 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab1FAWPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 18:15:04 -0400
In-Reply-To: <1306157880.20872.102.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-23 at 16:38 +0300, Yaniv Rosner wrote:
> Add support for 20G link speed
>
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> ---
>  ethtool-copy.h |    5 +++++
>  ethtool.c      |   18 +++++++++++++++++-
>  2 files changed, 22 insertions(+), 1 deletions(-)
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 22215e9..c02a98b 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -749,6 +749,8 @@ enum ethtool_sfeatures_retval_bits {
>  #define SUPPORTED_10000baseKX4_Full	(1 << 18)
>  #define SUPPORTED_10000baseKR_Full	(1 << 19)
>  #define SUPPORTED_10000baseR_FEC	(1 << 20)
> +#define SUPPORTED_20000baseMLD2_Full	(1 << 21)
> +#define SUPPORTED_20000baseKR2_Full	(1 << 22)
>  
>  /* Indicates what features are advertised by the interface. */
>  #define ADVERTISED_10baseT_Half		(1 << 0)
> @@ -772,6 +774,9 @@ enum ethtool_sfeatures_retval_bits {
>  #define ADVERTISED_10000baseKX4_Full	(1 << 18)
>  #define ADVERTISED_10000baseKR_Full	(1 << 19)
>  #define ADVERTISED_10000baseR_FEC	(1 << 20)
> +#define ADVERTISED_20000baseMLD2_Full	(1 << 21)
> +#define ADVERTISED_20000baseKR2_Full	(1 << 22)
> +
>  
>  /* The following are all involved in forcing a particular link
>   * mode for the device for setting things.  When getting the

You don't need to include this.  I've updated ethtool-copy.h from
today's net-next-2.6.

> diff --git a/ethtool.c b/ethtool.c
> index cfdac65..a099a23 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -1238,6 +1238,20 @@ static void dump_supported(struct ethtool_cmd *ep)
>  	if (mask & SUPPORTED_10000baseT_Full) {
>  		did1++; fprintf(stdout, "10000baseT/Full ");
>  	}
> +	if (did1 && (mask & SUPPORTED_20000baseMLD2_Full)) {
> +		fprintf(stdout, "\n");
> +		fprintf(stdout, "	                        ");
> +	}
> +	if (mask & SUPPORTED_20000baseMLD2_Full) {
> +		did1++; fprintf(stdout, "20000baseMLD2/Full ");
> +	}
> +	if (did1 && (mask & SUPPORTED_20000baseKR2_Full)) {
> +		fprintf(stdout, "\n");
> +		fprintf(stdout, "	                        ");
> +	}
> +	if (mask & SUPPORTED_20000baseKR2_Full) {
> +		did1++; fprintf(stdout, "20000baseKR2/Full ");
> +	}
>  	fprintf(stdout, "\n");
>  
>  	fprintf(stdout, "	Supports auto-negotiation: ");

This doesn't cover the advertised mask.

But I think I'll just combine the code to dump supported vs advertised
flags - it's ridiculous to duplicate it as the flag definitions are
deliberately kept equal to each other.

> @@ -2581,7 +2595,9 @@ static int do_sset(int fd, struct ifreq *ifr)
>  					 ADVERTISED_1000baseT_Half |
>  					 ADVERTISED_1000baseT_Full |
>  					 ADVERTISED_2500baseX_Full |
> -					 ADVERTISED_10000baseT_Full);
> +					 ADVERTISED_10000baseT_Full |
> +					 ADVERTISED_20000baseMLD2_Full |
> +					 ADVERTISED_20000baseKR2_Full);
>  			} else if (advertising_wanted > 0) {
>  				ecmd.advertising = advertising_wanted;
>  			}

You also need to update the table in the manual page, including a note
that this these are not IEEE standard modes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

