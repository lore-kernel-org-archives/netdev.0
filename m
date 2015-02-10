From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] rhashtable: require max_shift definition
Date: Tue, 10 Feb 2015 17:22:41 +0000
Message-ID: <20150210172241.GB9301@casper.infradead.org>
References: <1423529311-26050-1-git-send-email-johunt@akamai.com>
 <1423529311-26050-2-git-send-email-johunt@akamai.com>
 <20150210005801.GA8951@casper.infradead.org>
 <54D9C18B.5090208@iogearbox.net>
 <54DA2A13.5010204@akamai.com>
 <54DA3A9F.9090608@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Hunt <johunt@akamai.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54DA3A9F.9090608@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/10/15 at 06:06pm, Daniel Borkmann wrote:
> Hm, given that min_shift/max_shift are parameters that directly
> concern internals of rhashtable i.e. are tightly coupled to expand
> and shrink functionality, I'd say that depending on the use case,
> a maxelem limit should rather be handled outside of it, if it's
> truly an issue/concern.

Agreed, Netlink already uses the atomic counter of rhashtable to
enforce  upper limit of table entries:

        err = -ENOMEM;
        if (BITS_PER_LONG > 32 &&
            unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
                goto err;
