From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 13:41:13 -0700
Message-ID: <1282596073.3111.373.camel@localhost.localdomain>
References: <cover.1282550649.git.richard.cochran@omicron.at>
	 <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at>
	 <201008231457.26690.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:56798 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab0HWUlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 16:41:19 -0400
In-Reply-To: <201008231457.26690.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-23 at 14:57 +0200, Arnd Bergmann wrote:
> On Monday 23 August 2010, Richard Cochran wrote:
> > A new syscall is introduced that allows tuning of a POSIX clock. The
> > syscall is implemented for four architectures: arm, blackfin, powerpc,
> > and x86.
> > 
> > The new syscall, clock_adjtime, takes two parameters, a frequency
> > adjustment in parts per billion, and a pointer to a struct timespec
> > containing the clock offset. If the pointer is NULL, a frequency
> > adjustment is performed. Otherwise, the clock offset is immediately
> > corrected by skipping to the new time value.
> 
> It looks well-implemented, and seems to be a reasonable extension
> to the clock API. I'm looking forward to your ptp patches on top
> of this to see how it all fits together.
> 
> For new syscalls, it's best to take linux-api on Cc. I also added
> John, since he participated in the discussion.

As I mentioned in the previous mail, I agree the new functionality
(adjusting the time by an offset instantaneously) is useful, but I'd
prefer it be done initially within the existing adjtimex() interface.

Then if the posix-time clock_id multiplexing version of adjtimex is
found to be necessary, the new syscall should be introduced, using the
same API (not all clock_ids need to support all the adjtimex modes, but
the new interface should be sufficient for NTPd to use).


There are some other conceptual issues this new syscall introduces:

1) While clock_adjtimex(CLOCK_REALTIME,...) would be equivalent to
adjtimex(), would clock_adjtimex(CLOCK_MONOTONIC,...) make sense? 

Given CLOCK_MONOTONIC and CLOCK_REALTIME are both based off the same
notion of time, but offset from each other, any adjustment to one clock
would be reflected in the other. However, the API would make it seem
like they could be adjusted independently.

2) The same issue in #1 exists for CLOCK_REALTIME/MONOTONIC_COARSE
variants. 

3) Freq steering for MONOTONIC_RAW would defeat the purpose of the
clock_id.

4) Does adjustments to CPU_TIME clock_ids make sense?

I'm guessing "no" is the right call to all of the above, but am
interested if others see it differently.

thanks
-john


