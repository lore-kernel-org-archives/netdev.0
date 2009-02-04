From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: BUG: NIU driver: strange issues with multicast "UDP: short
	packet"
Date: Wed, 04 Feb 2009 10:32:06 +0100
Message-ID: <1233739926.20497.78.camel@localhost.localdomain>
References: <1233668300.20497.49.camel@localhost.localdomain>
	 <20090203.153853.163818774.davem@davemloft.net>
	 <1233737704.20497.70.camel@localhost.localdomain>
	 <20090204.010029.12969718.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:49428 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbZBDJcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 04:32:09 -0500
In-Reply-To: <20090204.010029.12969718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 01:00 -0800, David Miller wrote:
> From: Jesper Dangaard Brouer <jdb@comx.dk>
> Date: Wed, 04 Feb 2009 09:55:04 +0100
> 
> > On Tue, 2009-02-03 at 15:38 -0800, David Miller wrote:
> > > From: Jesper Dangaard Brouer <jdb@comx.dk>
> > > Date: Tue, 03 Feb 2009 14:38:20 +0100
> > > 
> > > >   UDP: short packet: From 81.161.2.106:0 44063/1324 to 233.123.173.7:0
> > > >   UDP: short packet: From 81.161.2.106:0 44063/1324 to 233.123.173.7:0
> > > >   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
> > > >   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
> > > >   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
> > > >   UDP: short packet: From 81.161.2.106:8304 27493/1324 to 233.123.173.7:24931
> > > 
> > > The UDP header length field is garbage in all of these packets.
> > 
> > Yes, but this only happens on the NIU/netpune NIC.  I works with the igb
> > driver, I have both a 82575 and a 82576 NIC.
> 
> Right, and what's unique about NIU is that NIU won't prepull
> the protocol headers into the linear area on receive.

So thats the difference...

> At the point when IPMR is dealing with potentially forwarding
> the frame, the UDP headers aren't yet pulled into the linear
> area.  UDP input will do that with it's pskb_may_pull() call.

Can I get a little code hint, where IPMR is dealing with potentially
forwarding the frame?

> I think this is the critical bit, and some part of the IPMR
> code makes assumptions about all of the protocol headers being
> pulled into the linear SKB area when it executes.
> 
> I really don't have time to track this down, so what I suggest
> you do is add logging to UDP multicast packets at various
> locations looking for the UDP header length in the paged SKB
> area to go illegal.  Move your probe points around to narrow
> down the culprit.

Is there an easy way to test if the packet is corrupted?
Can you recomment a way to test it?


> Good luck.

Thanks I'm going to need it ;-)

Thanks for you quick answer.
-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
