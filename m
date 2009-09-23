From: Stephen Hemminger <shemminger@vyatta.com>
Subject: pktgen: tricks
Date: Tue, 22 Sep 2009 22:49:02 -0700
Message-ID: <20090922224902.17ed6cc4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <jdb@comx.dk>,
	Robert Olsson <robert@herjulf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43111 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751477AbZIWFtG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 01:49:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I thought others want to know how to get maximum speed of pktgen.

1. Run nothing else (even X11), just a command line
2. Make sure ethernet flow control is disabled
   ethtool -A eth0 autoneg off rx off tx off
3. Make sure clocksource is TSC.  On my old SMP Opteron's
   needed to get patch since in 2.6.30 or later, the clock guru's
   decided to remove it on all non Intel machines.  Look for patch
   than enables "tsc=reliable"
4. Compile Ethernet drivers in, the overhead of the indirect
   function call required for modules (or cache footprint),
   slows things down.
5. Increase transmit ring size to 1000
   ethtool -G eth0 tx 1000

Result: OK: 70408581(c70405979+d2602) nsec, 100000000 (60byte,0frags)
  1420281pps 681Mb/sec (681734880bps) errors: 0
