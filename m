From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Fri, 12 Sep 2008 18:40:08 -0700 (PDT)
Message-ID: <20080912.184008.74354363.davem@davemloft.net>
References: <20080913011018.GA10242@gondor.apana.org.au>
	<20080912.182259.238925690.davem@davemloft.net>
	<20080913012758.GA10459@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38560
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755373AbYIMBkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 21:40:14 -0400
In-Reply-To: <20080913012758.GA10459@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 12 Sep 2008 18:27:58 -0700

> On Fri, Sep 12, 2008 at 06:22:59PM -0700, David Miller wrote:
> > And then there are all of these complicated pieces of state the
> > classful qdiscs modify when a SKB is removed from their visibility.
> > So, the unlink isn't just a simple list delete operation.  There
> > are queue lengths that need to be updated, watchdog timers to
> > manage, etc.
> 
> The decision really comes down to whether it's harder to requeue
> a seemingly arbitrary packet or whether it's harder to dequeue the
> packet that was last peeked.

My current opinion is that both operations are equally difficult.
With the slight advantage for ->requeue() because all the complicated
logic is already implemented :-)
