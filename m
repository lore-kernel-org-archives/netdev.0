From: Ben Greear <greearb@candelatech.com>
Subject: Long-term TCP connections suffer on high-latency links.
Date: Thu, 29 Jul 2004 22:01:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4109D63E.5070006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have been running a TCP connection over a link with 2 seconds round-trip-time.

It started off well, about 16Mbps in both directions (cwnd trained up to 2100
after a few  seconds).

After several hours of running, it is now doing only about 2.2Mbps in one
direction, and 3.4Mbps in the other direction.  I have watched the cwnd slowly
increasing by one every 2-5 seconds (it is at 440 on one side and 655 on the
other as I type).

Occasionally, the cwnd drops in half or maybe even goes to zero.

The un-acked packets is always == snd_cwnd.

My suspicion is that for connections needing a cwnd of 2000 or so,
the cwnd does not grow nearly fast enough after the connection
has been established for a while.  My naive suggestion would be to
increase cwnd by a certain percentage instead of a fixed number (1).

But, TCP has been around a long while, and surely other people
have noticed things like this, so what am I missing?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
