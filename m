From: Scott Feldman <sfeldma@nuovasystems.com>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Fri, 10 Oct 2008 15:34:37 -0700
Message-ID: <C515268D.C81F%sfeldma@nuovasystems.com>
References: <20081010.115849.215623604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <rdreier@cisco.com>, <akpm@linux-foundation.org>, <mingo@elte.hu>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:26033 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751272AbYJJWei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 18:34:38 -0400
In-Reply-To: <20081010.115849.215623604.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/08 11:58 AM, "David Miller" <davem@davemloft.net> wrote:

> From: Scott Feldman <sfeldma@nuovasystems.com>
> Date: Fri, 10 Oct 2008 11:29:23 -0700
>> Yes, enic hw provides atomic read/write for 64-bit regs even if register is
>> accessed with 32-bit read/writes.
> 
> Sure, and this is why 32-bit arch's don't provide readq/writeq
> implementations,
> things are much more subtle here.
> 
> The hardware may allow 2 32-bit writes to a 64-bit register, but...
> 
> Are there potential problems when the register is half-way updated?
> 
> For example, consider a ring index where the upper and lower 32-bits
> are actually significant.  If you change the top part and then the
> bottom part, in the intermediate step there is an invalid state and
> the card might try to access an invalid ring index.

Yes, I'd like to retract my original remark.  :(  There is a mechanism for
atomic access to a wide register, but it's not enabled for the register
cases in question, and even if it was, an intermediate access to another
address would invalidate the mechanism, as you point out.  So...
 
> Then also, of course, the driver itself has to make sure it does
> enough locking to make sure a partial 64-bit update isn't interrupted
> by a parallel one on another cpu to the same register but I'll assume
> the driver takes care of that here :-)

...There is enough locking.

-scott

