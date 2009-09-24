From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: pktgen: tricks
Date: Wed, 23 Sep 2009 17:41:41 -0700
Message-ID: <20090923174141.1d350103@s6510>
References: <20090922224902.17ed6cc4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	Robert Olsson <robert@herjulf.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37084 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448AbZIXAln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 20:41:43 -0400
In-Reply-To: <20090922224902.17ed6cc4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Sep 2009 22:49:02 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> I thought others want to know how to get maximum speed of pktgen.
> 
> 1. Run nothing else (even X11), just a command line
> 2. Make sure ethernet flow control is disabled
>    ethtool -A eth0 autoneg off rx off tx off
> 3. Make sure clocksource is TSC.  On my old SMP Opteron's
>    needed to get patch since in 2.6.30 or later, the clock guru's
>    decided to remove it on all non Intel machines.  Look for patch
>    than enables "tsc=reliable"
> 4. Compile Ethernet drivers in, the overhead of the indirect
>    function call required for modules (or cache footprint),
>    slows things down.
> 5. Increase transmit ring size to 1000
>    ethtool -G eth0 tx 1000
> 
> Result: OK: 70408581(c70405979+d2602) nsec, 100000000 (60byte,0frags)
>   1420281pps 681Mb/sec (681734880bps) errors: 0

Other kernel config help:
  - turn off lock dependency checker, kmecheck, page alloc debug
    basically anything that slows stuff down
  - turn off content group scheduler
