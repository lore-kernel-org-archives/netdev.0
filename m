From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Tue, 15 Oct 2013 16:58:34 -0700
Message-ID: <1381881514.2045.82.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131010063301.GO7660@secunet.com>
	 <20131011.150124.527914076255487526.davem@davemloft.net>
	 <20131015073020.GV7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:52970 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759606Ab3JOX6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 19:58:42 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so134737pab.8
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 16:58:41 -0700 (PDT)
In-Reply-To: <20131015073020.GV7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-15 at 09:30 +0200, Steffen Klassert wrote:

> Right, that's why I've limited the queue to 100 packets. We can
> queue the SYNs of up to 100 tcp connestions that want to use
> this IPsec state. It surely can happen that we queue multiple
> retransmitted SYNs if the IPsec resolution is slow. But the
> queueing code tries at least to get the packets out before
> the first tcp retransmit. I think there is still room for
> optimizations, maybe reducing the queue lenght or the queue
> timeout to avoid queueing retransmitted SYNs as much as possible.

Note that its totally possible to avoid retransmitting SYN if original
SYN is still in a host queue.

We currently increment a SNMP counter when we detect this, we could
do something else (like not queuing a copy of the packet)

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=0e280af026a5662ffd57c4e623b822df1f7f47ff

Another work in progress is to delay RTO arming at the time TCP
packet leaves the host queues, instead of at the enqueue time.
