From: Jeffrey Knockel <jeffk@cs.unm.edu>
Subject: Re: [PATCH net] ip: make IP identifiers less predictable
Date: Fri, 25 Jul 2014 14:28:35 -0600
Message-ID: <53D2BDF3.5060909@cs.unm.edu>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>	 <CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com>	 <53D27E0E.40102@cs.unm.edu> <1406311751.3363.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Willy Tarreau <w@1wt.eu>,
	"security@kernel.org" <security@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snape.cs.unm.edu ([64.106.20.59]:53140 "EHLO snape.cs.unm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934614AbaGYU2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 16:28:45 -0400
In-Reply-To: <1406311751.3363.95.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2014 12:09 PM, Eric Dumazet wrote:
> What do you mean by "an attacker who controls a large number of
> addresses" ?

In general, I mean any attacker who can read the packets sent to a large
number of different Internet addresses.  Even an attacker who has one
address but can cycle through different assignments may be a problem.

> The hash(daddr) -> slot function is not known, as we use a Jenkin hash
> with a secret ( ip_idents_hashrnd & ip6_idents_hashrnd )

That's true, but the secret never changes, right?  I may not be able to
identify the slot number that any address is hashed to, but I can
identify when some victim address hashes to the same slot as one of my
addresses whose packets I can read.  For instance, if I in short succession

1. Probe value of the IP id counter for each of my addresses
2. Spoof a large number of (e.g.) echo requests from victim address (or
something else to the distribution that I can measure)
3. Again probe value of the IP id counter for each of my addresses

Then I can tell which of my addresses hash to the same slot as the
victim address by whose value of the IP id counter has jumped as a
result of the linux machine sending echo replies to the victim.

Jeff
