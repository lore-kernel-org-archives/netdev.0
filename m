From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH] ARCNET: fix hard_header_len limit
Date: Wed, 16 Sep 2015 14:47:13 +0200
Message-ID: <20150916124713.GA18173@pengutronix.de>
References: <20150805153451.GB20781@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33851 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbbIPMrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 08:47:17 -0400
Content-Disposition: inline
In-Reply-To: <20150805153451.GB20781@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2015 at 05:34:51PM +0200, Michael Grzeschik wrote:
> On Thu, Jul 30, 2015 at 11:16:36AM -0700, David Miller wrote:
> > From: Michael Grzeschik <m.grzeschik@pengutronix.de>
> > Date: Thu, 30 Jul 2015 15:34:36 +0200
> > 
> > > The commit <9c7077622dd9> ("packet: make packet_snd fail on len smaller
> > > than l2 header") adds the check for minimum packet length of the used l2.
> > > For arcnet the hardware header length is not the complete archdr which
> > > includes hard + soft header. This patch changes the length to
> > > sizeof(arc_hardware).
> > > 
> > > Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> > 
> > The hard header len is used for other purposes as well, are you sure
> > those don't get broken by this change?
> 
> Its meaning is to represent the amount of the hardware (link layer)
> data of one packet.
> 
> Which other purposes do you mean?
> Can you point to some code?
> 
> > Code assumes that if the data at the SKB mac pointer is taken, for
> > dev->hard_header_len bytes, that is exactly the link layer header.
> > And that this can be used to compare two MAC headers, copy the
> > MAC header from one packet to another, etc.
> 
> The link layer size of arcnet is 4 bytes long. 1 byte source, 1 byte
> dest and two offset bytes. As described by struct arc_hardware in
> if_arcnet.h . The above condition is fulfilled when the mac pointer
> is 0.
> 
> The following pending bytes of struct archdr have a variable meaning
> depending of the used protocol and are represented by an union.
> (network layer)
> 
> In the case of raw packets, the payload comes immediately after the
> hard_header.
> 

Ping!

I have the cleanup patches from Joe Perches and several ARCNET patches
on top, waiting to be posted on the list. What is your Opinion to my
Maintainer Request I send some weeks ago?

Michael

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
