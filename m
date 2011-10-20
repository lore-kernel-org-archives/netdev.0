From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 5/6] ixgbe: add hardware timestamping support
Date: Thu, 20 Oct 2011 16:56:37 +0200
Message-ID: <20111020145637.GC1949@netboy.at.omicron.at>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1318854062-3628-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <20111017164433.GA2028@netboy.at.omicron.at>
 <CA+P7+xoP7VE0FEKnLCbzygw499xLr1PFynPn6W0+ud6KwZHgEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jacob Keller <jacob.keller@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:33987 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab1JTO5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 10:57:02 -0400
Received: by ggnb1 with SMTP id b1so2869002ggn.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 07:57:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+P7+xoP7VE0FEKnLCbzygw499xLr1PFynPn6W0+ud6KwZHgEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 10:04:33AM -0700, Jacob Keller wrote:
> On Mon, Oct 17, 2011 at 9:44 AM, Richard Cochran <richardcochran@gmail.com> wrote:
> > So, is this wrap around due to the fact that you are tied to the
> > system time via time_compare? Or, putting it another way, can't you
> > program the hardware time stamping unit so that the registers have
> > some reasonable resolution (like 64 bits worth of nanoseconds) and
> > just offer RAW timestamps?
> 
> The wrap around is due to hardware limitations. The ixgbe devices
> cannot support 64bits worth of nanoseconds and still have the ability
> to adjust the frequency in parts per billion. A larger increment
> increases the resolution available for frequency adjustments, but
> decreases the time it takes for the cycle counter to wrap around.

Oh, well. That stinks.

I think you do want to offer ppb adjustment.

> > I would really like to move away from the timecompare hacks and
> > towards a proper PHC->SYS PPS solution.
> >
> 
> I agree that this is the correct approach. The timecompare
> functionality does have issues.

And these cards are highlighting timecompare weaknesses I had not even
thought of.

I expect that if you offer the RAW time stamps, then it should be
possible to have the time stamp values always correct (or nearly so)
even with a changing link speed. If the link speed change gives an
interrupt, then the ISR can reprogram the frequency compensation
registers and let the counter continue.

> > Again, doing the update thing on every packet won't work for real
> > world PTP scenarios.
> >
> Which is why the PHC solution is better. Work on implementing this
> support is in progress. Out of curiosity, what is the sync rate for
> the scenario that breaks this? I would like to try that rate out on my
> setup.

For the audio/video profile, they have a max of 32 sync packets per
second. Not sure about delay request rate, maybe 16 per second.

Thanks,
Richard
