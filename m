From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 17 Jun 2016 20:09:47 -0700 (PDT)
Message-ID: <20160617.200947.2078656051211641868.davem@davemloft.net>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbcFRDJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 23:09:49 -0400
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 16 Jun 2016 10:51:54 -0700

> The goal of this work is twofold:
> 
> 1) Allow applications to run their own transport layer stack (i.e.from
>    userspace). This eliminates dependencies on the OS (e.g. solves a
>    major dependency issue for Facebook on clients).

Clients need to support TOU in their kernels, it's a similar kind of
dependency, but of course you only need to propagate it once rather
than once per desired stack change.

We also now have to debug against every single userland TCP
implementation someone can come up with, the barrier to entry is
insanely low with TOU.  Maybe this sounds great to you, but to me
it is quite terrifying

This has a monumental impact upon maintainence of our TCP stack.

I suspect a lot of bug reports will go straight to /dev/null once it
is clear that it is a TOU TCP connection.

For TCP the tight integration into the kernel is a benefit, because it
limits the number of variables at stake when trying to analyze
problems.

> 2) Make transport layer headers (all of L4) invisible to the network
>    so that they can't do intrusive actions at L4. This will be enforced
>    with DTLS in use.

This achievement is only met when DTLS is enabled, and it isn't enabled
by default.

This sounds really great on paper, however I find it hard to believe
that makers of middleware boxes are just going to throw their hands in
the air and say "oh well, we lose."

Rather, I think people are going to start adding rules to block TOU
tunnels entirely because they cannot inspect nor conditionally
filter/rewrite the contents.  This is even more likely if Joe Random
and so easily can do their own userland TCP stack over TOU.

BTW, I have a question about the pseudo header checksum.  If the outer
IP addresses can change, due to NAT or whatever, and therefore the
session key is used for connection demuxing instead of the addresses,
why don't we also have to use the session key instead of the IP
addresses for the pseudo header used in checksum calculations?
