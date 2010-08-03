From: David Miller <davem@davemloft.net>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Mon, 02 Aug 2010 22:18:13 -0700 (PDT)
Message-ID: <20100802.221813.43045517.davem@davemloft.net>
References: <20100802110334.GK11110@cel.leo>
	<20100802201629.GA5973@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leonerd@leonerd.org.uk, netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58463
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754944Ab0HCFRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 01:17:54 -0400
In-Reply-To: <20100802201629.GA5973@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Mon, 2 Aug 2010 22:16:29 +0200

> PS: the LOOP opcode must be secure against any ressource attack -> the loop
> must be break after n iterations.

Oh yeah, what is an iteration in your definition?  See this is why I
totally refuse to add a looping construct to BPF.

If you just check for a single loop hitting, the user will just use
a chaining of two looping constructs.  And then three levels of
indirection, then four, etc.  He can run up to just before exhasting
the "iteration limit" of one loop, and branch to the next one, and
so on and so forth.

There are probably a million ways to exploit this, and once you come
up with a validation or limiting scheme one of two things will happen:

1) The limiting scheme will make legitimate scripts USELESS

2) Someone will just figure out another hole to punch through and
   exploit

There's a reason no back branching construct was added to BPF to begin
with.  It violates the core design principles of BPF.
