From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: Re: [PATCH] PS3: gelic: convert to net_device_ops
Date: Fri, 16 Jan 2009 16:09:53 +0900
Message-ID: <20090116160550.0B62.40F06B3A@sm.sony.co.jp>
References: <20090116134050.0B5B.40F06B3A@sm.sony.co.jp> <20090115220708.6a246ff1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Geoff Levand <geoffrey.levand@am.sony.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms6.Sony.CO.JP ([211.125.136.204]:35157 "EHLO ms6.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754329AbZAPHKG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 02:10:06 -0500
In-Reply-To: <20090115220708.6a246ff1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 15 Jan 2009 22:07:08 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Fri, 16 Jan 2009 13:57:15 +0900
> Masakazu Mokuno <mokuno@sm.sony.co.jp> wrote:
> 
> > Convert the gelic driver to net_device_ops
> > 
> > Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> > ---
> >  drivers/net/ps3_gelic_net.c |   23 +++++++++++++----------
> >  1 file changed, 13 insertions(+), 10 deletions(-)
> > 
> > --- a/drivers/net/ps3_gelic_net.c
> > +++ b/drivers/net/ps3_gelic_net.c
> > @@ -1403,6 +1403,18 @@ void gelic_net_tx_timeout(struct net_dev
> >  		atomic_dec(&card->tx_timeout_task_counter);
> >  }
> >  
> > +static const struct net_device_ops gelic_netdevice_ops = {
> > +	.ndo_open = gelic_net_open,
> > +	.ndo_stop = gelic_net_stop,
> > +	.ndo_start_xmit = gelic_net_xmit,
> > +	.ndo_set_multicast_list = gelic_net_set_multi,
> > +	.ndo_change_mtu = gelic_net_change_mtu,
> > +	.ndo_tx_timeout = gelic_net_tx_timeout,
> > +#ifdef CONFIG_NET_POLL_CONTROLLER
> > +	.ndo_poll_controller = gelic_net_poll_controller,
> > +#endif
> >
> 
> You probably want to add:
> 	.ndo_change_mtu		= eth_change_mtu,
> 	.ndo_set_mac_address 	= eth_mac_addr,
> 	.ndo_validate_addr	= eth_validate_addr,

Thanks!

I'll respin.

-- 
Masakazu Mokuno

