From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Question about QOS
Date: Tue, 26 Apr 2005 14:59:55 +0200
Message-ID: <20050426125955.GT577@postel.suug.ch>
References: <426E06F1.9000105@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Content-Disposition: inline
In-Reply-To: <426E06F1.9000105@6wind.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Nicolas DICHTEL <426E06F1.9000105@6wind.com> 2005-04-26 11:16
> I set CONFIG_NET_SCH_CLK_GETTIMEOFDAY in my kernel. The macro 
> PSCHED_TDIFF_SAFE calculates
> the difference between two timestamps and uses the function 
> psched_tod_diff() to do this.
> If the clock is readjusted (due to ntp for example), this function can 
> return a negative number
> (if bound > 1000000) and then the flow is blocked by the kernel. Am I 
> right ?

do_gettimeofday takes care of ntp adjustments so we _should_ be safe,
however, it might be wise to enforce a range of 0..bound instead of
INT_MIN..bound because qdiscs like red are relying on this. Assuming
we have a delta of -4 seconds and return -4e6 red will horribly
crash when acccessing the array with idle_time>>cell_log.
