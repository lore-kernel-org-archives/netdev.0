From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: Regulator support for smsc911x
Date: Wed, 8 Feb 2012 09:31:41 +0100
Message-ID: <20120208083141.GM3852@pengutronix.de>
References: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
 <CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
 <20120203074408.GD1990@pengutronix.de>
 <20120203111133.GD3151@opensource.wolfsonmicro.com>
 <CAOMZO5B2_yq=m8Mer=iV-HsXvF-MZJ-BV2=LTg1CZN+O=yepSQ@mail.gmail.com>
 <20120207193914.GA31557@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fabio Estevam <festevam@gmail.com>, robert.marklund@stericsson.com,
	netdev@vger.kernel.org, Sascha Hauer <kernel@pengutronix.de>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43116 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756035Ab2BHIbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 03:31:47 -0500
Content-Disposition: inline
In-Reply-To: <20120207193914.GA31557@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2012 at 07:39:14PM +0000, Mark Brown wrote:
> On Tue, Feb 07, 2012 at 05:25:48PM -0200, Fabio Estevam wrote:
> > On Fri, Feb 3, 2012 at 9:11 AM, Mark Brown
> 
> > > There's also options c) set up the regulators for the board and d) don't
> > > enable the regulator API if the board doesn't use regulators.
> 
> > Option c would require that we change every single board.
> 
> Well, yes.
> 
> > The patch below does option d.
> 
> > What do you think?
> 
> Absolutely not.  Putting conditional code like this in drivers is nuts,
> you would have to do the same thing in every single driver which is not
> a useful use of anyone's time.  This is *clearly* a generic thing and
> should therefore be handled in generic code for the same reason we don't
> have driver specific platform data for actual usage of the API.
> 
> Really, anyone who wants this sort of thing should just enable dummy
> regulators - it's exactly what you're implementing.  I'm pretty sure
> your board does actually have power supplies for the chip, you've just
> not told software about them.

Yes, my board also has a supply for the smc911x, it's the same as used
for the CPU...

There is also option e), something I've been thinking about for a while.
Implement a list of resources which can be attached to a device. By
resources I mean regulators, clocks and pinmux for example. A device
would then just call a make_me_work(state) function which iterates over
this list and enables/disables all resources as necessary. This way we
could attach everything we need to a device without cluttering the
driver code like we do today.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
