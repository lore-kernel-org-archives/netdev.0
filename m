From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Linux Device Driver for Xilinx LL TEMAC 10/100/1000 Ethernet NIC
Date: Mon, 18 Aug 2008 15:36:51 +0100
Message-ID: <20080818143649.GD7908@solarflare.com>
References: <48A7B01C.2070403@dlasys.net> <20080818123056.GA7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-embedded <linuxppc-embedded@ozlabs.org>,
	netdev@vger.kernel.org
To: "David H. Lynch Jr." <dhlii@dlasys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:41935 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753022AbYHROgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 10:36:53 -0400
Content-Disposition: inline
In-Reply-To: <20080818123056.GA7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wrote:
> > +static struct net_device_stats *
> > +temac_get_stats(struct net_device *ndev)
> > +{
> > +    return netdev_priv(ndev);
> 
> Not even the right type.  Do you read your compiler warnings?

Sorry, I now see that this is correct, though it's very fragile - it will
silently break if struct temac_local is reordered.

struct net_device includes a stats buffer which you should be able to use
instead of adding your own in struct temac_local.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
