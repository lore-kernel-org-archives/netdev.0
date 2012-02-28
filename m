From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/4] net: ethtool: add the EEE support
Date: Tue, 28 Feb 2012 15:45:00 +0000
Message-ID: <1330443900.8460.158.camel@deadeye>
References: <1330433084-18586-1-git-send-email-peppe.cavallaro@st.com>
	 <1330433084-18586-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14139 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755386Ab2B1Pox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 10:44:53 -0500
In-Reply-To: <1330433084-18586-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-28 at 13:44 +0100, Giuseppe CAVALLARO wrote:
> This patch adds two new functions to detect if Energy-Efficient
> Ethernet (EEE) is supported and the way to enable/disable it.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  include/linux/ethtool.h |    7 +++++++
>  net/core/ethtool.c      |   32 ++++++++++++++++++++++++++++++++
>  2 files changed, 39 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index da5b2de..fdea3c7 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -43,6 +43,7 @@ struct ethtool_cmd {
>  	__u8	eth_tp_mdix;
>  	__u8	reserved2;
>  	__u32	lp_advertising;	/* Features the link partner advertises */
> +	__u32	eee;		/* Energy-Efficient Etehrnet */
>  	__u32	reserved[2];
>  };

You can't change the size of this structure.

> @@ -874,6 +875,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
>   * 		   and flag of the device.
>   * @get_dump_data: Get dump data.
>   * @set_dump: Set dump specific flags to the device.
> + * @get_eee: Get Energy-Efficient Ethernet (EEE) supported and status.
> + * @set_eee: Set EEE status (enable/disable).
>   *
>   * All operations are optional (i.e. the function pointer may be set
>   * to %NULL) and callers must take this into account.  Callers must
> @@ -937,6 +940,8 @@ struct ethtool_ops {
>  				 struct ethtool_dump *, void *);
>  	int	(*set_dump)(struct net_device *, struct ethtool_dump *);
>  
> +	int	(*get_eee) (struct net_device *, struct ethtool_value *);
> +	int	(*set_eee) (struct net_device *, struct ethtool_value *);
[...]

Why are there new operations as well as a new field to ethtool_cmd?

Is the value a boolean or a bitmask?

Since EEE is an auto-negotiated feature, why aren't you defining flags
for the supported/advertising/lp_advertising fields?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
