From: David Miller <davem@davemloft.net>
Subject: Re: How do I use multiqueue tx
Date: Tue, 03 Jun 2008 09:10:38 -0700 (PDT)
Message-ID: <20080603.091038.208527273.davem@davemloft.net>
References: <4845647A.7060002@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54302
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752086AbYFCQKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 12:10:42 -0400
In-Reply-To: <4845647A.7060002@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Tue, 03 Jun 2008 11:34:18 -0400

> I've done a patch to myri10ge which enables the use of multiple
> transmit queues in our Linux driver using CONFIG_NETDEVICES_MULTIQUEUE
> netdev subqueues.  Our current hardware uses multiple queues purely
> for increasing host parallelism, not priority/QOS.  I'm looking for a
> way, beyond pktgen, to actually use any transmit queue other than 0 to
> increase parallelism.

Even though there are seperate per-TX-queue start/stop states
available to manage, all of the transmit path still uses a
single global lock to manage the packet queue in the generic
device structure.

So you will get zero extra parallelism by using the other queues.

I plan to work on this and have presented my ideas about how to
solve this problem in two presentations I gave in Japan several
months ago, and last week in Berlin.

http://vger.kernel.org/~davem/davem_tokyo08.pdf
http://vger.kernel.org/~davem/davem_berlin08.pdf

Don't even bother trying to get better TX parallelism at the
current time, it'll be so much easier to accomplish after
I do this development which I anticipate should be in a testable
state in about one month.
