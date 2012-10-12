From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v2 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Fri, 12 Oct 2012 12:03:29 -0400
Message-ID: <20121012160329.GQ12330@titan.lakedaemon.net>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <20121011212629.GA14171@electric-eye.fr.zoreil.com>
 <20121012143131.GP12330@titan.lakedaemon.net>
 <20121012165919.0dd085dd@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Rami Rosen <rosenr@marvell.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Maen Suleiman <maen@marvell.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-04-ewr.mailhop.org ([204.13.248.74]:37086 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752637Ab2JLQDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 12:03:41 -0400
Content-Disposition: inline
In-Reply-To: <20121012165919.0dd085dd@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 04:59:19PM +0200, Thomas Petazzoni wrote:
> Jason,
> 
> On Fri, 12 Oct 2012 10:31:31 -0400, Jason Cooper wrote:
> 
> > I agree with Francois on most of these.  I prefer readability over
> > hard 80 column limits.
> 
> Sure, but checkpatch.pl is warning on every line exceeding the 80
> columns. Not that I think that all checkpatch.pl warnings should
> necessarily be religiously respected, but if you have gazillions of
> warnings regarding line exceeding 80 columns, it is very likely that
> you will miss more important warnings.

./scripts/checkpatch.pl --ignore LONG_LINE ...

Will yield the 'more important' warnings/errors.  After those are
cleared, you can run without --ignore to check for over-indentation,
etc.

> > Although, 80 columns is still sound
> > guidance.  For example, a majority of the broken lines are due to
> > long macro and constant names.  I did a 'git grep NETA' and didn't
> > see anything alarming.  So, above could become
> > 
> > 			val |= rx_filled << NETA_RXQ_ADD_NONOCC_SHIFT;
> 
> I don't mind, but then I would like to keep things consistent:
> 
>  * The driver file would be neta.c
> 
>  * All functions and data structure would be prefixed neta_ and not
>    mvneta_
> 
>  * The Kconfig option would become CONFIG_NETA. Do we really want such
>    a "simple" Kconfig option name for a driver?

Well, you could do mv_neta.c and CONFIG_MV_NETA, but at the end of the
day, we were both trying to put lipstick on a pig.  Your last paragraph
is the most important.

> Maybe the fact that those long macros are making long lines is also due
> to the code having sometimes a too deep indentation, and I need to fix
> that by using more auxiliary functions or something like that?

This is the intent of the 80 column warning.  Please review the patch
for over-indentation, and consider shortening the macros, eg
MVNETA_RXQ_ADD_NONOCC_SHFT.

thx,

Jason.
