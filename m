From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/13]: Finish basic TX multiqueue functionality.
Date: Thu, 10 Jul 2008 03:55:58 -0700 (PDT)
Message-ID: <20080710.035558.98940761.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753758AbYGJK4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 06:56:00 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D9104C8C17F
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 03:55:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've respun the rest of the TX multiqueue patches
in a tree cloned off of current net-next-2.6:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-tx-2.6.git

Thanks to Johannes Berg I was able to get the WME/QOS mac80211
bits at least basically tested and without the lockups he saw
last time.  That's a good sign.

The most important patch is patch number 5.  That's where
the bulk of the tree and the existing multiqueue drivers
transition completely to the new interfaces.

It looks like a lot, but that patch really need to contain all of
those bits all at once.  There is no other way to sequence it.
The full transition request going from:

	netif_*_queue() flow controls all queues
	netif_*_subqueue() flow controls individual queues

to just:

	netif_tx_*_queue() flow controls individual queues

If you just convert the core networking, the multiqueue drivers
break.  Whereas if you just convert the drivers, this breaks them
too :)

During the upheaval I temporarily mark the mac80211 QoS bits
as broken, then in patch 9 it all gets converted properly and
re-enabled.

So, what's left?  The qdisc config semantics.  I still need to
sort that out and pretty much that's what I'll be working on the
next few days.

This has been allmodconfig build tested on sparc64, basic multiqueue
has been tested with NIU driver, non-multiqueue is tested using
tg3 on my 2-cpu workstation, and Johannes gave mac80211 a little
bit of usage.
