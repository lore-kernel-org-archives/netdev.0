From: Stephen Hemminger <shemminger@osdl.org>
Subject: Inaccuracies with SCH_CLK_CPU
Date: Wed, 4 Aug 2004 09:43:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804094310.1d054b3a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I noticed that the netem delay values are off if using 
CONFIG_NET_SCH_CKL_CPU. For example, if the latency is set to 500ms
 a ping reports the time as much less (343ms).

Requested	JIFFIES	GETTIMEODAY	CPU
0		.1	.1		.1
1		2	2		1
5		5	6		4
10		10	11		7
100		98	101		69
500		489	500		343
1000		976	1000		685

The 1ms value is affected by the clock granularity.  Larger jiffie values
are inaccurate due to the optimization of using shift to do divide (ie 1024 > 1000).

With CLK_CPU /proc/net/psched is:
000005d9 00000400 000f4240 000003e8


Instead of computing own values of psched_us_per_tick
and psched_clock_per_hz, couldn't the values already done
in timers code be used?  

Also doesn't PSCHED_US2JIFFIE need to be doing a do_div()
in order to correctly do u64 divided by u32. Otherwise
it ends up just doing an u32 divide.
