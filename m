From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] gianfar: Fix crashes on RX path
Date: Tue, 26 Oct 2010 23:20:42 +0200
Message-ID: <20101026212042.GA1888@del.dom.local>
References: <1287727917.9059.117.camel@edumazet-laptop>
 <20101022065231.GA7036@ff.dom.local>
 <20101022085248.GA8571@ff.dom.local>
 <20101026.104257.245396217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, eminak71@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, avorontsov@mvista.com,
	afleming@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33742 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080Ab0JZVUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 17:20:49 -0400
Received: by wyf28 with SMTP id 28so5130359wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 14:20:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101026.104257.245396217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 10:42:57AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 22 Oct 2010 08:52:48 +0000
> 
> > On Fri, Oct 22, 2010 at 06:52:31AM +0000, Jarek Poplawski wrote:
> >> On Fri, Oct 22, 2010 at 08:11:57AM +0200, Eric Dumazet wrote:
> > ...
> >> > Gianfar claims to be multiqueue, but only one cpu can run gfar_poll()
> >> > and call gfar_clean_tx_ring() / gfar_clean_rx_ring()
> >> > 
> >> > If not, there would be more bugs than only rx_recycle thing
> >> 
> >> I didn't find what prevents running gfar_poll on many cpus and don't
> >> claim there is no more bugs around.
> > 
> > On the other hand, I don't see your point in the code below either.
> > These're only per gfargrp queues - not per device, aren't they?
> 
> I am still not at the point where I feel confortable applying this bug
> fix, in fact I am very far from that.
> 
> None of the logic is consistent in what we are saying causes the
> problem.
> 
> Anything that would make the RX recycling code racy and corrupt
> recycling queue of the gianfar driver, would also corrupt all of the
> other RX side and other driver state.
> 
> The NAPI state is unary for gianfar, and inside of that singular
> ->poll() instance it iterates over the queues.

IMHO, the NAPI state is unary only for gfargrp, and multiple ->poll()
instances share a (unary) rx_recycle queue without proper locking.

Thanks,
Jarek P.
