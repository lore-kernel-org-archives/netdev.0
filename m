From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/4 (V3)] stmmac: add the Energy Efficient Ethernet
 support
Date: Thu, 12 Apr 2012 16:32:58 -0400 (EDT)
Message-ID: <20120412.163258.602029261264172098.davem@davemloft.net>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
	<1333704559-11251-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934668Ab2DLUeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 16:34:15 -0400
In-Reply-To: <1333704559-11251-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri,  6 Apr 2012 11:29:17 +0200

> +static int stmmac_ethtool_op_set_eee(struct net_device *dev,
> +				     struct ethtool_value *eee)
> +{
> +	struct stmmac_priv *priv = netdev_priv(dev);
> +
> +	if ((!eee->data) && (priv->eee_enabled)) {
> +		stmmac_disable_eee_mode(priv);
> +		priv->eee_enabled = eee->data;
> +	} else if ((eee->data) && (!priv->eee_enabled))
> +		/* We are asking for enabling the EEE but this
> +		 * has to be verified by invoking the eee_init function.
> +		 * For this reason we cannot set eee_enabled to
> +		 * eee->data, directly. */
> +		priv->eee_enabled = stmmac_eee_init(priv);
> +
> +	return 0;

If stmmac_eee_init() determines that it cannot enable eee, you should
return an appropriate error code here so that ethtool can report that
fact.
