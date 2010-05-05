From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: 3 packet TCP window limit?
Date: Wed, 05 May 2010 09:26:04 -0400
Message-ID: <4BE171EC.20904@athenacr.com>
References: <alpine.LNX.2.00.1005050210230.8544@d>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1411 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755866Ab0EEN0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 09:26:08 -0400
In-Reply-To: <alpine.LNX.2.00.1005050210230.8544@d>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dormando wrote:
> Hey,
> 
> Noticed in Linux that no matter what sysctl variable I twiddle, or what
> TCP congestion algorithm is running, TCP will wait for remote acks after
> sending the first 3 packets. After that it's normal.
> 
> Apologies, it's hard ot describe:
> 
> Linux server listening.
> 
> Remote -> SYN
> (RTT wait)
> Linux -> SYN/ACK
> Remote -> ACK
> Remote -> Packet (small HTTP request)
> (RTT wait)
> Linux -> Packet (x 3)
> Remote -> (returning acks per packet)
> (RTT wait)
> Linux -> More packets (up to window size)
> 
> If the request response fits in 3 packets or less, that third RTT wait
> never happens. The remote client gets all its data, and sends back all the
> FIN/ACK packets for closing the connection.
> 
> What's bizarre is that this 3 packet/4 packet barrier is regardless of how
> much data there is to send. I can cause the extra RTT to flip on or off by
> sending exactly +/- 1 byte to cause an extra packet.
> 
> Holding the connection open and repeating the request any number of times
> runs just fine, after the initial request.
> 
> You can pretty easily see this by:
> tc qdisc add dev eth0 root netem delay 100ms
> ... then fetching a 3k file, then 4k file from an http server running
> linux. Well. at least I can see this easily. I tried on a half dozen boxes
> (2.6.11 through 2.6.32).
> 
> I'm trying to track down where in the code this is, or why my sysctl
> tuning isn't affecting it. I can't discern its purpose. The lag it causes
> is pretty awful for far away clients; adding 300ms of latency will make a
> small request take a full second, instead of 600ms.
> 
> I'm slugging through the code but any insight would be greatly
> appreciated!

This sounds like TCP slow start.

http://en.wikipedia.org/wiki/Slow-start

As far as tunables you might want to play with the initcwnd route
flag (see "ip route help")

> 
> -Dormando
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

