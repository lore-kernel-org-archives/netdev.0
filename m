From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 9/24] make atomic_read() behave consistently on ia64
Date: Fri, 10 Aug 2007 18:43:04 -0400
Message-ID: <46BCE9F8.4060009@redhat.com>
References: <20070809135107.GA15985@shell.boston.redhat.com><617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com><46BCC1AF.5050204@redhat.com><617E1C2C70743745A92448908E030B2A0224C777@scsmsx411.amr.corp.intel.com> <jewsw3oyl8.fsf@sykes.suse.de> <617E1C2C70743745A92448908E030B2A0224C88B@scsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andreas Schwab <schwab@suse.de>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: "Luck, Tony" <tony.luck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40853 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752571AbXHJWnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 18:43:45 -0400
In-Reply-To: <617E1C2C70743745A92448908E030B2A0224C88B@scsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luck, Tony wrote:
>> Use atomic64_read to read an atomic64_t.
> 
> Thanks Andreas!
> 
> Chris: This bug is why the 8-byte loads got changed to 4-byte + sign-extend
> by your change to atomic_read().

I figured as much.  Thanks for confirming this.

> With this applied together with shuffling the volatile from the
> declaration to the usage (in both atomic_read() and atomic_set()
> the generated code *almost* reverts to the original.
> 
> There are some differences where ld4 have turned into ld8 though.
> Are these bugs in the use of atomic_add() and atomic_sub().  E.g.
> the first of these changes is in: ipc/msg.c:freeque() where we have:
> 
> 	atomic_sub(msg->q_cbytes, &msg_bytes);
> 
> Now the type of msg->q_cbytes is "unsigned long" ... so it seems a
> poor idea to subtract such a large typed object from "msg_bytes"
> which is a mere slip of an atomic_t.
> 
> Or is there some other type-wrangling that needs to happen in
> include/asm-ia64/atomic.h?  There are a total of nineteen of
> these ld4->ld8 transforms.

Possibly.  Either that or we've uncovered some latent bugs.  Maybe a 
combination of the two.  Can you list those 19 changes so we can 
evaluate them?  I'm told there were some *(volatile *) bugs fixed in gcc 
recently, so it's also possible your 3.4.6 is showing those.  I can test 
that on a more recent gcc on ia64 if it's inconvenient for you to do so 
on your test box.

	-- Chris
