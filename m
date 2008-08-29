From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1 net-2.6] Re-enable IP when MTU > 68
Date: Fri, 29 Aug 2008 16:05:08 +0100
Message-ID: <20080829150506.GO7908@solarflare.com>
References: <48B80D6B.5030007@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Lorandi <rafaello@br.ibm.com>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:40801 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750725AbYH2PFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 11:05:19 -0400
Content-Disposition: inline
In-Reply-To: <48B80D6B.5030007@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno Leitao wrote:
[...]
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 91d3d96..758b4f6 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1048,6 +1048,10 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
>  				IN_DEV_CONF_SET(in_dev, NOXFRM, 1);
>  				IN_DEV_CONF_SET(in_dev, NOPOLICY, 1);
>  			}
> +		} else if (event == NETDEV_CHANGEMTU) {
> +			/* Re-enabling IP */
> +			if (dev->mtu > 68)
[...]

Should be >= to match the other tests.  And it would really be cleaner to
use something like

	static inline bool inetdev_valid_mtu(unsigned mtu)
	{
		return mtu >= 68;
	}

rather than repeating the magic number.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
