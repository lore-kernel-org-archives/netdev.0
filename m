From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods
 with timespec64 type for k_clock structure
Date: Wed, 22 Apr 2015 12:11:14 +0200
Message-ID: <20150422101114.GA5527@localhost.localdomain>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <3231171.5TrYVVBLh4@wuerfel>
 <alpine.DEB.2.11.1504211701140.13914@nanos>
 <2819798.f0KhjY3UAe@wuerfel>
 <alpine.DEB.2.11.1504212204130.13914@nanos>
 <alpine.DEB.2.11.1504220946460.13914@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, y2038@lists.linaro.org,
	Baolin Wang <baolin.wang@linaro.org>, pang.xunlei@linaro.org,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>, cl@linux.com,
	heenasirwani@gmail.com, linux-arch@vger.kernel.org,
	linux-s390@vger.kernel.org, mpe@ellerman.id.au,
	rafael.j.wysocki@intel.com, ahh@google.com,
	Frederic Weisbecker <fweisbec@gmail.com>, pjt@google.com,
	riel@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	John Stultz <john.stultz@linaro.org>, rth@twiddle.net,
	gregkh@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	linux390@de.ibm.com, linuxppc-dev@lists.ozlabs.org,
	Ingo Molnar <mingo@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504220946460.13914@nanos>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 22, 2015 at 10:45:23AM +0200, Thomas Gleixner wrote:
> So we could save one translation step if we implement new syscalls
> which have a scalar nsec interface instead of the timespec/timeval
> cruft and let user space do the translation to whatever it wants.

+1

> I personally would welcome such an interface as it makes user space
> programming simpler. Just (re)arming a periodic nanosleep based on
> absolute expiry time is horrible stupid today:

Jup.

> Thoughts?

Current user space example: The linuxptp programs are doing ns64 to
timespec conversions to call into the kernel, which then does timespec
to ns64 to talk to the hardware.  I would bet that most (all?) use
cases are better served with 64 bit nanosecond system calls.

Thanks,
Richard
