From: David Miller <davem@davemloft.net>
Subject: Re: net: alignment problem in icmp code
Date: Sun, 21 Oct 2007 22:15:24 -0700 (PDT)
Message-ID: <20071021.221524.49830652.davem@davemloft.net>
References: <20071021232113.52ce1be7@poseidon.drzeus.cx>
	<20071021.160215.115679567.davem@davemloft.net>
	<20071022065443.2f3c1b8a@poseidon.drzeus.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drzeus@drzeus.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751855AbXJVFPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 01:15:11 -0400
In-Reply-To: <20071022065443.2f3c1b8a@poseidon.drzeus.cx>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ossman <drzeus@drzeus.cx>
Date: Mon, 22 Oct 2007 06:54:43 +0200

> On Sun, 21 Oct 2007 16:02:15 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > You will get a 64-bit load and a 64-bit store emitted by
> > the compiler.  Here is what we get on sparc64:
> 
> I assume those ops cause a bus error on unaligned addresses?

Sure.  But the language defines that the types in question
must be 64-bit aligned, so it is legal for the compiler to
emit this code.

It's not a GCC bug.

If you want to let the compiler know that a pointer to a type might
not be aligned, you have to tell it so.
