From: Martin Devera <devik@cdi.cz>
Subject: ANK's PSCHED_TDIFF_SAFE change unmasked old bug (~0UL != 0xFFFFFFFF)
Date: Thu, 16 May 2002 15:52:43 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0205161543400.12674-100000@luxik.cdi.cz>
References: <200205121635.UAA01437@mops.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200205121635.UAA01437@mops.inr.ac.ru>
List-Id: netdev.vger.kernel.org

> > even if tv1<tv2 which can be true when time wraps (which is true
> > at least with PSCHED_TIME_SOURCE == JIFFIES)
>
> No, psched_time_t cannot wrap for our life.

Ok. It did. I looked for the reason and probably find another
bug. In all kernels (example given for 2.4.19pre8)
include/net/pkt_sched.h line 224:
#if ~0UL == 0xFFFFFFFF

this test delimits part which decides about PSCHED_WATCHER usage.
The test is FALSE on gcc:
gcc version 2.95.2 20000220 (Debian GNU/Linux)
gcc version egcs-2.91.66 19990314/Linux (egcs-1.1.2 release)
gcc version 3.0.2

I tested by:
echo -e "#if ~0UL == 0xffffffff\nTST\n#endif"|gcc -E -
echo -e "#if ~0UL == 0xffffffffffffffff\nTST\n#endif"|gcc -E -

and the second line displays TST !!

So that the test is never TRUE and PSCHED_WATCHER is never used.
Thus psched_time_t wraps every 40 minutes and your change (althought
correct one) to PSCHED_TDIFF_SAFE made it more visible than before.

Probably the test should be changed. I'm not sure how. How to detect
that long is 64 bit in cpp ?

regards
devik
