From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Tue, 08 May 2007 23:36:30 -0700 (PDT)
Message-ID: <20070508.233630.35664266.davem@davemloft.net>
References: <20070508.190506.85687854.davem@davemloft.net>
	<OF0E0FA5FB.06A0B8D0-ON652572D6.001854BA-652572D6.001943CC@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34795
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934895AbXEIGga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 02:36:30 -0400
In-Reply-To: <OF0E0FA5FB.06A0B8D0-ON652572D6.001854BA-652572D6.001943CC@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Wed, 9 May 2007 10:05:57 +0530

> This change will not change existing behavior in case there are
> packets in the queue, it will return -1 each time as does the
> original code. But when there are no packets, the original
> qdisc_restart returns -1 and the caller will unnecessarily call
> qdisc_restart which branches to the bottom and returns 0
> (qlen). This call can be avoided if we had returned 0 in the
> previous iteration.  Branching to the bottom cannot be done since it
> breaks the "packets present" case, as it will return a positive
> number and the caller will assume that the queue is throttled.

Ok, thanks for the explanation.

But this only makes sense for the second hunk you changed.

The first hunk is a bug case, an improper looping device
decapsulation condition, and we do want to always return
-1 in that case in order to break out of the loop.

Your change will make the kernel essentially hang instead
when this bug check is triggered.
