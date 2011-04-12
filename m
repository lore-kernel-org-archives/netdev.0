From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_emac: fix spinlock bug with dma channel
 cleanup
Date: Tue, 12 Apr 2011 14:33:29 -0700 (PDT)
Message-ID: <20110412.143329.59682750.davem@davemloft.net>
References: <1302583351-10449-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43513
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932568Ab1DLVeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 17:34:04 -0400
In-Reply-To: <1302583351-10449-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriramakrishnan A G <srk@ti.com>
Date: Tue, 12 Apr 2011 10:12:31 +0530

> The DMA cleanup function was holding the spinlock across
> a busy loop where it waits for HW to indicate teardown is complete.
> This generates a backtrace, when DEBUG_SPINLOCK is enabled. Make the
> locking more granular.
> 
> Signed-off-by: Sriramakrishnan A G <srk@ti.com>

You can't really sleep in this function at all.

For example, it gets invoked from the ->ndo_tx_timeout() method in
davinci_emac.c, which runs from a timer.

So even if you hack the spinlock usage, there are still major issues
here.

We could conditionalize the timeout handling, but I don't think so
much complexity is worth it here.

Just do a udelay()/mdelay() or similar, instead of the timed sleeps.

Thanks.
