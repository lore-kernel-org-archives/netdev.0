From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [v2 Patch 1/2] s2io: add dynamic LRO disable support
Date: Wed, 09 Jun 2010 15:00:58 +0100
Message-ID: <1276092058.2093.1.camel@achroite.uk.solarflarecom.com>
References: <20100609100928.6573.14199.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sgruszka@redhat.com,
	herbert.xu@redhat.com, Ramkrishna.Vepa@exar.com,
	davem@davemloft.net
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46969 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128Ab0FIOBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 10:01:03 -0400
In-Reply-To: <20100609100928.6573.14199.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-09 at 06:05 -0400, Amerigo Wang wrote:
[...]
> +static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
> +{
> +	struct s2io_nic *sp = netdev_priv(dev);
> +	int rc = 0;
> +	int changed = 0;
> +
> +	if (data & ETH_FLAG_LRO) {
> +		if (lro_enable) {
> +			if (!(dev->features & NETIF_F_LRO)) {
> +				dev->features |= NETIF_F_LRO;
> +				changed = 1;
> +			}
> +		} else
> +			rc = -EINVAL;
> +	} else if (dev->features & NETIF_F_LRO) {
> +		dev->features &= ~NETIF_F_LRO;
> +		changed = 1;
> +	}
> +
> +	if (changed && netif_running(dev)) {
> +		s2io_stop_all_tx_queue(sp);
> +		s2io_card_down(sp);
> +		sp->lro = dev->features & NETIF_F_LRO;
> +		rc = s2io_card_up(sp);
> +		s2io_start_all_tx_queue(sp);
[...]

Is it safe to call s2io_start_all_tx_queue() if s2io_card_up() failed?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

