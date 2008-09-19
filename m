From: David Miller <davem@davemloft.net>
Subject: multiqueue interrupts...
Date: Thu, 18 Sep 2008 19:38:15 -0700 (PDT)
Message-ID: <20080918.193815.175549834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753268AbYISCi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 22:38:27 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4F42FC8C181
	for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 19:38:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


During kernel summit I was speaking with Arjan van de Ven
about irqbalanced and networking card multiqueue interrupts.

In order for irqbalanaced to make smart decisions, what needs to
happen in drivers is that the individual interrupts need to be
named in such a way that he can tell by looking at /proc/interrupts
output that these interrupts are related.

I would suggest that people use something like:

	char buf[IFNAMSIZ+6];

	sprintf(buf, "%s-%s-%d",
	        netdev->name,
		(RX_INTERRUPT ? "rx" : "tx"),
		queue->index);

So on a multiqueue card with 2 RX queues and 2 TX queues we'd
have names like:

	eth0-rx-0
	eth0-rx-1
	eth0-tx-0
	eth0-tx-1

So let's make an effort to get this done right in 2.6.28 and meanwhile
Arjan can add the irqbalanced code.
