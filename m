From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: inter-packet gap in pktgen
Date: Wed, 8 Dec 2004 08:38:58 +0100
Message-ID: <20041208073858.GA4027@xi.wantstofly.org>
References: <20041207222522.GA30266@xi.wantstofly.org> <41B632F3.1090104@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <41B632F3.1090104@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 07, 2004 at 02:47:15PM -0800, Ben Greear wrote:

> >By tweaking the 'ipg' parameter I can generate pretty much any packet rate
> >I want, as long as I set ipg=(1e9/rate)-496 instead of something possibly
> >more straightforward.
> 
> That 496 will also change with load on the system, at least on average.  I
> dealt with this by having a user-space app sample the rate and adjust the 
> ipg to keep the average rate where I want it.
> 
> So, I'd suggest leaving the ipg as it is, and use external tools to get
> the exact pps that you are looking for.

Just because it's possible that way doesn't mean that it's the only
way or even _the_ way of doing it.

Another option is:

	next_tx = get_time_in_ns();
	while (--count) {
		tx_packet();
		next_tx += 1e9/intended_pps;
		nanospin(next_tx - get_time_in_ns());
	}

This should be relatively independent of system load.  OK, I know,
time to show some code.


--L
