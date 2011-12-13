From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware
 Clock instead of the timecompare method
Date: Tue, 13 Dec 2011 04:41:33 +0100
Message-ID: <20111213034132.GC9604@netboy.at.omicron.at>
References: <cover.1323744724.git.richardcochran@gmail.com>
	<388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
	<1323746932.2583.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1323746932.2583.33.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Dec 13, 2011 at 04:28:52AM +0100, Eric Dumazet wrote:
> 
> Adding a (shared) spinlock on a multiqueue device is source of extra
> delay (because of extra cache line trafic), I guess.
> 
> It seems current code doesnt need a spinlock, maybe it was a bug ?

(I didn't think about the old code. I only deleted it. ;)

The spinlock is needed because reading the 64 bit time value involves
reading two 32 registers. The first read latches the value. Ditto for
writing.

In addition, here we have to watch the most significant bit for
one-to-zero transistion, in order to keep count of the overflow.

It is too bad that we have to take the spinlock for every time stamped
packet, but it is the hardware's fault for not providing a 64 bit wide
nanosecond time register.

Richard

------------------------------------------------------------------------------
Systems Optimization Self Assessment
Improve efficiency and utilization of IT resources. Drive out cost and 
improve service delivery. Take 5 minutes to use this Systems Optimization 
Self Assessment. http://www.accelacomm.com/jaw/sdnl/114/51450054/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
