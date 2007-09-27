From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Make TCP prequeue configurable
Date: Thu, 27 Sep 2007 16:09:29 -0700 (PDT)
Message-ID: <20070927.160929.104050247.davem@davemloft.net>
References: <46FC29E1.9010809@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57900
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758673AbXI0XJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 19:09:29 -0400
In-Reply-To: <46FC29E1.9010809@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 28 Sep 2007 00:08:33 +0200

> 1) It adds 48 bytes per 'struct tcp_sock'
> 2) It adds some ugly code in hot paths
> 3) It has a small hit ratio on typical servers using many sockets
> 4) It may have a high hit ratio on UP machines running one process,
>     where the prequeue adds litle gain. (In fact, letting the user
>     doing the copy after being woke up is better for cache reuse)
> 5) Doing a copy to user in softirq handler is not good, because of
>     potential page faults :(
> 6) Maybe the NET_DMA thing is the only thing that might need prequeue.

If you want to make changes at least get your facts straight in your
changelog message :-)

The prequeue doesn't do copies in softirqs, it acquires the user side
socket lock and runs the packet input path directly from there,
copying into userspace along the way.

You are making claims about performance based upon your understanding
of the code and your understanding of typical workloads, rather than
from actual measurements.  In scientific communities this would make
you a quack at best :-)
