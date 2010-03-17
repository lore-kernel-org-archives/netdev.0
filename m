From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] 3c59x: Acquire vortex lock instead of disabling irq
Date: Wed, 17 Mar 2010 11:03:20 -0700 (PDT)
Message-ID: <20100317.110320.15445884.davem@davemloft.net>
References: <1268836396-23943-1-git-send-email-chase.douglas@canonical.com>
	<1268836396-23943-2-git-send-email-chase.douglas@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chase.douglas@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57173
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755286Ab0CQSC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 14:02:58 -0400
In-Reply-To: <1268836396-23943-2-git-send-email-chase.douglas@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chase Douglas <chase.douglas@canonical.com>
Date: Wed, 17 Mar 2010 10:33:16 -0400

> Last year, threaded IRQ handlers were introduced to the mainline kernel.
> This change requires the disable_irq function to sleep if any IRQ
> handler threads for a given IRQ line are running.
> 
> Back in 2006, while working on the -rt patch set that had threaded IRQ
> handlers, the vortex_timer function was causing scheduling bugs because
> it is run in softirq context and called disable_irq. This patch was the
> best fix determined at the time, and still exists in the .33 -rt
> patchset. Now that threaded IRQ handlers are present in the mainline
> kernel we need to apply the patch there as well.
> 
> http://lkml.org/lkml/2006/5/12/178
> 
> BugLink: http://bugs.launchpad.net/bugs/533335
> 
> Signed-off-by: Chase Douglas <chase.douglas@canonical.com>

This code is very much intentionally using disable_irq*().

The operation being performed here is extremely expensive,
and during that time if we have cpu interrupts disabled
serial devices will drop characters etc.
