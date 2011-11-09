From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] neigh: replace unres_qlen by unres_qlen_bytes
Date: Tue, 8 Nov 2011 17:05:42 -0800
Message-ID: <20111108170542.18595c52@nehalam.linuxnetplumber.net>
References: <1320783085.2588.17.camel@edumazet-laptop>
	<20111108.172448.2101648110512252549.davem@davemloft.net>
	<1320792301.26025.21.camel@edumazet-laptop>
	<20111108.174820.558780148839093199.davem@davemloft.net>
	<1320797656.26025.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52337 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190Ab1KIBFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 20:05:45 -0500
In-Reply-To: <1320797656.26025.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Nov 2011 01:14:16 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> [PATCH V2 net-next] neigh: replace unres_qlen by unres_qlen_bytes
> 
> unres_qlen is the number of frames we are able to queue per unresolved
> neighbour. Its default value (3) was never changed and is responsible
> for strange drops, especially if IP fragments are used, or multiple
> sessions start in parallel. TCP initial congestion window is now bigger
> than 3.

I don't understand this argument.
TCP won't send data until the initial SYN is acked. And the SYN can't
be sent until the ARP is resolved.

The only use case for this is for applications that open lots of connections
to the same destination as once (a.k.a TCP accelerators) to get around
TCP slow start.
