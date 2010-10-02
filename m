From: "M. Warner Losh" <imp@bsdimp.com>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Fri, 01 Oct 2010 19:44:50 -0600 (MDT)
Message-ID: <20101001.194450.1113329769525619655.imp@bsdimp.com>
References: <20100923223417.4ed62e5b@lxorguk.ukuu.org.uk>
	<4C9BC7CE.8020400@riesch.at>
	<alpine.DEB.2.00.1009271035110.9258@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christian@riesch.at, giometti@linux.it, peterz@infradead.org,
	johnstul@us.ibm.com, devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-api@vger.kernel.org, tglx@linutronix.de,
	linuxppc-dev@lists.ozlabs.org, richardcochran@gmail.com,
	alan@lxorguk.ukuu.org.uk, khc@pm.waw.pl
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bsdimp.com ([199.45.160.85]:51185 "EHLO harmony.bsdimp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396Ab0JBB7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 21:59:20 -0400
In-Reply-To: <alpine.DEB.2.00.1009271035110.9258@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message: <alpine.DEB.2.00.1009271035110.9258@router.home>
            Christoph Lameter <cl@linux.com> writes:
: On Thu, 23 Sep 2010, Christian Riesch wrote:
: 
: > > > It implies clock tuning in userspace for a potential sub microsecond
: > > > accurate clock. The clock accuracy will be limited by user space
: > > > latencies and noise. You wont be able to discipline the system clock
: > > > accurately.
: > >
: > > Noise matters, latency doesn't.
: >
: > Well put! That's why we need hardware support for PTP timestamping to reduce
: > the noise, but get along well with the clock servo that is steering the PHC in
: > user space.
: 
: Even if I buy into the catch phrase above: User space is subject to noise
: that the in kernel code is not. If you do the tuning over long intervals
: then it hopefully averages out but it still causes jitter effects that
: affects the degree of accuracy (or sync) that you can reach. And the noise
: varies with the load on the system.

Please see the earlier posts in this thread about why this doesn't
matter as much as you might think.  What matters is the measurements
(which are done in hardware and the results buffered), not the latency
in processing those messages through your servo.  This is due to the
fact that the errors that even long latencies introduce are
proportional to the change in fractional frequency[*] of the clock being
steered.  This change is usually on the order of a part per million.
Even with 10ms of latency would mean that you're introducing on the
order of sub-nanoseconds of phase error that will be measured in the
next cycle and steered out.

That's why latency doesn't matter.  Do you have other math to show
that it does?

Warner

[*] abs(1 - (clock_freq_old / clock_freq_new)) where clock_freq_old is
the old estimate of the clock and clock_freq_new is the new frequency
estimate of the clock.  Second to second, these change on the order of
a part per million or less...
