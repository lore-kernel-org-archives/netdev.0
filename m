From: David Miller <davem@davemloft.net>
Subject: Re: [v3 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Fri, 25 Sep 2015 12:48:48 -0700 (PDT)
Message-ID: <20150925.124848.1041664902815491015.davem@davemloft.net>
References: <1443106819-5549-1-git-send-email-madalin.bucur@freescale.com>
	<1443106819-5549-3-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, scottwood@freescale.com,
	igal.liberman@freescale.com, roy.pledge@freescale.com,
	ppc@mindchasers.com, joe@perches.com, pebolle@tiscali.nl,
	joakim.tjernlund@transmode.se, f.fainelli@gmail.com, stsp@list.ru
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443106819-5549-3-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@freescale.com>
Date: Thu, 24 Sep 2015 18:00:13 +0300

> +#define DPA_NAPI_WEIGHT		64

This is just the default, so simply use "NAPI_POLL_WEIGHT" rather
than defining your own macro unnecessarily for this.

> +static int dpa_eth_priv_stop(struct net_device *net_dev)
> +{
> +	int err;
> +	struct dpa_priv_s *priv;
> +
> +	err = dpa_stop(net_dev);
> +	/* Allow NAPI to consume any frame still in the Rx/TxConfirm
> +	 * ingress queues. This is to avoid a race between the current
> +	 * context and ksoftirqd which could leave NAPI disabled while
> +	 * in fact there's still Rx traffic to be processed.
> +	 */
> +	usleep_range(5000, 10000);

A wait never fixes a race.  Instead you must use appropriate mutual
exclusion mechanisms to ensure that NAPI is really completed it's
run, and we definitely have a means by which to do that properly.

> +	net_dev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +		NETIF_F_LLTX);

This second line should start exactly at the first column after the
openning parenthesis of the first line.
