From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Mon, 16 Aug 2010 21:59:39 +0200
Message-ID: <201008162159.39734.arnd@arndb.de>
References: <cover.1281956490.git.richard.cochran@omicron.at> <201008161626.24083.arnd@arndb.de> <20100816190003.GB4166@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	Rodolfo Giometti <giometti@linux.it>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:60180 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab0HPUAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 16:00:13 -0400
In-Reply-To: <20100816190003.GB4166@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 16 August 2010 21:00:03 Richard Cochran wrote:
> 
> On Mon, Aug 16, 2010 at 04:26:23PM +0200, Arnd Bergmann wrote:
> > Have you considered integrating the subsystem into the Posix clock/timer
> > framework?
> 
> Yes, but see below.
>  
> > I can't really tell from reading the source if this is possible or
> > not, but my feeling is that if it can be done, that would be a much
> > nicer interface. We already have clock_gettime/clock_settime/
> > timer_settime/... system calls, and while you'd need to add another
> > clockid and some syscalls, my feeling is that it will be more
> > usable in the end.
> 
> You are not the first person to ask about this. See this link for
> longer explanation of why I did not go that way:
> 
>   http://marc.info/?l=linux-netdev&m=127669810232201&w=2
> 
> You could offer the PTP clock as a Linux clock source/event device,
> and I agree that it would be nicer. However, the problem is, what do
> you do with the PHY based clocks?  Just one 16 bit read from a PHY
> clock can take 40 usec, and you need four such read operations just to
> get the current time value.

Why does it matter how long it takes to read the clock? I wasn't thinking
of replacing the system clock with this, just exposing the additional
clock as a new clockid_t value that can be accessed using the existing
syscalls.

> Also, I really did not want to add or change any syscalls. I could not
> see a practical way to extend the existing syscalls to accommodate PTP
> clocks.

Why did you not want to add syscalls? Adding ioctls instead of syscalls
does not make the interface better, just less visible.

Out of the ioctl commands you define, we already seem to have half or more:

PTP_CLOCK_APIVERS -> not needed
PTP_CLOCK_ADJFREQ -> new clock_adjfreq
PTP_CLOCK_ADJTIME -> new clock_adjtime
PTP_CLOCK_GETTIME -> clock_gettime
PTP_CLOCK_SETTIME -> clock_settime
PTP_CLOCK_GETCAPS -> new clock_getcaps
PTP_CLOCK_GETTIMER -> timer_gettime
PTP_CLOCK_SETTIMER -> timer_create/timer_settime
PTP_FEATURE_REQUEST -> possibly clock_feature

	Arnd
