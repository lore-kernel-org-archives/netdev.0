From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: Driver SFC: Possible bug in LM87 temperature XFP detection code
Date: Tue, 28 Apr 2009 14:44:04 +0000
Message-ID: <1240929844.10689.35.camel@localhost.localdomain>
References: <1240911369.10689.20.camel@localhost.localdomain>
	 <1240925799.3200.16.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56827 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505AbZD1OoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 10:44:06 -0400
In-Reply-To: <1240925799.3200.16.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-28 at 14:36 +0100, Ben Hutchings wrote:
> On Tue, 2009-04-28 at 11:36 +0200, Jesper Dangaard Brouer wrote:
> > Hi Ben,
> > 
> > I have borrowed some SMC10GPCIe-XFP NICs directly from SMC for
> > evaluation.  The NICs uses a Solarflare Chip and the SFC driver.
> > 
> > If unpluging the fiber cable I start getting these errors:
> > 
> > +--------
> >  sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status 30:00) INTERNAL EXTERNAL
> >  sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting down PHY
> > 
> >  sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status 30:00) INTERNAL EXTERNAL
> >  sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting down PHY
> > 
> >  sfc 0000:12:00.0: ERR: eth88 LM87 detected a hardware failure (status 10:00) INTERNAL
> >  sfc 0000:12:00.0: ERR: eth88 Board sensor reported fault; shutting down PHY
> > +---------
> > 
> > Reading through the driver code (drivers/net/sfc/boards.c), this problem
> > is related to temperature.
> 
> Right.  And the sensors are not polled while the link is up, on the
> assumption that a temperature or voltage fault will cause the link to go
> down, and because bit-banged I2C will reduce throughput slightly.

In my situation the link does not go down due the temperature issue.


> > The real issues is that I cannot get the device up and running again
> > after lowering the temperature.  Only if I unload and load the sfc
> > driver, then I can get the device running again.
> > 
> > I'm thinking perhaps there is missing a PHY power up again, after the
> > temperature alarm has gone?
> 
> We considered it most important to shut down the board to prevent or
> mitigate damage, and did not implement any recovery beyond that.

Im my case putting the PHY in PHY_MODE_LOW_POWER, does not help lowering
the temperature.  The errors are continous, until I apply "manual"
airflow ;-)


> > I'm using kernel 2.6.30-rc1-net-next-00664-gd93fe1a.
> > 
> > 
> > To Ben; do you have anything you want me to try. Do you want to fix this
> > you self, or can you give me some code hints or patches to try out?
> 
> I don't intend to fix this myself.  If you want to try implementing this
> then you should start by looking at efx_monitor() in efx.c.  However, I
> think your time might be better spent in fixing the air flow in the
> computer before the board is permanently damaged.

I see you point, I don't want to damage the board... not sure I want to
fix it then... Although in a production environment, I think the driver
should support exchanging a failed XFP without rebooting the server.

Then I also think that we should make the error message a bit more
explicit, in order to warn people before the board is permanently
damaged.  I'll post a patch proposal as reply to this message...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

