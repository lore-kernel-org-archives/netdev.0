From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] niu: fix SMP race protecting rx_rings and tx_rings
Date: Thu, 03 Feb 2011 15:22:14 -0800 (PST)
Message-ID: <20110203.152214.59684545.davem@davemloft.net>
References: <1296758717-18406-1-git-send-email-fleitner@redhat.com>
	<20110203.142145.183054407.davem@davemloft.net>
	<20110203231805.GA3710@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752227Ab1BCXVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 18:21:38 -0500
In-Reply-To: <20110203231805.GA3710@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Thu, 3 Feb 2011 21:18:05 -0200

> Ok, I can write a new version using RCU if you like.

Don't worry, I'll take care of it, I actually have the
hardware to test on :-)

> I've chose rwsem because I think those operations aren't
> frequent. The RCU leaves an operation to run later during
> a safe context, so I thought the cost doesn't worth it.

One thing I'm worried about with your patch is that the statistics
method can be called in basically any context, therefore a sleeping
lock like the rw_semaphore is probably not usable.

In fact I'm going to revert your patch for now because of this issue.
