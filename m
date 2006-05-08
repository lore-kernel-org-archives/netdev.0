From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: dBm cutoff at -1dBm is too low
Date: Mon, 8 May 2006 10:17:11 -0700
Message-ID: <20060508171711.GA10948@bougret.hpl.hp.com>
References: <1146760665.5294.65.camel@dv> <20060505172818.GA7543@bougret.hpl.hp.com> <1146972732.24434.89.camel@dv>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:58335 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S932483AbWEHRRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 13:17:15 -0400
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1146972732.24434.89.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 06, 2006 at 11:32:12PM -0400, Pavel Roskin wrote:
> On Fri, 2006-05-05 at 10:28 -0700, Jean Tourrilhes wrote:
> > 
> > 	There are still quite a few drivers which have not been
> > converted to use IW_QUAL_DBM, so I don't want to drop the backward
> > compatibility yet.
> 
> But shouldn't you trust the drivers using IW_QUAL_DBM, whether the value
> is positive or negative?

	You can't remove the test, making the rest pointeless. Old
style driver never used the flags, new style driver that don't report
dBm will never use the flags, and there is not way to dinstinguish
both, apart from the 'sign' of the value.
	We may want to perform an audit of the various drivers,
in-tree and out-of-tree, to see how much progress we have made so far.

> The problem is the driver has to take care of it.  It cannot just take
> the dBm value from the card and pass it to userspace.  It has to limit
> the value at -1.  Otherwise iwconfig would show -256dBm or something
> like that.  I can imagine that some GUI can decide that the connection
> has become very bad, and that would confuse the user.

	Correct.

> I suggest -192dBm to 63dBm.  That's enough padding on both sides, so
> that the drivers can just pass the firmware value without checking.

	Yep, seems reasonable.

> Pavel Roskin

	Jean
