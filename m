From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Thu, 19 May 2011 14:36:30 -0500
Message-ID: <1305833791.3271.31.camel@dcbw.foobar.com>
References: <4DD36803.1020001@neli.hopto.org>
		 <20110518.023725.441358922110721042.davem@davemloft.net>
		 <4DD36E54.9040706@neli.hopto.org>
		 <20110518.181427.1228926976939865196.davem@davemloft.net>
	 <1305819120.3271.3.camel@dcbw.foobar.com> <4DD56E7A.3010901@neli.hopto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Micha Nelissen <micha@neli.hopto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754846Ab1ESTeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 15:34:20 -0400
In-Reply-To: <4DD56E7A.3010901@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-19 at 21:24 +0200, Micha Nelissen wrote:
> Dan Williams wrote:
> > Shouldn't the code still wait at *least* one second?  Not all drivers
> > support carrier detect, and those that don't set the carrier always-on.
> > Thus older devices that used to have 1s to get carrier in line (even if
> > they don't report it) now have only 10ms.
> 
> Btw, it does not matter much, there are 2 cases:
> 1) DHCP: dhcp will retry every few seconds, so if link is not up, then a
> later try will succeed
> 2) Static IP: an ARP request is performed every second, so the second
> request will be answered instead of the first.
> 
> Even if link is "fake up" by driver and not actually up after 10 msecs,
> things will continue to work (eventually), after a second, just like now.

I don't particularly care what happens here, I was simply pointing out
that previous assumptions about older driver behavior are broken by this
patch, and this can cause a change in behavior.  The simplest thing to
do here is to revert only the hunks that change CONF_POST_OPEN, ie set
CONF_POST_OPEN back to 1, and revert the ssleep() -> msleep() bit.  The
rest of it looks fine to me.

But if davem wants to take the patch anyway, that's fine with me too,
since I believe all drivers that don't support carrier detect should be
put out of their misery by a quick bullet to the back of the head at the
end of a dark alley anyway.

Dan


