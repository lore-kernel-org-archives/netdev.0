From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 07/23] netfilter: x_tables: check standard target size too
Date: Mon, 6 Jun 2016 00:02:10 +0200
Message-ID: <20160605220210.GA7827@breakpoint.cc>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
 <1461332394-3994-8-git-send-email-pablo@netfilter.org>
 <8760tn5ojb.fsf@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8760tn5ojb.fsf@linux-m68k.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Schwab <schwab@linux-m68k.org> wrote:
> > From: Florian Westphal <fw@strlen.de>
> >
> > We have targets and standard targets -- the latter carries a verdict.
> >
> > The ip/ip6tables validation functions will access t->verdict for the
> > standard targets to fetch the jump offset or verdict for chainloop
> > detection, but this happens before the targets get checked/validated.
> >
> > Thus we also need to check for verdict presence here, else t->verdict
> > can point right after a blob.
> >
> > Spotted with UBSAN while testing malformed blobs.
> 
> This breaks iptables on PPC32.

Yes, we got bug report for arm32, I'm sorry about this -- only 32bit
platform I tested was i686 and that only needs 4byte alignment for u64.

This fix should help:

https://git.kernel.org/cgit/linux/kernel/git/pablo/nf.git/commit/?id=7b7eba0f3515fca3296b8881d583f7c1042f5226
