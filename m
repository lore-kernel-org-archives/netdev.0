From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Wed, 29 Jul 2015 14:30:05 +0200
Message-ID: <20150729123005.GB16880@localhost.localdomain>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
 <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com>
 <CALAqxLVkwJ5cmvSZ9bL-F7YTFprZ+CvZW4MrMN0sEkk5yFqMRQ@mail.gmail.com>
 <alpine.DEB.2.11.1507291014490.3825@nanos>
 <alpine.DEB.2.11.1507291222190.3825@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
	Christopher Hall <christopher.s.hall@intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	john.ronciak@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1507291222190.3825@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 29, 2015 at 12:23:27PM +0200, Thomas Gleixner wrote:
> > Something like the below untested patch should be all we need for PTP
> > to be as precise as possible.

Yes, that is as good as it can be.  The code protects against
concurrent NTP adjustments, and the PTP driver will have to block
changes to its clock during the ioctl.

> > I don't know whether we need functionality to convert arbitrary
> > timestamps at all, but if we really need them then they are going to
> > be pretty simple and explicitely not precise for anything else than
> > clock monotonic raw. But that's a different story.
> > 
> > Lets concentrate on PTP first and talk about the other stuff once we
> > settled the use case which actually has a precision requirement.

The PTP ioctl only needs the REALTIME value, and so the MONO-RAW bit
could be dropped for now.

Thanks,
Richard
