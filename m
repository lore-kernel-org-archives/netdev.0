From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Tue, 08 May 2007 19:05:06 -0700 (PDT)
Message-ID: <20070508.190506.85687854.davem@davemloft.net>
References: <20070508073132.17547.68502.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54841
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S967364AbXEICFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 22:05:05 -0400
In-Reply-To: <20070508073132.17547.68502.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Tue, 08 May 2007 13:01:32 +0530

> Optimize return value of qdisc_restart so that it is not called an
> extra time if there are no more packets on the queue to be sent out.
> It is also not required to check for gso_skb (though the lock is
> dropped) since another cpu which added this would have done a
> netif_schedule.
> 
> Patch against net-2.6.22.git
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

<0 return value here means that the queue is not empty, and the device
is throttled.  If you want to do this, just branch down to the end of
the function which asserts that q->q.qlen is not negative, and returns
it.

That will achieve the right effect.

But I'm not so sure about this idea, I have this strange feeling that
we do things this way for a reason... Hmmm...
