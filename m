From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: BUG: NIU driver: strange issues with multicast "UDP: short
	packet"
Date: Thu, 05 Feb 2009 13:44:00 +0100
Message-ID: <1233837840.20497.129.camel@localhost.localdomain>
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
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56294 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbZBEMoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 07:44:04 -0500
In-Reply-To: <20090204.010029.12969718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 01:00 -0800, David Miller wrote:
> > Yes, but this only happens on the NIU/netpune NIC.  I works with the
> igb
> > driver, I have both a 82575 and a 82576 NIC.
> 
> Right, and what's unique about NIU is that NIU won't prepull
> the protocol headers into the linear area on receive.
> 
> At the point when IPMR is dealing with potentially forwarding
> the frame, the UDP headers aren't yet pulled into the linear
> area.  UDP input will do that with it's pskb_may_pull() call.

I think I have found the problem.  And its actually due to the
pskb_may_pull() call in net/ipv4/udp.c:__udp4_lib_rcv().

pskb_may_pull() may alter the SKB and a pointer to the UDP header was
stored before the pskb_may_pull() call.

I'll send a patch...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
