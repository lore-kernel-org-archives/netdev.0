From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Thu, 28 Jul 2011 23:20:04 +0200
Message-ID: <1311888004.2677.18.camel@deadeye>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	 <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8300 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755849Ab1G1VUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 17:20:09 -0400
In-Reply-To: <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-27 at 15:17 -0700, Greg Rose wrote:
> Add new set commands to configure the number of SR-IOV VFs, the
> number of VM queues and spoof checking on/off switch.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> ---
> 
>  include/linux/ethtool.h |   11 ++++++++++-
>  1 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index c6e427a..c4972ba 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -36,12 +36,14 @@ struct ethtool_cmd {
>  	__u8	mdio_support;
>  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
>  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> +	__u32	num_vfs;	/* Enable SR-IOV VFs */

What are the semantics of changing this after VFs have already been set
up?

> +	__u32	num_vmqs;	/* Set number of queues for VMDq */

VMDq is an Intel proprietary name.  Please specify this in generic
terms.

>  	__u16	speed_hi;       /* The forced speed (upper
>  				 * bits) in Mbps. Please use
>  				 * ethtool_cmd_speed()/_set() to
>  				 * access it */
>  	__u8	eth_tp_mdix;
> -	__u8	reserved2;
> +	__u8	spoof_check;	/* Enable/Disable anti-spoofing */
>  	__u32	lp_advertising;	/* Features the link partner advertises */
>  	__u32	reserved[2];
>  };
> @@ -1121,6 +1123,13 @@ struct ethtool_ops {
>  #define AUTONEG_DISABLE		0x00
>  #define AUTONEG_ENABLE		0x01
>  
> +/* Enable or disable MAC and/or VLAN spoofchecking.If this is
> + * set to enable, then depending on the controller capabilities
> + * MAC and/or VLAN spoofing will be turned on.
> + */
> +#define SPOOFCHECK_DISABLE     0x00
> +#define SPOOFCHECK_ENABLE      0x01

I'm not sure it's necessary to continue defining macros for booleans.

This should not 'depend on controller capabilities'.  If the
administrator tries to enable this feature on a device that does not
support it, the request must return an error rather than failing
silently.  (This is another reason to define new commands.)

Ben.

>  /* Mode MDI or MDI-X */
>  #define ETH_TP_MDI_INVALID	0x00
>  #define ETH_TP_MDI		0x01
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

