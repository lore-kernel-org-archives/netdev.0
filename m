From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip: make IP identifiers less predictable
Date: Fri, 25 Jul 2014 20:09:11 +0200
Message-ID: <1406311751.3363.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFyCDNq3E+bZ3aPfS33w8mA_86J+cNWR5V6fdogNihSh2Q@mail.gmail.com>
	 <53D27E0E.40102@cs.unm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Willy Tarreau <w@1wt.eu>,
	"security@kernel.org" <security@kernel.org>
To: Jeffrey Knockel <jeffk@cs.unm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:43898 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbaGYSJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 14:09:20 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so1431351wib.2
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2014 11:09:19 -0700 (PDT)
In-Reply-To: <53D27E0E.40102@cs.unm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-07-25 at 09:55 -0600, Jeffrey Knockel wrote:

> So my thoughts in a nutshell:  I believe that this proposed patch solves
> the original problem of attackers being able to infer the value of
> counters via a side-channel.  However, in the post-73f156a6e8c1 world,
> there's also a new problem which we might care about too where we have
> an attacker who controls a large number of addresses.  This patch also
> happens to help with this problem too, but maybe not enough, depending
> on how sophisticated of an attacker we want to protect against.

What do you mean by "an attacker who controls a large number of
addresses" ?

The hash(daddr) -> slot function is not known, as we use a Jenkin hash
with a secret ( ip_idents_hashrnd & ip6_idents_hashrnd )

We might change the hash to use both daddr & saddr to increase
protection.

pre-73f156a6e8c1 was horrible, because it was easy to fill inetpeer
table to force a garbage collection. Then when an ID was needed for a
peer that had been evicted, we started again from a fixed base ID
( secure_ip_id() )

Thanks.
