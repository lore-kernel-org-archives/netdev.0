From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: do_gettimeofday
Date: Thu, 2 Oct 2003 13:46:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002204636.GB30579@gaz.sfgoth.com>
References: <3F7C6F3B.6070502@sgi.com> <20031002125625.72b8c0a7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Modica <modica@sgi.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031002125625.72b8c0a7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Two problems:
> 	a. xtime is limited to HZ resolution which is insufficient for more advanced
> 	   packet schedulers and rtt estimation.
> 	b. unlocked access to xtime is unsafe because it is not atomic!
> 
> ATM is busted if it does this.

It got fixed in 2.5 (when skb->stamp got changed to nanosecond resolution
so it broke the compile to do it the old way)  You can use LXR to see all
of the xtime users as of 2.6.0-test2:
  http://lxr.linux.no/ident?v=2.6.0-test2&i=xtime

The reason that ATM _had_ been using xtime was not for performance.  When
the ATM code was originally written (during the 1.X kernels) all network
drivers used xtime directly.  At some point the network drivers were
mass-updated to use do_gettimeofday() but ATM had not been merged into
the main tree yet so it missed the conversion.

-Mitch
