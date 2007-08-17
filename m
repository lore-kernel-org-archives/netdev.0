From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] restore netdev_priv optimization
Date: Fri, 17 Aug 2007 16:56:25 -0700 (PDT)
Message-ID: <20070817.165625.23014105.davem@davemloft.net>
References: <20070817154022.0f3afba4@freepuppy.rosehill.hemminger.net>
	<20070817.160409.88475506.davem@davemloft.net>
	<20070817161928.6b6302fd@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751650AbXHQX4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 19:56:25 -0400
In-Reply-To: <20070817161928.6b6302fd@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 17 Aug 2007 16:19:28 -0700

> The subqueue is only referenced in start/stop queue and that only happens
> once per packet on normal tx, and only if multiqueue is used.

If it only happens when multiqueue, then why does loopback need
at least one queue entry there even though it's not multiqueue? :-)

This thing is deref'd regardless of multi-queue.

Once per TX packet is a lot, and it's the same amount of derefs
as dev->priv will have on the TX path.
