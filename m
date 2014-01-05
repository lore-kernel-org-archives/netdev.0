From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 01/12] netfilter: avoid get_random_bytes calls
Date: Mon, 6 Jan 2014 00:41:57 +0100
Message-ID: <20140105234157.GB29910@order.stressinduktion.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org> <1388963586-5049-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, fw@strlen.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1388963586-5049-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 06, 2014 at 12:12:55AM +0100, Pablo Neira Ayuso wrote:
> From: Florian Westphal <fw@strlen.de>
> 
> All these users need an initial seed value for jhash, prandom is
> perfectly fine.  This avoids draining the entropy pool where
> its not strictly required.

Secrets protecting hash tables should be rather strong.

prandom_u32() has two seeding points at boot-up. One is at late_initcall.
Thanks to parallel boot-up this gets executed fairly early. The other one is
when the RNG nonblocking pool is fully initialized. Only after this point we
can assume prandom_u32() returns truely random values. In between, only
get_random_bytes or net_get_random_once are safe for use.

To get the impression when prandom_u32 gets truely seeded, watch out
for the message "random: nonblocking pool is initialized" in dmesg. ;)

Hmm, some of them look like good candidates for net_get_random_once. I don't
see such a problem with draining entropy pool, especially as they don't run
that early and they don't request so many random bits.

Greetings,

  Hannes


