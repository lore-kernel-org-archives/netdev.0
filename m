From: Dan Noe <dnoe@limebrokerage.com>
Subject: Re: Detecting TCP loss on the receiving side?
Date: Thu, 10 Jul 2008 18:15:42 -0400
Message-ID: <48768A0E.3010904@limebrokerage.com>
References: <4876668C.8040108@limebrokerage.com> <48766CF0.1020101@hp.com>	<48766EC2.2090000@limebrokerage.com> <1e41a3230807101405y437dff4er443185be3228caa5@mail.gmail.com> <48767D07.2000003@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Heffner <johnwheffner@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colobus.isomerica.net ([216.93.242.10]:42890 "EHLO
	colobus.isomerica.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921AbYGJWXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:23:40 -0400
In-Reply-To: <48767D07.2000003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2008 05:20 PM, Rick Jones wrote:
> John Heffner wrote:
>> Looking for loss at the receiver is a bit tricky.  It doesn't look
>> like struct tcp_info has enough information to do this easily.  If you
>> are able to install a custom kernel on this machine, the Web100 patch
>> would be able to gather enough information to figure it out.  The
>> basic idea would be to look for a difference between RcvNxt and
>> RcvMax.
>
> And even then it depends on the connections having multiple segments
> in flight at one time.  Although I suppose that cuts both ways and
> affects the tracing too, but perhaps not to the same extent.
>
> Dan - seeing "brokerage" in your email and worries about latency makes
> me think that your app(s) are pushing around lots of small messages -
> are those spread-out across lots of connections, or are they
> consolidated into a rather smaller number of connections?  Also, what
> is the magnitude of the latency in these latency events?

Yeah, without going into too much detail:  We are getting data from a
market via a TCP connection.  Usually this is one or two connections. 
It is dominated by receiving traffic (from peer).  The message rates can
be very bursty, and the size is small.  The links are usually short and
fairly fat - metro fast Ethernet, for example, and the geographic
latency is low.  We believe loss is occurring but we're trying to
determine how often and where.  The data comes on fairly fast and a loss
event (even with fast retransmit) means things piling up in queues and a
sudden flood of data coming into userspace (which is a pretty serious
latency hit on this scale).

More and more places are moving to multicast (which has its own quirks)
but some are still using TCP :)

Cheers,
Dan
