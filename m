From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 04:43:44 +0100
Message-ID: <1307850224.22348.626.camel@localhost>
References: <20110611215919.5fc29c27@konijn>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joris van Rantwijk <joris@jorisvr.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.globalsuite.net ([69.46.103.200]:51962 "EHLO
	mail.globalsuite.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab1FLEno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 00:43:44 -0400
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

This was a problem in older versions of Linux (and still is on other
network stacks that aren't aware of LRO).

> Maybe I misunderstand something in the network code (likely).
> Could someone please explain me how this ACK issue is handled?

LRO implementations (and GRO) are expected to put the actual segment
size in skb_shared_info(skb)->gso_size on the aggregated skb.  TCP will
then use that rather than the aggregated payload size when deciding
whether to defer an ACK.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

