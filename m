From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: dBm cutoff at -1dBm is too low
Date: Tue, 9 May 2006 11:54:42 -0700
Message-ID: <20060509185442.GA30590@bougret.hpl.hp.com>
References: <1146760665.5294.65.camel@dv> <20060505172818.GA7543@bougret.hpl.hp.com> <1146972732.24434.89.camel@dv> <20060508171711.GA10948@bougret.hpl.hp.com> <1147150495.4453.65.camel@dv>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelbas01.cce.hp.com ([161.114.21.104]:57286 "EHLO
	ccerelbas01.cce.hp.com") by vger.kernel.org with ESMTP
	id S1750886AbWEISyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 14:54:54 -0400
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1147150495.4453.65.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 09, 2006 at 12:54:55AM -0400, Pavel Roskin wrote:
> On Mon, 2006-05-08 at 10:17 -0700, Jean Tourrilhes wrote:
> > > But shouldn't you trust the drivers using IW_QUAL_DBM, whether the value
> > > is positive or negative?
> > 
> > 	You can't remove the test, making the rest pointeless. Old
> > style driver never used the flags, new style driver that don't report
> > dBm will never use the flags, and there is not way to dinstinguish
> > both, apart from the 'sign' of the value.
> 
> I used "new style driver" as synonymous to the driver using IW_QUAL_DBM
> and "old style driver" as the one that doesn't use IW_QUAL_DBM.
> 
> I don't think any drivers need to specify both dBm and non-dBm data for
> the same device.
> 
> Drivers that give non-dBm data are already well served by wireless
> tools.  They don't need to change.
> 
> Drivers that give dBm data had to limit the data to avoid its
> misinterpretation as non-dBm data.  Now IW_QUAL_DBM is supposed to free
> drivers from such checks.  But it doesn't deliver its promise, because
> the data can still be misinterpreted, just is a different way.  Namely,
> a strong signal (0dBm) can be interpreted as an incredibly weak signal
> (-256dBm).  That's what I want to see fixed.

	I hear you 100%. But, before removing the backward
compatibility for old style drivers, we need to make sure all of them
are gone. I don't plan to keep backward compatibility forever, but
just enough to cover the transition.
	Technically, we can't make backward compatibility for old
driver and this proposal to work together, because of the test on the
sign. We need to pick one.

> One tricky case would be when the driver sets the max signal e.g. to 30
> and reports 35 (i.e. a positive value within the "reasonable" dBm
> range).  I would probably prefer to show it as 30/30 rather than 35dBm,
> but the driver is nuts anyway, and I'm not really concerned about it to
> write an extra line of code.

	Agreed.

> Regards,
> Pavel Roskin

	Jean
