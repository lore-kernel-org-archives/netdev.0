From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 1/2] net: Allow changing number of RX
 queues after device allocation
Date: Fri, 24 Sep 2010 13:24:41 +0100
Message-ID: <1285331081.2257.3.camel@achroite.uk.solarflarecom.com>
References: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
	 <1285273194.7794.24.camel@achroite.uk.solarflarecom.com>
	 <1285296505.2380.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:35506 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423Ab0IXMYo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 08:24:44 -0400
In-Reply-To: <1285296505.2380.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-09-24 at 04:48 +0200, Eric Dumazet wrote:
> Le jeudi 23 septembre 2010 =C3=A0 21:19 +0100, Ben Hutchings a =C3=A9=
crit :
> > For RPS, we create a kobject for each RX queue based on the number =
of
> > queues passed to alloc_netdev_mq().  However, drivers generally do =
not
> > determine the numbers of hardware queues to use until much later, s=
o
> > this usually represents the maximum number the driver may use and n=
ot
> > the actual number in use.
> >=20
> > For TX queues, drivers can update the actual number using
> > netif_set_real_num_tx_queues().  Add a corresponding function for R=
X
> > queues, netif_set_real_num_rx_queues().
> >=20
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
>=20
> Seems very good to me, except a minor style issue here :
>=20
> All functions in this file use a single line.
>=20
> > -static int rx_queue_register_kobjects(struct net_device *net)
> > +int
> > +net_rx_queue_update_kobjects(struct net_device *net, int old_num, =
int new_num)
>=20
> ->
>=20
> int net_rx_queue_update_kobjects(struct net_device *net, int old, int=
 new)

Why should I rename variables to fit a function signature on one line?

> Also, I dont understand why we need to restrict
> netif_set_real_num_rx_queues() to lower the count.
> This wastes memory.
>=20
> Why dont we allocate dev->_rx once we know the real count, not in
> alloc_netdev_mq() but in register_netdevice() ?

We probably could do.  I was just being consistent with
netif_set_real_num_tx_queues().

Note that both functions allow changing the number of queues on a
registered device, although I don't think any driver uses this.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

