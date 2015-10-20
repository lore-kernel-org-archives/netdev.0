From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Tue, 20 Oct 2015 21:36:39 +0200
Message-ID: <20151020193639.GA15095@localhost.localdomain>
References: <alpine.DEB.2.11.1510132116480.25029@nanos>
 <op.x6iyd7gq1774gr@chall-mobl2.amr.corp.intel.com>
 <alpine.DEB.2.11.1510151014330.3960@nanos>
 <op.x6r25dza1774gr@chall-mobl2.amr.corp.intel.com>
 <CALAqxLXu_C8sWaKyxqXJPFV+m5Zdk=4q4s7O6NoLR1B8bbyuxg@mail.gmail.com>
 <20151020085408.GA2542@netboy>
 <alpine.DEB.2.11.1510201246250.3982@nanos>
 <20151020115113.GA23428@netboy>
 <20151020145523.GA5207@netboy>
 <alpine.DEB.2.11.1510202107410.8159@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
	Christopher Hall <christopher.s.hall@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"x86@kernel.org" <x86@kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, kevin.b.stanton@intel.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1510202107410.8159@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 20, 2015 at 09:11:21PM +0200, Thomas Gleixner wrote:
> Darn, we don't want to have that kind of sampling in every driver
> which has this kind of problem even if it looks like the simpler
> choice for this particular use case. This is going to be something
> which next generation chips will have on more than just the audio
> interface and we realy want to have a generic solution for this.

Right, having multiple drivers sampling is bad.

Just thinking out loud: how about a service layer that can handle
multiple drivers?  The layer samples at the maximum requested rate,
and buffers the history for the maximum requested backlog.  The
non-max rate users simply get a higher resolution than they need.

A generic solution would handle any history length for old time
stamps, within reason.  I think hard coding 4 ms (or 8 ms or 800 ms)
is clunky.

Thanks,
Richard
