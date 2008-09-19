From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Fri, 19 Sep 2008 13:29:51 -0700 (PDT)
Message-ID: <20080919.132951.46369136.davem@davemloft.net>
References: <20080918.023614.193687634.davem@davemloft.net>
	<31089112.38051221843450562.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jens.axboe@oracle.com, netdev@vger.kernel.org,
	nickpiggin@yahoo.com.au, ilpo.jarvinen@helsinki.fi
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754237AbYISUaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 16:30:03 -0400
In-Reply-To: <31089112.38051221843450562.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Fri, 19 Sep 2008 09:57:30 -0700 (PDT)

> I wonder if the added overhead of local_irq_disable/local_irq_enable is
> killing any performance gain. Certainly it adds more latency to a sensitive code path.
> 
> Is there a good lock-less solution?

The cross-cpu IPI is 1,000 times more expensive than the local IRQ
enable/disable (on x86 it's a bunch of APIC programming), so if you're
looking for cost analysis start there.
