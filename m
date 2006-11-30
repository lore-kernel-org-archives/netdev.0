From: Wenji Wu <wenji@fnal.gov>
Subject: RE: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 10:08:22 -0600
Message-ID: <HNEBLGGMEGLPMPPDOPMGMEAMCGAA.wenji@fnal.gov>
References: <20061129.181950.31643130.davem@davemloft.net>
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:2951 "EHLO mailgw2.fnal.gov")
	by vger.kernel.org with ESMTP id S967828AbWK3QMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 11:12:44 -0500
In-reply-to: <20061129.181950.31643130.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



>We can make explicitl preemption checks in the main loop of
>tcp_recvmsg(), and release the socket and run the backlog if
>need_resched() is TRUE.

>This is the simplest and most elegant solution to this problem.


I am not sure whether this approach will work. How can you make the explicit
preemption checks?



For Desktop case, yes, you can make the explicit preemption checks at some
points whether need_resched() is true. But when need_resched() is true, you
can not decide whether it is triggered by higher priority processes becoming
runnable, or the process within tcp_recvmsg being expiring.


If the higher prioirty processes become runnable (e.g., interactive
process), you better yield the CPU, instead of continuing this process. If
it is the case that the process within tcp_recvmsg() is expriring, then, you
can continue the process to go ahead to process backlog.

For Low-latency Desktop case, I believe it is very hard to make the checks.
We do not know when the process is going to expire, or when higher priority
process will become runnable. The process could expire at any moment, or
higher priority process could become runnnable at any moment. If we do not
want to tradeoff system responsiveness, where do you want to make the check?
If you just make the chekc, then need_resched() become TRUE, what are you
going to do in this case?

wenji




