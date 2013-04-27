From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Sat, 27 Apr 2013 11:05:45 +0200
Message-ID: <20130427090545.GY1366@pengutronix.de>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
 <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
 <20130426134415.GS1366@pengutronix.de>
 <20130426.143309.1011152996477262852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: r.schwebel@pengutronix.de, lznuaa@gmail.com,
	l.stach@pengutronix.de, netdev@vger.kernel.org,
	Frank.Li@freescale.com, festevam@gmail.com, shawn.guo@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49670 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000Ab3D0JFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 05:05:50 -0400
Content-Disposition: inline
In-Reply-To: <20130426.143309.1011152996477262852.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 26, 2013 at 02:33:09PM -0400, David Miller wrote:
> From: Robert Schwebel <r.schwebel@pengutronix.de>
> Date: Fri, 26 Apr 2013 15:44:15 +0200
>
> > Seriously - it's friday, and 3.9 is expected to come out this
> > weekend.
>
> Seriously, it took you how long to notice the breakage and report
> it in sufficient detail for the author to make an attempt at a fix?
>
> I thnk Frank's request is reasonable given the circumstances, please
> work closely with him on the fix.

The FEC driver has worked fine in 3.8.x.

Frank's patches for the 3.9 cycle...

- remove locking in a way that memory is freed which is in use
- break the driver, up to a point where the kernel oopses when the link
  goes away
- mix up different changes (queue handling) and should have been split up
  into separate patches

Unfortunately, the breakage happens only on multicore (MX6Q) and if you
change the link status; that's probably the reason why it hasn't been
noticed earlier.

We have really tried to find a "quick fix which does it right", but it
has turned out that this isn't possible in such a short time, because it
is more complex than just re-adding locks. We feel that the results of
last week's activities are not good enough that they could be merged
without further breakage.

Please consider to merge the reverts. Otherwhise FEC will be broken in 3.9.

Of course, we can help with a real solution, but please after 3.9.final.

Thanks,
Robert
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
