From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC: netdev: allow ethtool physical id to drop rtnl_lock
Date: Mon, 02 Nov 2009 18:29:39 +0000
Message-ID: <1257186579.2847.24.camel@achroite.uk.solarflarecom.com>
References: <20091030104201.6bb03b23@nehalam> <1257007462.9706.9.camel@HP1>
	 <20091102.001710.209808608.davem@davemloft.net>
	 <20091102085121.7416fa8f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:44905 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932105AbZKBS3i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 13:29:38 -0500
In-Reply-To: <20091102085121.7416fa8f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-02 at 08:51 -0800, Stephen Hemminger wrote:
[...]
> For compatibility, I was thinking of adding a new ethtool hook that
> moves the blinking loop into ethtool.
>
> static int ethtool_phys_blink(struct net_device *dev, u32 secs)
> {
> 	while (secs > 0) {
> 		dev->ethtool_ps->phys_led(dev, ETH_LED_ON);
> ...
> 		dev->ethtool_ps->phys_led(dev, ETH_LED_OFF);
> 	}
> 	dev->ethtool_ops->phys_led(dev, ETH_LED_NORMAL);
> }
[...]

=EF=BB=BFWe could even force this on unconverted drivers, but using a l=
onger
loop period to allow for slow blinking:

static int ethtool_phys_id_loop(struct net_device *dev, u32 secs)
{
	u32 timeout;
	int rc;

	for (;;) {
		timeout =3D min_t(u32, secs, 5);
		secs -=3D timeout;
		rc =3D dev->ethtool_ops->phys_id(dev, timeout);
		if (rc || secs =3D=3D 0)
			return rc;
		...
	}
}

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

