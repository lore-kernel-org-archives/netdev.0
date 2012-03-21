From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Wed, 21 Mar 2012 17:08:17 +0100
Message-ID: <20120321160817.GB1941@netboy.at.omicron.at>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
 <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jacob.e.keller@intel.com, jeffrey.t.kirsher@intel.com,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35904 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037Ab2CUQIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 12:08:31 -0400
Received: by wejx9 with SMTP id x9so1081613wej.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 09:08:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 21, 2012 at 11:00:59AM -0400, chetan loke wrote:
> 
> Once PHC->gettime goes live(aka exported to user space), we can't
> really control how users will use it in their applications. There
> could be 100+ apps all trying to get real-time from the network to do
> some time-keeping stuff. They might pound the ioctls at high rate. The
> last thing we would want is to self-induce a light weight DOS.

Well, if people want to write programs that make no sense at all,
then I can cannot stop them. There really isn't any point in general
applications using the PHC directly. You can easily synchronize the
system time to the PHC to within a few microseconds. Just the error
from reading the clock (due to various kinds of latency) is much
larger than that.

Also, although you might be able to optimize clock_gettime performance
for a PCI card, this will never work for PHY based devices, which, by
the way, offer superior PTP time stamping. So, in general, applications
should stick to reading the system time.

We still need to get some more tools out there in order to support the
PHC->system synchronization, but that is not too far off. That is what
I am working on now, and I don't think optimizing the igb is worth the
effort. If you want to try it, please go right ahead, but adding the
PPS would be much more useful IMHO.

Thanks,
Richard
