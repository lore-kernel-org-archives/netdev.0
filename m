From: Travis Stratman <tstratman@emacinc.com>
Subject: Re: data received but not detected
Date: Tue, 17 Jun 2008 17:58:26 -0500
Message-ID: <1213743506.5771.220.camel@localhost.localdomain>
References: <1213740538.5771.192.camel@localhost.localdomain>
	 <48583B37.5070708@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.emacinc.com ([63.245.244.68]:41646 "EHLO mail.emacinc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760175AbYFQW7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 18:59:50 -0400
In-Reply-To: <48583B37.5070708@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-06-17 at 15:31 -0700, Ben Greear wrote:
> Travis Stratman wrote:
> > I am working on an application that uses a fairly simple UDP protocol to
> > send data between two embedded devices. I'm noticing an issue with an
> > initial test that was written where datagrams are received but not seen
> > by the recvfrom() call until more data arrives after it. As of right now
> > the test case does not implement any type of lost packet protection or
> > other flow control, which is what makes the issue so noticeable.
> 
> UDP packets can be lost anywhere..including in the receive buffer
> after it has been received by the NIC.
> 
> You probably just need to write your code smarter to use non-blocking
> IO and deal with packet loss.

Thanks Ben.

I understand that there is no guarantee of anything with UDP, but it
seems to me that if there is a packet in the buffer (it shows up after
another packet comes in behind it) the system should know about it,
right?

The code will eventually deal with packet loss / retransmission (it is
actually a customer's application, not my own). Development was only
stopped at this point because this behavior was discovered. However, if
the final application behaves in the same way that things are going now,
the application would need to timeout on read, request retransmission,
receive the original packet (that was just stuck in the buffer
somewhere) and the retransmitted packet and decide which to toss every
couple of seconds. This is a whole lot more retransmissions than I would
expect to see on a cross-over cable, especially from receiving and
processing only two small packets at one pass.

If this is what's required I will relay that to the customer or
implement some type of workaround to force a poll or flush. However, if
there is possibly a bug or race condition that is not getting handled
properly it would be better to try and find it.

Thanks,
Travis

> 
> Thanks,
> Ben
> 

