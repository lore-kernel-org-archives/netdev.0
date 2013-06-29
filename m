From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Fri, 28 Jun 2013 21:16:32 -0700 (PDT)
Message-ID: <20130628.211632.1064715548223073397.davem@davemloft.net>
References: <51CB05BB.3030909@xdin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, joe@perches.com,
	jboticario@gmail.com, balferreira@googlemail.com
To: arvid.brodin@xdin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795Ab3F2EQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 00:16:33 -0400
In-Reply-To: <51CB05BB.3030909@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@xdin.com>
Date: Wed, 26 Jun 2013 17:16:11 +0200

> +static int hsr_dev_open(struct net_device *dev)
> +{
> +	struct hsr_priv *hsr_priv;
> +
> +	hsr_priv = netdev_priv(dev);
> +
> +	if (hsr_priv->slave[0])
> +		dev_open(hsr_priv->slave[0]);
> +	if (hsr_priv->slave[1])
> +		dev_open(hsr_priv->slave[1]);
> +
> +	return 0;
> +}

dev_open() can and does fail, you must thus check for error returns, undo any
necessary state, and propagate that error to callers of hsr_dev_open.
