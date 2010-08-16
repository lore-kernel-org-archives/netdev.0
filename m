From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Mon, 16 Aug 2010 21:00:03 +0200
Message-ID: <20100816190003.GB4166@riccoc20.at.omicron.at>
References: <cover.1281956490.git.richard.cochran@omicron.at>
 <363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
 <201008161626.24083.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64847 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319Ab0HPS7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 14:59:43 -0400
Content-Disposition: inline
In-Reply-To: <201008161626.24083.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 16, 2010 at 04:26:23PM +0200, Arnd Bergmann wrote:
> Have you considered integrating the subsystem into the Posix clock/timer
> framework?

Yes, but see below.
 
> I can't really tell from reading the source if this is possible or
> not, but my feeling is that if it can be done, that would be a much
> nicer interface. We already have clock_gettime/clock_settime/
> timer_settime/... system calls, and while you'd need to add another
> clockid and some syscalls, my feeling is that it will be more
> usable in the end.

You are not the first person to ask about this. See this link for
longer explanation of why I did not go that way:

  http://marc.info/?l=linux-netdev&m=127669810232201&w=2

You *could* offer the PTP clock as a Linux clock source/event device,
and I agree that it would be nicer. However, the problem is, what do
you do with the PHY based clocks?  Just one 16 bit read from a PHY
clock can take 40 usec, and you need four such read operations just to
get the current time value.

Also, I really did not want to add or change any syscalls. I could not
see a practical way to extend the existing syscalls to accommodate PTP
clocks.

Richard
