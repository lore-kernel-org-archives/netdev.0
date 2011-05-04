From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Thu, 5 May 2011 01:28:54 +0200
Message-ID: <20110504232854.GA11687@rere.qmqm.pl>
References: <20110504181813.GA17547@redhat.com>
 <20110504223415.GA14819@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43209 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932101Ab1EDX2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 19:28:55 -0400
Content-Disposition: inline
In-Reply-To: <20110504223415.GA14819@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2011 at 08:34:15AM +1000, Herbert Xu wrote:
> On Wed, May 04, 2011 at 09:18:14PM +0300, Michael S. Tsirkin wrote:
> > BTW, I just noticed that net-next spits out
> > many of the following when I run any VMs:
> >=20
> > tap0: Dropping NETIF_F_SG since no checksum feature.
> > tap0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Features changed: 0x401b4849 -> 0x40004040
> > device msttap0 entered promiscuous mode
> > br0: Dropping NETIF_F_GSO since no SG feature.
> > br0: port 1(msttap0) entering forwarding state
> > br0: port 1(msttap0) entering forwarding state
> > tap0: Features changed: 0x40004040 -> 0x40024849
> > tap0: Dropping NETIF_F_SG since no checksum feature.
> > tap0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Features changed: 0x40024849 -> 0x40004040
> > br0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Dropping NETIF_F_SG since no checksum feature.
> > tap0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Dropping NETIF_F_SG since no checksum feature.
> > tap0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Dropping NETIF_F_SG since no checksum feature.
> > tap0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Dropping NETIF_F_SG since no checksum feature.
> > tap0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Features changed: 0x40004040 -> 0x401b4849
> > tap0: Dropping NETIF_F_SG since no checksum feature.
> > tap0: Dropping NETIF_F_GSO since no SG feature.
> > tap0: Features changed: 0x401b4849 -> 0x40004040
> > br0: Dropping NETIF_F_GSO since no SG feature.
> >=20
> > My problem is not primarily with warnings:
> >=20
> > will that linearize all packets and disable GSO
> > for tap and bridge? If yes it can't be good
> > for performance...
> I think so.  So the question is why is checksum off?

Whatever application is creating the tap0 device is not calling
ioctl(TUNSETOFFLOAD) with TUN_F_CSUM set. This is userspace bug/feature
exposed by recent changes to netdev features handling.

Best Regards,
Micha=B3 Miros=B3aw
