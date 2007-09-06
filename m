From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
	condition
Date: Thu, 06 Sep 2007 09:22:05 -0400
Message-ID: <1189084926.4229.19.camel@localhost>
References: <20070904032036.GA11153@ludhiana>
	 <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org>
	 <20070905074411.GA4815@ludhiana> <46DE9B09.7060603@katalix.com>
	 <1188995619.4238.5.camel@localhost> <46DEB545.3030509@katalix.com>
	 <1189002087.4228.26.camel@localhost>  <20070906050629.GA4262@ludhiana>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>,
	Daniele Venzano <venza@brownhat.org>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: Mandeep Singh Baines <mandeep.baines@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:50531 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756082AbXIFNWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 09:22:10 -0400
Received: by an-out-0708.google.com with SMTP id d31so23290and
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2007 06:22:09 -0700 (PDT)
In-Reply-To: <20070906050629.GA4262@ludhiana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-09 at 22:06 -0700, Mandeep Singh Baines wrote:
> jamal (hadi@cyberus.ca) wrote:

> > If you read the paper: There are no issues with high throughput - NAPI
> > kicks in.
> > The challenge to be overcome is at low traffic, if you have a real fast
> > processor your cpu-cycles-used/bits-processed ratio is high....
> 
> I'm not sure cpu-cycles-used/bits-processed is the correct metric to use.
> An alternative would be to look at cpu-cycles-used/unit-time (i.e.
> CPU utilization or load) for a given bit-rate or packet-rate. 

I wasnt explicit but we are saying the same thing. The paper is more
specific: if you make the packet count used constant - this translates
to a unit of time given low traffic rate. If you fix the time,
cpu-cycles are easier to extrapolate from.

> This would make an interesting graph.

If you are to plot a cpu-util vs packet rate, on most modern hardware you will 
see a spike before you hit the MLFRR and then utilization will go down and slowly 
start going up.

> At low packet-rate, CPU utilization is low so doing extra work per packet
> is probably OK. 

Thats the arguement weve used in the past ;-> Unfortunately, with the
relative cost of IO going up you cant keep making that arguement (at
least thats the position presented in the paper). 
Your mileage may vary. If you are running a machine dishing out bulk
transfers probably not a big deal. If you are doing database
transactions, you loose in benchmarks etc.

> Utilizing 2% of CPU vesus 1% is negligible. But at higher
> rate, when there is more CPU utilization, using 40% of CPU versus 60% is
> significant. I think the absolute different in CPU utilization is more
> important than the relative difference. iow, 2% versus 1%, even though 
> a 2x difference in cpu-cycles/packet, is negligible compared to 40% 
> versus 60%.

Refer to above.

> Using a timer might also behave better in a tick-less (CONFIG_NO_HZ) 
> configuration.

good point.

cheers,
jamal

