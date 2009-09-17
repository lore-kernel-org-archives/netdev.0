From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ks8851_ml ethernet network driver
Date: Wed, 16 Sep 2009 21:07:02 -0700
Message-ID: <20090916210702.617b5069@s6510>
References: <20090917023836.GA15260@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Choi@kroah.com, David <David.Choi@Micrel.Com>,
	Jeff Garzik <jgarzik@redhat.com>
To: Greg KH <greg@kroah.com>, "Li, Charles" <Charles.Li@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52156 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979AbZIQEHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 00:07:04 -0400
In-Reply-To: <20090917023836.GA15260@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Sep 2009 19:38:36 -0700
Greg KH <greg@kroah.com> wrote:

> +
> +/**
> + * ks_net_open - open network device
> + * @netdev: The network device being opened.
> + *
> + * Called when the network device is marked active, such as a user executing
> + * 'ifconfig up' on the device.
> + */
> +static int ks_net_open(struct net_device *netdev)
> +{
> +	struct ks_net *ks = netdev_priv(netdev);
> +	int err;
> +
> +#define	KS_INT_FLAGS	(IRQF_DISABLED|IRQF_TRIGGER_LOW)
> +	/* lock the card, even if we may not actually do anything
> +	 * else at the moment.
> +	 */
> +	mutex_lock(&ks->lock);
> +

I don't understand the purpose of ks->lock mutex. What is it
really protecting? open/close are already protected by rtnl_mutex,
is it really only for the PHY?
