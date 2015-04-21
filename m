From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods
 with timespec64 type for k_clock structure
Date: Tue, 21 Apr 2015 22:13:42 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1504212204130.13914@nanos>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <3231171.5TrYVVBLh4@wuerfel> <alpine.DEB.2.11.1504211701140.13914@nanos> <2819798.f0KhjY3UAe@wuerfel>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: y2038@lists.linaro.org, Baolin Wang <baolin.wang@linaro.org>,
	pang.xunlei@linaro.org, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	paulus@samba.org, cl@linux.com, heenasirwani@gmail.com,
	linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
	mpe@ellerman.id.au, rafael.j.wysocki@intel.com, ahh@google.com,
	fweisbec@gmail.com, pjt@google.com, riel@redhat.com,
	richardcochran@gmail.com, schwidefsky@de.ibm.com,
	john.stultz@linaro.org, rth@twiddle.net,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, tj@kernel.org, linux390@de.ibm.com,
	linuxppc-dev@lists.ozlabs.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2819798.f0KhjY3UAe@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Apr 2015, Arnd Bergmann wrote:
> I know there are concerns about this, in particular because C11 and
> POSIX both require tv_nsec to be 'long', unlike timeval->tv_usec,
> which is a 'suseconds_t' and can be defined as 'long long'.
>
> a)
> 
> struct timespec {
> 	time_t tv_sec;
> 	long long tv_nsec; /* or typedef long long snseconds_t */
> };
> 
> This is not directly compatible with C11 or POSIX.1-2008, but it
> matches what we do inside of 64-bit kernels, so probably has the
> highest chance of working correctly in practice

After reading Linus rant in the x32 thread again (thanks for the
reminder), and looking at b/c/d - which rate between ugly and butt
ugly - I think we should go for a) and screw POSIX and C11 as those
committee dinosaurs seem to completely ignore the 2038 problem on
32bit machines. At least I have not found any hint that these folks
care at all. So why should we comply to something which is completely
useless?

That also makes the question about the upper 32bits check moot, so
it's the simplest and clearest of the possible solutions.

Thanks,

	tglx
