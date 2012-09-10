From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 5/8] stmmac: get/set coalesce parameters via
 ethtool
Date: Mon, 10 Sep 2012 17:45:10 +0100
Message-ID: <1347295510.2823.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <1347262689-21251-1-git-send-email-peppe.cavallaro@st.com>
	 <1347262689-21251-6-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29544 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754778Ab2IJQpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 12:45:16 -0400
In-Reply-To: <1347262689-21251-6-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-10 at 09:38 +0200, Giuseppe CAVALLARO wrote:
> This patch is to get/set the tx/rx coalesce parameters
> via ethtool interface.
> 
> Tests have been done on several platform with
> different GMAC chips w/o w/ RX watchdog feature.
[...]
> +static int stmmac_set_coalesce(struct net_device *dev,
> +			       struct ethtool_coalesce *ec)
> +{
> +	struct stmmac_priv *priv = netdev_priv(dev);
> +	unsigned int rx_riwt;
> +
> +	/* No rx interrupts will be generated if both are zero */
> +	if (ec->rx_coalesce_usecs == 0)
> +		return -EINVAL;
> +
> +	/* No tx interrupts will be generated if both are zero */
> +	if ((ec->tx_coalesce_usecs == 0) &&
> +	    (ec->tx_max_coalesced_frames == 0))
> +		return -EINVAL;
> +
> +	if ((ec->tx_coalesce_usecs > STMMAC_COAL_TX_TIMER) ||
> +	    (ec->tx_max_coalesced_frames > STMMAC_TX_MAX_FRAMES))
> +		return -EINVAL;
[...]

You should also check that the settings you don't support
(rx_max_coalesced_frames, use_adaptive_rx_coalesce,
use_adaptive_tx_coalesce, *_irq) are equal to 0.  (This isn't done
consistently in all drivers - but I believe best practice is to reject
rather than quietly ignoring settings you don't support.)

I don't have time to review the other changes properly, but at a quick
look they seem to be OK.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
