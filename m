From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Mon, 21 Jul 2008 07:14:39 -0400
Message-ID: <1216638879.4847.210.camel@localhost>
References: <E1KKZmE-0000ty-00@gondolin.me.apana.org.au>
	 <1216568119.4847.101.camel@localhost>
	 <20080721001119.GA6515@gondor.apana.org.au>
	 <1216607637.4847.172.camel@localhost>
	 <20080721031716.GA7535@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:49056 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbYGULOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 07:14:42 -0400
Received: by py-out-1112.google.com with SMTP id p76so992761pyb.10
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 04:14:41 -0700 (PDT)
In-Reply-To: <20080721031716.GA7535@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-21-07 at 11:17 +0800, Herbert Xu wrote:

> Unfortunately the scenario that I wrote this for requires frequent
> addition/removal.

Aha - makes absolute sense then;->

> Only if you also want to share it :) In the end I patched it to
> not share it which is much easier.

I am trying to visualize: if you dont share, you must have 256K copies
then? Assuming also you have a fast lookup since that was design intent.

> Of course if you're volunteering to write the dynamic hash table
> for actions then I'd happily switch back to sharing :)

It is a unique need like you said earlier (and would require a
medium-size surgery).
How about this: if a second user shows up with such a need I could do
it.

If you knew you had a 256K entry, then you could make
NAT_TAB_MASK to be (256K-1) and you are guaranteed to get O(1) lookup if
you dont specify indices.
I know youve patched it already -havent quiet understood how and your
current solution may be better- but one other way is to have a Kconfig
option which lets the user type the size of the nat hash table size at
kernel compile time. So then a change
of the sort:
#ifdef CONFIG_HASH_SIZE
#define NAT_TAB_MASK CONFIGURED_HASH_SIZE
#else
#define NAT_TAB_MASK 15
#endif

What do you think?

cheers,
jamal

