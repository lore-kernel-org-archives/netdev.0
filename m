From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 15:27:51 -0700 (PDT)
Message-ID: <20080625.152751.154176346.davem@davemloft.net>
References: <20080625141511.GH22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	netdev@vger.kernel.org
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56638
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753568AbYFYW1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 18:27:51 -0400
In-Reply-To: <20080625141511.GH22981@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 25 Jun 2008 10:15:11 -0400

> 
> Globally disable the interrupt during netpoll rather than simply
> disabling it on the hardware.  This will ensure all pending operations
> are complete and no more will execute.  I've seen reports of deadlocks
> with the current driver and this patch resolves them.

I don't want to see network drivers start getting into the habit
of doing this.  This operation could be extremely expensive with
certain IRQ controllers.

It's better to have a good understanding of why the deadlocks
happen, and this was decidedly missing from your commit message.

NAPI is designed in such a way that if pending interrupts arrive
after NAPI disables chip interrupts it should be handled just
fine and in fact I see this happen all the time on some of my
test systems.
