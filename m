From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Getting hopcount and dupacks from TCP CA module
Date: Fri, 29 Jun 2007 10:08:40 -0400
Message-ID: <20070629100840.4764e49d@oldman>
References: <20070629094837.92827.qmail@web25504.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pierre Capillon <pierrecap@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55477 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765544AbXF2OIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 10:08:53 -0400
In-Reply-To: <20070629094837.92827.qmail@web25504.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Jun 2007 11:48:37 +0200 (CEST)
Pierre Capillon <pierrecap@yahoo.fr> wrote:

> Hello,
> 
> I'm a french IT engineering student and as part of my
> internship, I'm writing a congestion avoidance module
> based on research by my tutor. It aims at better
> efficiency and throughput on mobile adhoc networks.
> 
> Basically, it is a sender-side modification that
> differentiates between losses due to network
> congestion or link failure, in which case I would need
> to get the new route properties for the current tcp
> socket.
> 
> Is there a simple and generic way of knowing the route
> length (hopcount) from a TCP CA module, once RTO has
> occured? Currently, the paper states I should know the
> exact new route length to recompute the congestion
> window and RTO values. I guess I need to get that
> information from the routing layers, but is it event
> possible from the module? Or is it simpler to rework
> the algorithm to have the congestion window based on
> hop difference (using received TTL values from the
> remote end)?

A TCP CA module can find the RTT but has no way to find TTL.
TTL (hop count) is not really available given the IP model. 

> Either way, I would appreciate hints/pointers to
> structures and/or mechanics I would not have properly
> understood in congestion avoidance modules (especially
> how to get down to the received IP header for received
> TTL values or to the routing protocols).

Use RTT instead. RTT reflects dynamic state of the link.
With TTL you only know the value after routers decremented
not initial value of other side.  Residual TTL (min/max/avg)
could be tracked but it doesn't seem that changes in TTL would
correlate with better worse RTT.

It might be able to do some nmap style heuristics and get a value from received
packets, but that would be fragile and not standards compliant

> Regarding dupacks, after a full week of studying the
> code and another week of implementing most of the
> principles described in the said paper, I would like
> some confirmation : it seems like the field
> tp->sacked_out is accounting for them in a SACKless
> connection (in tcp_fastretrans_alert()). Can I without
> a doubt rely on it to adjust TCP's behavior? If so,
> can I check is the state is TCP_CA_Disorder and then
> the value of sacked_out in order to adjust my behavior
> once 3 duplicate acks have been received, or is there
> a better way to do it?
> I'm sorry if this sounds like a dumb question, but I
> want to make sure, as I'm no expert.
> 
> 
> Thanks a lot.
> 
> 
> 
> Pierre Capillon
> 
> 
