From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 13 Oct 2015 10:31:13 +0200
Message-ID: <20151013083113.GA1931@localhost.localdomain>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <20151013045832.GA2437@netboy>
 <alpine.DEB.2.11.1510130944520.6097@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Christopher S. Hall" <christopher.s.hall@intel.com>,
	jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1510130944520.6097@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 13, 2015 at 09:51:02AM +0200, Thomas Gleixner wrote:
> 
> You are restricting the problem space to this particular use
> case. There are other use cases where PTP is not available or not the
> relevant reference, but you still want to correlate time domains to
> ART.

They may well be other use cases, but they have not been identified
here.  The PTP to media clock problem has a very simple solution.  You
do not need a history of system time stamps to solve it.

Even if you wanted to correlate the system time's UTC with the media
clock, still you don't need any shadow history for that.  Just feed
(ART, UTC) pairs into the DSP at a regular rate, and let the DSP do
the math.  This does not need to be part of the central time keeping
code at all.

Thanks,
Richard
