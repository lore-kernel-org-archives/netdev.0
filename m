From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.27] tcp_vegas cong avoid fix
Date: Tue, 09 Dec 2008 00:13:38 -0800 (PST)
Message-ID: <20081209.001338.157454265.davem@davemloft.net>
References: <20081205164743.GB18146@scriptng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: doug.leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753266AbYLIINh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 03:13:37 -0500
In-Reply-To: <20081205164743.GB18146@scriptng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <doug.leith@nuim.ie>
Date: Fri, 5 Dec 2008 16:47:43 +0000

> This patch addresses a book-keeping issue in tcp_vegas.c.   At present tcp_vegas
> does separate book-keeping of cwnd based on packet sequence numbers.  A mismatch can develop between this
> book-keeping and tp->snd_cwnd due, for example, to delayed acks acking
> multiple packets.  When vegas transitions to reno operation (e.g. following
> loss), then this mismatch leads to incorrect behaviour (akin to a cwnd
> backoff).  This seems mostly to affect operation at low cwnds where delayed acking can 
> lead to a significant fraction of cwnd being covered by a single ack, leading to the 
> book-keeping mismatch.  This patch modifies the congestion avoidance update to avoid 
> the need for separate book-keeping while leaving vegas congestion avoidance functionally 
> unchanged.  A secondary advantage of this modification is that the use of fixed-point 
> (via V_PARAM_SHIFT) and 64 bit arithmetic is no longer necessary, simplifying the code.
> 
> Some example test measurements with the patched code (confirming no functional
> change in the congestion avoidance algorithm) can be seen at:
> 
> http://www.hamilton.ie/doug/vegaspatch/
> 
> 
> Signed-off-by:  Doug Leith <doug.leith@nuim.ie>

Applied, thanks a lot Doug.

> --- net/ipv4/tcp_vegas.c.orig	2008-12-04 23:51:19.000000000 +0000
> +++ net/ipv4/tcp_vegas.c	2008-12-05 15:04:11.000000000 +0000

I remember asking you to -p1 root your patches last time,
or did I? :-)
