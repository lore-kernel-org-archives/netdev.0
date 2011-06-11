From: Joris van Rantwijk <joris@jorisvr.nl>
Subject: Question about LRO/GRO and TCP acknowledgements
Date: Sat, 11 Jun 2011 21:59:19 +0200
Message-ID: <20110611215919.5fc29c27@konijn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr18.xs4all.nl ([194.109.24.38]:2664 "EHLO
	smtp-vbr18.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab1FKUMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 16:12:02 -0400
Received: from konijn (vertex.xs4all.nl [82.95.239.45])
	by smtp-vbr18.xs4all.nl (8.13.8/8.13.8) with ESMTP id p5BJxKE5070568
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 11 Jun 2011 21:59:26 +0200 (CEST)
	(envelope-from joris@jorisvr.nl)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to understand how Linux produces TCP acknowledgements
for segments received via LRO/GRO.

As far as I can see, the network driver uses GRO to collect several
received packets into one big super skb, which is then handled
during just one call to tcp_v4_rcv(). This will eventually result
in the sending of at most one ACK packet for the entire GRO packet.

Conventional wisdom (RFC 5681) says that a receiver should send at
least one ACK for every two data segments received. The sending TCP
needs these ACKs to update its congestion window (e.g. slow start).

It seems to me that the current implementation in Linux may send
just one ACK for a large number of received segments. This would
be a deviation from the standard. As a result the congestion
window of the sender would grow much slower than intended.

Maybe I misunderstand something in the network code (likely).
Could someone please explain me how this ACK issue is handled?

Thanks,
Joris van Rantwijk.
