From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Wed, 29 Jul 2015 14:35:55 +0200
Message-ID: <20150729123555.GP19282@twins.programming.kicks-ass.net>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
 <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com>
 <CALAqxLVkwJ5cmvSZ9bL-F7YTFprZ+CvZW4MrMN0sEkk5yFqMRQ@mail.gmail.com>
 <alpine.DEB.2.11.1507291014490.3825@nanos>
 <20150729104944.GM19282@twins.programming.kicks-ass.net>
 <20150729114840.GA16880@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	John Stultz <john.stultz@linaro.org>,
	Christopher Hall <christopher.s.hall@intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	john.ronciak@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150729114840.GA16880@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 29, 2015 at 01:48:41PM +0200, Richard Cochran wrote:
> On Wed, Jul 29, 2015 at 12:49:44PM +0200, Peter Zijlstra wrote:
> > This is still fuzzy, right? The hardware ART timestamp could be from
> > _before_ the NTP adjust; or the NTP adjust could happen while we do this
> > conversion and we'll take the retry loop.
> 
> In the original series, yes.
>  
> > In both cases, the resulting value is computed using a different slope
> > than was in effect at the time of the stamp. With the end result being
> > slightly off from what it should be.
> 
> In Thomas' patch the get_ts() is meant to read fresh pairs of time
> stamps from within the loop.

Ah, indeed, I missed that. Yes if that's possible we get it right.
