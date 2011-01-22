From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V9 08/13] posix clocks: cleanup the CLOCK_DISPTACH macro
Date: Sat, 22 Jan 2011 13:38:40 +0100
Message-ID: <20110122123840.GA30830@riccoc20.at.omicron.at>
References: <cover.1294917347.git.richard.cochran@omicron.at>
 <90b2beef441615d01c93fcad029c44af4e505c5f.1294917348.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1101131745400.2678@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1101131745400.2678@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2011 at 06:03:24PM +0100, Thomas Gleixner wrote:
> On Thu, 13 Jan 2011, Richard Cochran wrote:
> >  int posix_cpu_clock_getres(const clockid_t which_clock, struct timespec *ts);
> >  int posix_cpu_clock_get(const clockid_t which_clock, struct timespec *ts);
> > -int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *ts);
> > +int posix_cpu_clock_set(const clockid_t which_clock, struct timespec *ts);
> 
> Shouldn't we change the clock_set function to have *ts const in all places ?

The common_clock_set function calls:

    do_sys_settimeofday
        security_settime
            cap_settime
    do_settimeofday

so all their signatures must also change.

Should I add that into my patch set?

Thanks,
Richard
