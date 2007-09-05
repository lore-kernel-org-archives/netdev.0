From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
	condition
Date: Wed, 05 Sep 2007 10:21:27 -0400
Message-ID: <1189002087.4228.26.camel@localhost>
References: <20070904032036.GA11153@ludhiana>
	 <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org>
	 <20070905074411.GA4815@ludhiana>  <46DE9B09.7060603@katalix.com>
	 <1188995619.4238.5.camel@localhost>  <46DEB545.3030509@katalix.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mandeep Singh Baines <mandeep.baines@gmail.com>,
	Daniele Venzano <venza@brownhat.org>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:48223 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756395AbXIEOVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 10:21:35 -0400
Received: by an-out-0708.google.com with SMTP id d31so402380and
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2007 07:21:34 -0700 (PDT)
In-Reply-To: <46DEB545.3030509@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-09 at 14:55 +0100, James Chapman wrote:

> Thanks Jamal. Yes, I'd already read your paper. I think my idea is 
> different to the ideas described in your paper 

I am hoping you can pick from the lessons of what has been tried and
failed and the justification for critiqueing something as "Failed". 
If you have - i feel i accomplished something useful writting the paper.

> and I'm in the process of 
> writing it up as an RFC to post to netdev. 

Please cc me if you want my feedback - I am backlogged by about 3000
messages on netdev.

> Briefly though, the driver's 
> ->poll() holds off doing netif_rx_complete() for 1-2 jiffies and keeps 
> itself in poll_on mode for that time, consuming no quota. 
> The net_rx 
> softirq processing loop is modified to detect the case when the only 
> devices in its poll list are doing no work (consuming no quota). The 
> driver's ->poll() samples jiffies while it is considering when to do the 
> netif_rx_complete() like your Parked state - no timers are used.

Ok, so the difference seems to be you actually poll instead for those
jiffies instead starting a timer in the parked state - is that right?

> If I missed that this approach has already been tried before and 
> rejected, please let me know. I see better throughput and latency in my 
> packet forwarding and LAN setups using it.

If you read the paper: There are no issues with high throughput - NAPI
kicks in.
The challenge to be overcome is at low traffic, if you have a real fast
processor your cpu-cycles-used/bits-processed ratio is high....
If you are polling (softirqs have high prio and depending on the cpu,
there could be a few gazillion within those 1-2 jiffies), then isnt the
end result still a high cpu-cycles used?
Thats what the timer tries to avoid (do nothing until some deffered
point).
If you waste cpu cycles and poll, I can see that (to emphasize: For
FastCPU-LowTraffic scenario), you will end up _not_ having latency
issues i pointed out, but you surely have digressed from the original
goal which is to address the cpu abuse at low traffic (because you abuse
more cpu).

One thing that may be valuable is to show that the timers and polls are
not much different in terms of cpu abuse (It's theoretically not true,
but reality may not match).
The other thing is now hrestimers are on, can you try using a piece of
hardware that can get those kicked and see if you see any useful results
on latency.

cheers,
jamal

