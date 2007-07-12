From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 02:37:10 -0700 (PDT)
Message-ID: <20070712.023710.36923635.davem@davemloft.net>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: noboru.obata.ar@hitachi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751369AbXGLJhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 05:37:12 -0400
In-Reply-To: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Date: Thu, 12 Jul 2007 16:15:10 +0900 (JST)

> 1. Network device layer detects a failure first and switch to a
>    backup device (say, in 20sec).
> 
> 2. TCP layer timeout & retransmission comes next, _hopefully_
>    before the application layer timeout.
> 
> 3. Application layer detects a network failure last (by, say,
>    30sec timeout) and may trigger a system-level failover.
> 
>    * Note 1.  The timeouts for #1 and #2 are handled
>      independently and there is no relationship between them.
> 
>    * Note 2.  The actual timeout settings (20sec or 30sec in
>      this example) are often determined by systems requirement
>      and so setting them to certain "safe values" (if any) are
>      usually not possible.
> 
> If TCP retransmission misses the time frame between event #1
> and #3 in Background above (between 20 and 30sec since network
> failure), a failure causes the system-level failover where the
> network-device-level failover should be enough.

I'm still totally unconvinced, this seems pointless.

TCP's timeouts are perfectly fine, and the only thing you
might be showing above is that the application timeouts
are too short or that TCP needs notifications.

I am totally unconvinced about your dom0 vs. domU notification
arguments as well.
