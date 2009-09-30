From: Michael Buesch <mb@bu3sch.de>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Wed, 30 Sep 2009 16:33:02 +0200
Message-ID: <200909301633.04376.mb@bu3sch.de>
References: <200909111648.50902.mb@bu3sch.de> <20090929192928.GF2678@tuxdriver.com> <4AC3475C.7000403@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Kalle Valo <kalle.valo@iki.fi>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:50992 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754203AbZI3OdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 10:33:20 -0400
In-Reply-To: <4AC3475C.7000403@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 September 2009 13:56:12 Oliver Hartkopp wrote:
> John W. Linville wrote:
> > On Sat, Sep 12, 2009 at 06:41:12PM +0200, Oliver Hartkopp wrote:
> > 
> >> i cooked a patch that introduces netif_rx_ti() and fixes up the problems in
> >> mac80211 and the CAN subsystem.
> > 
> > Oliver,
> > 
> > Are you going to send this patch to Dave?  If you want me to carry
> > it instead, please resend it with a proper changelog including a
> > Signed-off-by line.  For that matter, Dave will most certainly want
> > that as well...
> 
> Hello John,
> 
> as i wrote here
> 
> http://marc.info/?l=linux-netdev&m=125277885910179&w=2
> 
> there are currently only three occurrences of checks that use netif_rx() and
> netif_rx_ni() depending on in_interrupt().
> 
> And regarding the suggested fix from Michael, that checked every(!) netif_rx()
> whether it is in interrupt or not, i was unsure if a netif_tx_ti() would make
> sense for only three cases?!?
> 
> If you think it makes sense, i can post a patch for that ... but:
> 
> Indeed it costs some additional investigation to prove whether netif_rx() or
> netif_rx_ni() should be used in each case. But IMHO this has to be done before
> providing a pump-gun function that solves the problem without thinking if we
> are in irq-context or not. I want to avoid that people are using netif_rx_ti()
> as some kind of default ...
> 
> I don't know how expensive in_interrupt() is, but it IMO should be avoided
> when the context for a code section can be determined in another way.

What if we just get the fix merged and discuss later whether it's worth to optimize a picosecond or not??
My patch fixes the _bug_. You can merge a more "efficient" fix later that saves one or two CPU cycles.

-- 
Greetings, Michael.
