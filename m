From: David Miller <davem@davemloft.net>
Subject: Re: net: alignment problem in icmp code
Date: Mon, 22 Oct 2007 01:31:05 -0700 (PDT)
Message-ID: <20071022.013105.74746322.davem@davemloft.net>
References: <20071022065443.2f3c1b8a@poseidon.drzeus.cx>
	<20071021.221524.49830652.davem@davemloft.net>
	<20071022092350.5c75b3bd@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drzeus@drzeus.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46768
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbXJVIap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 04:30:45 -0400
In-Reply-To: <20071022092350.5c75b3bd@poseidon.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ossman <drzeus@drzeus.cx>
Date: Mon, 22 Oct 2007 09:23:50 +0200

> As for other instances of unaligned accesses, is there any active
> work on getting rid of those? And would you accept more patches for
> fixing them? (Code complexity being the downside)

On fast paths we aren't going to add things like get_unaligned()
calls.

Every architecture should handle unaligned accesses properly, and for
the fast paths the network driver should provide the packet fully
aligned or take steps to make it so if it can't DMA directly into
2-byte offset buffers (such as copying the packet).

What is the specific reason why you see packet headers unaligned?
It's probably just some AVR networking driver that needs tweaks.
