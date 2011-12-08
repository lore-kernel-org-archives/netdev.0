From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency difference between fifo and pfifo_fast
Date: Wed, 07 Dec 2011 19:05:45 -0500 (EST)
Message-ID: <b6a68bd3-eec7-47f3-bc46-2781b08d8815@jasiiieee>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF07@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>,
	Dave Taht <dave.taht@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:49228 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754915Ab1LGXFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 18:05:32 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF07@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "David Laight" <David.Laight@ACULAB.COM>
> To: "Dave Taht" <dave.taht@gmail.com>, "Eric Dumazet" <eric.dumazet@gmail.com>
> Cc: "John A. Sullivan III" <jsullivan@opensourcedevel.com>, netdev@vger.kernel.org, "Rick Jones" <rick.jones2@hp.com>
> Sent: Wednesday, December 7, 2011 9:08:24 AM
> Subject: RE: Latency difference between fifo and pfifo_fast
> 
> 
> ...
> > If he's hovering at close to line rate (wow), and yet experiencing
> > serious delays on short traffic, perhaps what I describe
> > below may apply.
> ...
> > 1) TCP grabs all the bandwidth it can. If you have no packet loss,
> > it will eat more bandwidth, as rapidly as it can ramp up.
> > Until it eventually has packet loss.
> 
> The 'ramp up' may be part of the problem!
> At a guess iSCSI is using the TCP connection to carry
> many, separate, commands and responses. As such Nagle
> will cause serious grief and is likely to be disabled.
> 
> TCP 'slow start' will apply whenever there is no unacked
> data - which might be after any slight lull in the traffic.
> IIRC (from looking at traces) Linux TCP will only send 4 data
> packets following 'slow start' until it has received an ack.
> Linux (at least some versions) will also delay sending an
> ack until the next clock tick - rather than the traditional
> scheme of always acking every other packet.
> 
> So if there are no responses, the requests can be delayed.
> This will increase latency.
> 
> My suspicions (as I've said before) is that slow start
> is broken for very low latency local networks.
> Might be worth disabling it - but that is a massive system-wide
> switch.
> 
> Very high packet rates can cause packet loss, but buying better
> network infrastructure should mitigate that. In any case, 'slow
> start' doesn't limit packet rate.
> 
> 	David
> 
> 
> 
<grin> Sorry to have kicked up a storm! We really don't have a problem - just trying to optimize our environment.  We have been told by our SAN vendor that, because of the 4KB limit on block size in Linux file systems, iSCSI connections for Linux file services are latency bound and not bandwidth bound.  I'm not sure if I believe that based upon our traces where tag queueing seems to coalesce SCSI commands into larger blocks and we are able to achieve network saturation.  I was just wondering, since it is all the same traffic and hence no need to separate into bands, if I should change the qdisc on those connections from pfifo_fast (which I assume needs to look at the TOS bits, sort into bands, and poll the separate bands) to fifo which I assume simply dumps packets on the wire.  Thanks - J
 ohn
