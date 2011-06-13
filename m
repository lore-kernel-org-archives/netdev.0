From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Mon, 13 Jun 2011 10:34:46 -0700
Message-ID: <1307986486.8149.3292.camel@tardy>
References: <20110611215919.5fc29c27@konijn>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joris van Rantwijk <joris@jorisvr.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:19642 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab1FMReu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 13:34:50 -0400
In-Reply-To: <20110611215919.5fc29c27@konijn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-06-11 at 21:59 +0200, Joris van Rantwijk wrote:
> Hi,
> 
> I'm trying to understand how Linux produces TCP acknowledgements
> for segments received via LRO/GRO.
> 
> As far as I can see, the network driver uses GRO to collect several
> received packets into one big super skb, which is then handled
> during just one call to tcp_v4_rcv(). This will eventually result
> in the sending of at most one ACK packet for the entire GRO packet.
> 
> Conventional wisdom (RFC 5681) says that a receiver should send at
> least one ACK for every two data segments received. The sending TCP
> needs these ACKs to update its congestion window (e.g. slow start).
> 
> It seems to me that the current implementation in Linux may send
> just one ACK for a large number of received segments. This would
> be a deviation from the standard. As a result the congestion
> window of the sender would grow much slower than intended.
> 
> Maybe I misunderstand something in the network code (likely).
> Could someone please explain me how this ACK issue is handled?

FWIW, HP-UX and Solaris stacks (perhaps others) have had ACK-avoidance
heuristics in place since the mid to late 1990's, and the ACK-avoidance
of LRO/GRO is quite similar "on the wire."  Have those heuristics been
stellar?  Probably not, but they've not it seems caused massive
problems, and when one has TSO and LRO/GRO the overhead of
ACK-every-other-MSS processing becomes non-trivial.  Even more so when
copy-avoidance is present.

I'd go with increase by the bytes ACKed not the ACK count.

rick jones

