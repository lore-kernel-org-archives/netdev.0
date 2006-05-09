From: Pavel Roskin <proski@gnu.org>
Subject: Re: dBm cutoff at -1dBm is too low
Date: Tue, 09 May 2006 00:54:55 -0400
Message-ID: <1147150495.4453.65.camel@dv>
References: <1146760665.5294.65.camel@dv>
	 <20060505172818.GA7543@bougret.hpl.hp.com> <1146972732.24434.89.camel@dv>
	 <20060508171711.GA10948@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:33998 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751372AbWEIEzD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 00:55:03 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FdKFS-0002n5-AN
	for netdev@vger.kernel.org; Tue, 09 May 2006 00:55:02 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060508171711.GA10948@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-08 at 10:17 -0700, Jean Tourrilhes wrote:
> > But shouldn't you trust the drivers using IW_QUAL_DBM, whether the value
> > is positive or negative?
> 
> 	You can't remove the test, making the rest pointeless. Old
> style driver never used the flags, new style driver that don't report
> dBm will never use the flags, and there is not way to dinstinguish
> both, apart from the 'sign' of the value.

I used "new style driver" as synonymous to the driver using IW_QUAL_DBM
and "old style driver" as the one that doesn't use IW_QUAL_DBM.

I don't think any drivers need to specify both dBm and non-dBm data for
the same device.

Drivers that give non-dBm data are already well served by wireless
tools.  They don't need to change.

Drivers that give dBm data had to limit the data to avoid its
misinterpretation as non-dBm data.  Now IW_QUAL_DBM is supposed to free
drivers from such checks.  But it doesn't deliver its promise, because
the data can still be misinterpreted, just is a different way.  Namely,
a strong signal (0dBm) can be interpreted as an incredibly weak signal
(-256dBm).  That's what I want to see fixed.

One tricky case would be when the driver sets the max signal e.g. to 30
and reports 35 (i.e. a positive value within the "reasonable" dBm
range).  I would probably prefer to show it as 30/30 rather than 35dBm,
but the driver is nuts anyway, and I'm not really concerned about it to
write an extra line of code.

-- 
Regards,
Pavel Roskin

