From: David Miller <davem@davemloft.net>
Subject: Re: net: alignment problem in icmp code
Date: Sun, 21 Oct 2007 12:48:14 -0700 (PDT)
Message-ID: <20071021.124814.50617600.davem@davemloft.net>
References: <20071020233540.43d2f103@poseidon.drzeus.cx>
	<20071020.221257.78359286.davem@davemloft.net>
	<20071021113405.37fa0bc5@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drzeus@drzeus.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50549
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751804AbXJUTsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 15:48:04 -0400
In-Reply-To: <20071021113405.37fa0bc5@poseidon.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ossman <drzeus@drzeus.cx>
Date: Sun, 21 Oct 2007 11:34:05 +0200

> Inlining isn't the problem, but the defined semantics of assignment
> versus memcpy(). memcpy() must work on any region of memory, whilst
> assignment must only work on a properly aligned object.

You are missing a crucial point.

The compiler may emit the same exact loads and stores when it inlines
memcpy() if it "knows" the objects are aligned properly.  And it very
much will do this.

If the compiler is calling memcpy() in your build, it's only because
gcc believes the the object is too big to optimally memcpy() inline.
