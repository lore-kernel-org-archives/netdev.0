From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netxen: fix tx ring accounting
Date: Thu, 18 Jun 2009 00:47:48 -0700 (PDT)
Message-ID: <20090618.004748.165979927.davem@davemloft.net>
References: <1245295645-22573-1-git-send-email-dhananjay@netxen.com>
	<1245295645-22573-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756859AbZFRHro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:47:44 -0400
In-Reply-To: <1245295645-22573-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed, 17 Jun 2009 20:27:25 -0700

> This forces every update of tx ring producer to check for
> availability of space for next full TSO command. Earlier
> firmware control commands didn't care to pause tx queue.
> 
> Stop the tx queue if there's not enough space to transmit one full
> LSO command left on the tx ring after current transmit. This avoids
> returning NETDEV_TX_BUSY after checking distance between producer
> and consumer on every cpu.
> 
> Restart the tx queue only if we have cleaned up enough tx
> descriptors.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied, thanks.

At some point you really should audit the queue vs. carrier
state handling.  There is absolutely no reason to conditionally
do queue waking based upon carrier state.  Yet I see such
tests here and there in this driver.

It is the core networkings job to seal off sending packets when
the carrier goes down, and that's exactly what it does.
