From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sat, 20 Sep 2008 13:00:58 -0700 (PDT)
Message-ID: <20080920.130058.90080260.davem@davemloft.net>
References: <1221924561.1343.121.camel@localhost.localdomain>
	<20080920084512.58f7fb08@infradead.org>
	<1221926529.1343.140.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: dwalker@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751492AbYITUBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 16:01:10 -0400
In-Reply-To: <1221926529.1343.140.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walker <dwalker@mvista.com>
Date: Sat, 20 Sep 2008 09:02:09 -0700

> In the case of networking and block I would think a lot of the softirq
> activity is asserted from userspace.. Maybe the scheduler shouldn't be
> migrating these tasks, or could take this softirq activity into
> account ..

Absolutely wrong.

On a per-flow basis you want to push the work down as far
as possible down to individual cpus.  Why do you think the
hardware folks are devoting silicon to RX multiqueue facilities
that spread the RX work amongst available cpus using MSI-X?
