From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC net-next 1/2] if_link : add support for VF privileges
Date: Tue, 14 Feb 2012 23:24:57 +0000
Message-ID: <1329261897.2443.60.camel@bwh-desktop>
References: <20120214192627.GA14163@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
To: Ajit Khaparde <ajit.khaparde@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11275 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757246Ab2BNXZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 18:25:00 -0500
In-Reply-To: <20120214192627.GA14163@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-14 at 13:26 -0600, Ajit Khaparde wrote:
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
> ---
>  include/linux/if_link.h   |   21 +++++++++++++++++++++
>  include/linux/netdevice.h |    3 +++
>  net/core/rtnetlink.c      |   17 ++++++++++++++++-
>  3 files changed, 40 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index c52d4b5..9c93a8e 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -280,11 +280,26 @@ enum {
>  	IFLA_VF_VLAN,
>  	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
>  	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
> +	IFLA_VF_PRIVILEGE,	/* VF Privilege level setting */
>  	__IFLA_VF_MAX,
>  };
>  
>  #define IFLA_VF_MAX (__IFLA_VF_MAX - 1)
>  
> +enum {
> +	IFLA_VF_PRIVILEGE_DEFAULT = 1,	/* Default privileges */

What are the default privileges?  Should existing drivers report that
their VFs have this?

> +	IFLA_VF_PRIVILEGE_STATS	= 2,	/* Privilege to gather statistics */

I assume that means port or board statistics as opposed to statistics
for the VF?

> +	IFLA_VF_PRIVILEGE_LNK_MGMT = 4,	/* Privilege to manage link params */
> +	IFLA_VF_PRIVILEGE_DIAG	= 8,	/* Privilege to perform diagnostics */
> +	IFLA_VF_PRIVILEGE_MAC	= 16,	/* Privilege to modify MAC address */
> +	IFLA_VF_PRIVILEGE_VLAN	= 32,	/* Privilege to add or remove VLANs */

I assume these two apply to RX filtering of the VF itself.  How about
control over TX filtering?

> +	IFLA_VF_PRIVILEGE_DEV_CFG = 64,	/* Unrestricted admin access privlege */

Does that include all the other privileges, or does it mean 'everything
else'?

> +	IFLA_VF_PRIVILEGE_SECURE = 128,	/* Privilege to access secure content */

What does that mean?

> +	__IFLA_VF_PRIVILEGE_MAX,
> +};
> +
> +#define IFLA_VF_PRIVILEGE_MAX (__IFLA_VF_PRIVILEGE_MAX - 1)
[...]

This doesn't seem to make sense for an enumeration of flags.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
