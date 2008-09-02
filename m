From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: forcedeth: option to disable 100Hz timer
Date: Tue, 2 Sep 2008 09:11:26 -0700
Message-ID: <20080902091126.232ee570@extreme>
References: <fa.zbmDQFBw5U2qR0I4VSAlvj/j2ek@ifi.uio.no>
	<48BC8BC8.4030308@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Robert Hancock <hancockr@shaw.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33479 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597AbYIBQL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 12:11:28 -0400
In-Reply-To: <48BC8BC8.4030308@shaw.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Sep 2008 18:41:44 -0600
Robert Hancock <hancockr@shaw.ca> wrote:

> Mikhail Kshevetskiy wrote:
> > On some hardware no TX done interrupts are generated, thus special
> > 100Hz timer interrupt is required to handle this situation properly.
> > Other device do not require that timer interrupt feature.
> > 
> > Patch add a "disable_timerirq" option to disable interrupt timer 
> > mentioned above. This may be extremely usefull for laptop users.
> > 
> > Mikhail Kshevetskiy
> > 
> 
> Someone (ideally NVIDIA) should really find out what hardware actually 
> requires this timer IRQ and only set the flag on those chipsets rather 
> than blindingly setting it on everything. This patch would be useful to 
> test whether a chipset does need it, however.

Some drivers run without TX done interrupts at all. It can be done, it just
requires cleaning up the ring in the start of the next transmit, and starting
a longer interval timer to cleanup leftover frames at the end of a burst.
