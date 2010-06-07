From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] act_cpu: redirect skb receiving to a special CPU.
Date: Mon, 07 Jun 2010 10:43:44 +0200
Message-ID: <87ljargrlr.fsf@basil.nowhere.org>
References: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
	<1275743224.3490.44.camel@bigi>
	<AANLkTiltF2APEnqHyHTtHA7JMNp3HX3aCu9UL3nUJ5_u@mail.gmail.com>
	<1275746045.3490.60.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52577 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab0FGInq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 04:43:46 -0400
In-Reply-To: <1275746045.3490.60.camel@bigi> (jamal's message of "Sat\, 05 Jun 2010 09\:54\:05 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal <hadi@cyberus.ca> writes:
>
> I would look at it as "messaging of remote CPU" which may not result
> in an IRQ. I am pretty sure if you tried hard you could use HT in AMD
> hardware - the remote cpu may have an IRQ triggered but it wont be as
> expensive as IPI.

It's unlikely you'll find any way on x86 to do an IPI that is cheaper
than an standard IPI. That is unless you dedicate the receiver to poll
or monitor.

On recent higher end Intel CPUs X2APIC IPIs will be somewhat cheaper
than classical APIC IPIs.

But for a normal "IPI user" like networking it looks all the same,
it's hidden by the architecture code.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
