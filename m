From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] NET: Multiple queue network device support
Date: Mon, 26 Feb 2007 17:03:17 -0800 (PST)
Message-ID: <20070226.170317.41636240.davem@davemloft.net>
References: <20070209000942.5155.78998.stgit@gitlost.site>
	<20070209000950.5155.24763.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	jesse.brandeburg@intel.com, auke@foo-projects.org,
	john.ronciak@intel.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35409
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965150AbXB0BDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 20:03:19 -0500
In-Reply-To: <20070209000950.5155.24763.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Thu, 08 Feb 2007 16:09:50 -0800

> From: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> Added an API and associated supporting routines for multiqueue network
> devices.  This allows network devices supporting multiple TX queues to
> configure each queue within the netdevice and manage each queue
> independantly.  Changes to the PRIO Qdisc also allow a user to map
> multiple flows to individual TX queues, taking advantage of each queue
> on the device.
> 
> Signed-off-by: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Thanks for posting this.

I was wonding if it would be better to have the ->enqueue() perform
the mapping operation, store the queue index selected inside of the
skb, and just use the normal ->hard_start_xmit() to send the packet
out?

The only thing to take care of is the per-queue locking, but that
should be easily doable.

We might be able to do this even without making sk_buff any larger.
For example, I suppose skb->priority might be deducable down to
a u16.  After a quick audit I really cannot see any legitimate use
of anything larger than 16-bit values, but a more thorough audit
would be necessary to validate this.

