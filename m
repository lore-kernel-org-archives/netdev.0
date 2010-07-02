From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Generic rx-recycling and emergency skb pool
Date: Fri,  2 Jul 2010 21:20:13 +0200
Message-ID: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41195 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751728Ab0GBTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 15:20:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is version two of generic rx-recycling followed by version one of
emergency skb pools which are built on top of rx-recycling.
The change from v1 of generic rx-recycling is that the list access is
unlocked instead of locked.
Patch six which introduces the emergency pools adds the locking back.
This is required since we now have two not serialized users. In order
not to punish everyone patch eight removes this locking again. That
patch converts only two drivers so you have an idea what I think is
required to get the locking removed.

The idea behind emergency pools is to have pre-allocated skbs for TX and
RX. Using the memory allocator for it leads to latencies during memory
pressure. The pre-allocated skb are "tagged" and should get back to the
pool once they are through the stack so the pool should never get
exhausted.

While it was easy to convert the drivers which share the same concept of
rx-recycling to use the emergency pools it was difficult to hook up the
more complex drivers like e1000e. The e1000e can use split skbs / a frag
list which is different from the allocation currently used. So instead of
forcing all drivers to use the same way of doing things I've been thinking
about providing a dedicated callback for skb allocation and checking if
this skb is "good enough". This is not yet implemented.

I would be glad to receive some feedback on this patch series before I go
any further. Unfortunately I'm on vacation for the next two weeks so I
can't respond earlier. tglx is on Cc and should be able respond earlier :)

Sebastian
