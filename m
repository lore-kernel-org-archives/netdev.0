From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 4/4 (v4)] stmmac: add the Energy Efficient
 Ethernet support
Date: Tue, 12 Jun 2012 17:42:27 +0100
Message-ID: <1339519347.2701.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339505153-26731-1-git-send-email-peppe.cavallaro@st.com>
	 <1339505153-26731-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <rayagond@vayavyalabs.com>,
	<davem@davemloft.net>, <yuvalmin@broadcom.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37423 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752838Ab2FLQmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 12:42:33 -0400
In-Reply-To: <1339505153-26731-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-12 at 14:45 +0200, Giuseppe CAVALLARO wrote:
> This patch adds the Energy Efficient Ethernet support to the stmmac.
> 
> Please see the driver's documentation for further details about this support
> in the driver.
[...]
> +static int stmmac_ethtool_op_set_eee(struct net_device *dev,
> +				     struct ethtool_eee *edata)
> +{
> +	struct stmmac_priv *priv = netdev_priv(dev);
> +
> +	priv->eee_enabled = edata->eee_enabled;
> +
> +	if (!priv->eee_enabled)
> +		stmmac_disable_eee_mode(priv);
> +	else {
> +		/* We are asking for enabling the EEE but it is safe
> +		 * to verify all by invoking the eee_init function.
> +		 * In case of failure it will return an error.
> +		 */

It would be better if you could avoid changing any settings in the case
of failure, though.

> +		priv->tx_lpi_timer = edata->tx_lpi_timer;
> +		priv->eee_enabled = stmmac_eee_init(priv);
> +		if (!priv->eee_enabled)
> +			return -EPERM;
[...]

Surely -EOPNOTSUPP?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
