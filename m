From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 4/7] [PATCH 4/8] can: Driver for the SJA1000 CAN
 controller
Date: Fri, 15 May 2009 14:39:27 -0600
Message-ID: <20090515143927.7ba06f10@bike.lwn.net>
References: <20090512092757.048938233@denx.de>
	<20090512092757.756749047@denx.de>
	<20090513155205.4bf06c25@bike.lwn.net>
	<4A0BDE79.4060606@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vena.lwn.net ([206.168.112.25]:47079 "EHLO vena.lwn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958AbZEOUj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2009 16:39:27 -0400
In-Reply-To: <4A0BDE79.4060606@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 May 2009 11:03:53 +0200
Wolfgang Grandegger <wg@grandegger.com> wrote:

> > So you're still using the "put the higher-level structure at the top so we
> > can treat it like either kind of pointer" trick.  I'd still recommend
> > against that.  Far better to do something like:
> > 
> > 	struct can_priv *canpriv = netdev_priv(dev);
> > 	struct sja_1000_priv *priv = container_of(canpriv, struct sja_1000_priv, can);
> > 
> > Of course, you can put that dance into a helper function.  
> 
> There is no way to initialize the value returned by netdev_priv() as it
> does not point to a member of struct net_device. I already commented here:
> 
>   http://marc.info/?l=linux-netdev&m=124120212106891&w=2
> 
> Have I missed something?

I'm confused.  It points to the struct can_priv that you registered at
the beginning.  Since that structure is contained within struct
sja1000_priv, you can use container_of(), as described above, to get
it.

I would probably just write something like:

static inline struct sja1000_priv *to_sja1000_priv(struct net_device *dev)
{
	return container_of(netdev_priv(dev), struct sja1000_priv, can);
}

So have *I* missed something?

jon
