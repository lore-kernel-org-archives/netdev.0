From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: e1000>5.2.30 unstable with InterruptThrottleRate=0
Date: Sun, 05 Dec 2004 12:34:53 -0800
Message-ID: <1102278893.3343.116.camel@sfeldma-mobl.dsl-verizon.net>
References: <Pine.LNX.4.44.0412051457030.13794-100000@papput.nsc.liu.se>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Kjellstroem <cap@nsc.liu.se>
In-Reply-To: <Pine.LNX.4.44.0412051457030.13794-100000@papput.nsc.liu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-05 at 06:04, Peter Kjellstroem wrote:
> I've been doing som more tests today to try to narrow down which patch 
> causes my problems. So far I have this:
> 
> 2.4.26 (5.2.30) is ok
> 2.4.28 (5.4.11) is not
> 
> 2.4.28 with 5.2.30 patched in is ok
> 2.4.28 with 5.2.39 (from 2.4.27-pre1) is not
> 
> In e1000_main.c for 5.2.39 (from 2.4.27-pre1) i found this:
> 
> /* Change Log
>  *
>  * 5.2.39       3/12/04
>  * ...
>  *   o Back out the CSA fix for 82547 as it continues to cause
>  *     systems lock-ups with production systems.

Yes, there was a driver "fix" for this problem that has since been
pulled out of the production driver because it caused lockups on some
systems.  I have one of these such systems.  Here's the results on my
systems with an 82547EI:

5.2.22		lockup
5.2.30.1	lockup
5.2.39		NETDEV reset
5.2.52		NETDEV reset
5.4.11		NETDEV reset

For you, with an 82547GI, any driver between 5.2.22 and 5.2.30.1 will
work because it has the "fix".  See the comment in e1000_intr for these
drivers.

So I guess you're not out of luck if you use the 5.2.30 driver.  You
just can't move forward to a newer driver unless you port the "fix"
forward.

-scott
