From: Patrick McHardy <kaber@trash.net>
Subject: Re: Inaccuracies with SCH_CLK_CPU
Date: Wed, 04 Aug 2004 22:10:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411142C3.7070501@trash.net>
References: <20040804094310.1d054b3a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040804094310.1d054b3a@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

>I noticed that the netem delay values are off if using 
>CONFIG_NET_SCH_CKL_CPU. For example, if the latency is set to 500ms
> a ping reports the time as much less (343ms).
>
>Requested	JIFFIES	GETTIMEODAY	CPU
>0		.1	.1		.1
>1		2	2		1
>5		5	6		4
>10		10	11		7
>100		98	101		69
>500		489	500		343
>1000		976	1000		685
>
>The 1ms value is affected by the clock granularity.  Larger jiffie values
>are inaccurate due to the optimization of using shift to do divide (ie 1024 > 1000).
>
I need to look at this some more.

>
>With CLK_CPU /proc/net/psched is:
>000005d9 00000400 000f4240 000003e8
>
>
>Instead of computing own values of psched_us_per_tick
>and psched_clock_per_hz, couldn't the values already done
>in timers code be used?
>
Can we do this in a uniform way on all architectures supported by
NET_SCH_CLK_CPU ? I think it's easier to fix up the PSCHED_* macros.

>
>Also doesn't PSCHED_US2JIFFIE need to be doing a do_div()
>in order to correctly do u64 divided by u32. Otherwise
>it ends up just doing an u32 divide.
>
No, PSCHED_US2JIFFIE is intended to be used with psched_tdiff_t, using
psched_time_t doesn't work with NET_SCH_CLK_GETTIMEOFDAY. psched_tdiff_t
is 32-bit on all 32-bit architectures.

Regards
Patrick
