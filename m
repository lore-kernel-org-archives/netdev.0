From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Tx queue selection
Date: Tue, 27 Jul 2010 20:51:07 +1000
Message-ID: <1280227867.1970.208.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38653 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755664Ab0G0KvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 06:51:11 -0400
Received: from [IPv6:::1] (localhost.localdomain [127.0.0.1])
	by gate.crashing.org (8.14.1/8.13.8) with ESMTP id o6RAp84b013448
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 05:51:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks !

I'm putting my newbie hat on ... :-)

While looking at our ehea driver (and in fact another upcoming driver
I'm helping with), I noticed it's using the "old style" multiqueue. IE.
It doesn't use the alloc_netdev_mq() variant, creates one queue on the
linux side, an makes its own selection of HW queue in start_xmit.

This had many drawbacks, obviously, such as not getting per-queue locks
etc...

Now, the mechanics of converting that to the new scheme are easy enough
to figure out by reading the code. However, where my lack of networking
background fails me is when it comes to the policy of choosing a Tx
queue.

ehea uses its own hash of the header, different from the "default" queue
selection in the net core. Looking at other drivers such as ixgbe, I see
that it can chose to use smp_processor_id() when a flag is set for which
I don't totally understand the meaning or default to the core algorithm.

Now, while I can understand why it's a good idea to use the current
processor, in order to limit cache ping pong etc... I'm not really
confident I understand the pro/cons of using the hashing for tx. I
understand that the net core can play interesting games with associating
sockets with queues etc... but I'm a bit at a loss when it comes to
deciding what's best for this driver. I suppose I could start by
implementing my own queue selection based on what ehea does today but I
have the nasty feeling that's going to be sub-optimal :-)

So I would very much appreciate (and reward with free beer at the next
conference) if somebody could give me a bit of a heads up on how things
are expected to be done there, pro/cons, perf impact etc...

Thanks in avance !

Cheers,
Ben.


