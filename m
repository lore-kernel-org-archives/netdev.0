From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH v2 1/3] Added kernel support in EEE Ethtool
 commands
Date: Wed, 6 Jun 2012 16:20:11 +0100
Message-ID: <1338996011.2836.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338973098-16439-1-git-send-email-yuvalmin@broadcom.com>
	 <1338973098-16439-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eilong@broadcom.com>, <peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6933 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756560Ab2FFPUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 11:20:18 -0400
In-Reply-To: <1338973098-16439-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 11:58 +0300, Yuval Mintz wrote:
> This patch extends the kernel's ethtool interface by adding support
> for 2 new EEE commands - get_eee and set_eee.
> 
> Thanks goes to Giuseppe Cavallaro for his original patch adding this support.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  include/linux/ethtool.h |   32 ++++++++++++++++++++++++++++++++
>  net/core/ethtool.c      |   40 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 72 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index e17fa71..6250e1f 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -137,6 +137,32 @@ struct ethtool_eeprom {
>  };
>  
>  /**
> + * struct ethtool_eee - Energy Efficient Ethernet information
> + * @cmd: ETHTOOL_{G,S}EEE
> + * @supported: Link speeds for which there is eee support.
> + * @advertised: Link speeds the interface advertises (AN) as eee capable.
> + * @lp_advertised: Link speeds the link partner advertised as eee capable.

And these are bitmasks of SUPPORTED_* & ADVERTISED_* flags, right?
Maybe 'link modes' not 'link speeds'?

Otherwise, this all looks good to me (with limited knowledge of EEE).

Ben.

> + * @eee_active: Result of the eee auto negotiation.
> + * @eee_enabled: EEE configured mode (enabled/disabled).
> + * @tx_lpi_enabled: Whether the interface should assert its tx lpi, given
> + *	that eee was negotiated.
> + * @tx_lpi_timer: Time in microseconds the interface delays prior to asserting
> + *	its tx lpi (after reaching 'idle' state). Effective only when eee
> + *	was negotiated and tx_lpi_enabled was set.
> + */
> +struct ethtool_eee {
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
