From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
 condition
Date: Wed, 05 Sep 2007 14:55:17 +0100
Message-ID: <46DEB545.3030509@katalix.com>
References: <20070904032036.GA11153@ludhiana>	 <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org>	 <20070905074411.GA4815@ludhiana>  <46DE9B09.7060603@katalix.com> <1188995619.4238.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mandeep Singh Baines <mandeep.baines@gmail.com>,
	Daniele Venzano <venza@brownhat.org>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:53264 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757045AbXIENzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 09:55:35 -0400
In-Reply-To: <1188995619.4238.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-05-09 at 13:03 +0100, James Chapman wrote:
> 
>> I have a patch that solves the high interrupt rate problem by keeping 
>> the driver in polled mode longer. It's written for the latest NAPI 
>> version that DaveM posted recently. I'll try to get some time to write 
>> it up and post it for comment.
> 
> Theres interesting challenges to be tackled with resolving that. 
> Just so you dont reinvent the wheel or to help invent a better one;
> please read:
> http://kernel.org/pub/linux/kernel/people/hadi/docs/UKUUG2005.pdf
> 
> if you have, what are the differences in your approach - and when
> do you find it useful?

Thanks Jamal. Yes, I'd already read your paper. I think my idea is 
different to the ideas described in your paper and I'm in the process of 
writing it up as an RFC to post to netdev. Briefly though, the driver's 
->poll() holds off doing netif_rx_complete() for 1-2 jiffies and keeps 
itself in poll_on mode for that time, consuming no quota. The net_rx 
softirq processing loop is modified to detect the case when the only 
devices in its poll list are doing no work (consuming no quota). The 
driver's ->poll() samples jiffies while it is considering when to do the 
netif_rx_complete() like your Parked state - no timers are used.

If I missed that this approach has already been tried before and 
rejected, please let me know. I see better throughput and latency in my 
packet forwarding and LAN setups using it.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

