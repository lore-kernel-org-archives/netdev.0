From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 14:09:06 +0100
Message-ID: <46027FF2.6020001@trash.net>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net> <20070322124533.M79867@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35463 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbXCVNJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 09:09:09 -0400
In-Reply-To: <20070322124533.M79867@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> /sbin/tc2 qdisc del dev ppp0 root 
> /sbin/tc2 qdisc add dev ppp0 root handle 1: prio 
> /sbin/tc2 qdisc add dev ppp0 parent 1:1 handle 2: tbf buffer 1024kb latency 
> 500ms rate 128kbit peakrate 256kbit minburst 16384 
> /sbin/tc2 filter add dev ppp0 parent 1:0 protocol ip prio 10 u32 match ip dst 
> 0.0.0.0/0 flowid 2:1 


That is an incredible huge buffer value.

> qdisc tbf 2: parent 1:1 rate 128000bit burst 4294932937b peakrate
256000bit minburst 16Kb lat 4.2s

And it causes an overflow.

The limit for the TBF burst value with nanosecond resolution is
~ 4 * rate (10^9 * burst / rate < 2^32 needs to hold), resoluting
in a worst-case latency of 4 seconds. I think this limit is in the
reasonable range. Your configuration results in a worst-case
queuing delay of 64s, and I doubt that you really want that.

Obviously its not good to break existing configurations, but I
would argue that this configuration is broken.

