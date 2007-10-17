From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: avoid race between netpoll and network fast path
Date: Tue, 16 Oct 2007 21:06:13 -0700 (PDT)
Message-ID: <20071016.210613.71104656.davem@davemloft.net>
References: <47158540.7000709@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, netdev@vger.kernel.org
To: tina.yang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47511
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750708AbXJQEGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 00:06:06 -0400
In-Reply-To: <47158540.7000709@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tina Yang <tina.yang@oracle.com>
Date: Tue, 16 Oct 2007 20:45:04 -0700

> The current netpoll design and implementation has serveral race issues with the
> network fast path that panics/hangs the system or causes interface timeout/reset
> but the fix is likely to have impact on the overall system performance and could
> involve a large number of drivers.  The proposal is to disable the problem code
> for normal operations but only to enable it at the time of crash in case polling
> is necessary.  Tests that have been done included the bug fix verification
> as well as regression check on the netlog results in various crash modes.
> 
> Signed-off-by: Tina Yang <tina.yang@oracle.com>

This is at best a kludge, and it's the wrong way to approach this problem.

Fix the bug, and fix it right.

If you disable that stretch of code, what you've done is make the
netpoll code hang and/or drop console messages if the TX queue is full
in the driver and the only way to liberate TX space is to call into
->poll().

You haven't shown the precise race that leads to corruption so that someone
so motivated can guide you towards a more correct fix if you are not
capable of implementing it properly on your own.
