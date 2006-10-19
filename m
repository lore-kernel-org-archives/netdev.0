From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Thu, 19 Oct 2006 01:41:20 -0700 (PDT)
Message-ID: <20061019.014120.78710373.davem@davemloft.net>
References: <45371C8D.20603@cosmosbay.com>
	<20061018.235747.74746971.davem@davemloft.net>
	<200610191029.00720.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7870
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030322AbWJSIlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 04:41:21 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610191029.00720.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 19 Oct 2006 10:29:00 +0200

> Cons :
> TLB cost

For those hot x86 and x86_64 cpus you tend to be using, this
particular cost is relatively small.  :-) It's effectively like
another memory reference in the worst case, in the best case
it's "free".

> With actual somaxconn=128 limit, my patch ends in allocating less
> ram (half of a page) than current x86_64 kernel (2 pages)

Understood.  But the issue is that there are greater security
implications than before when increasing this sysctl.

To be honest, it's probably water under the bridge, because
if you can stuff up SOMAXCONN number of sockets into the
system per listening socket which is a lot more than the
hash table eats up. :-)

