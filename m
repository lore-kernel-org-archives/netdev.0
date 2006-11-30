From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Wed, 29 Nov 2006 18:19:50 -0800 (PST)
Message-ID: <20061129.181950.31643130.davem@davemloft.net>
References: <2f14bf623344.456de60a@fnal.gov>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:31631
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S936133AbWK3CTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 21:19:51 -0500
To: wenji@fnal.gov
In-Reply-To: <2f14bf623344.456de60a@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wenji Wu <wenji@fnal.gov>
Date: Wed, 29 Nov 2006 19:56:58 -0600

> >We could also pepper tcp_recvmsg() with some very carefully placed
> >preemption disable/enable calls to deal with this even with
> >CONFIG_PREEMPT enabled.
>
> I also think about this approach. But since the "problem" happens in
> the 2.6 Desktop and Low-latency Desktop (not server), system
> responsiveness is a key feature, simply placing preemption
> disabled/enable call might not work.  If you want to place
> preemption disable/enable calls within tcp_recvmsg, you have to put
> them in the very beginning and end of the call. Disabling preemption
> would degrade system responsiveness.

We can make explicitl preemption checks in the main loop of
tcp_recvmsg(), and release the socket and run the backlog if
need_resched() is TRUE.

This is the simplest and most elegant solution to this problem.

The one suggested in your patch and paper are way overkill, there is
no reason to solve a TCP specific problem inside of the generic
scheduler.
