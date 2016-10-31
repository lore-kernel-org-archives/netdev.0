From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] [v2 netfilter-next] netfilter: nf_tables: fib warnings
Date: Mon, 31 Oct 2016 15:17:12 +0100
Message-ID: <20161031141712.GA21444@salvia>
References: <20161028201810.1076559-1-arnd@arndb.de>
 <20161028232612.GA30488@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161028232612.GA30488@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 29, 2016 at 01:26:12AM +0200, Florian Westphal wrote:
> Arnd Bergmann <arnd@arndb.de> wrote:
> > The newly added nft fib code produces two warnings:
> > 
> > net/ipv4/netfilter/nft_fib_ipv4.c: In function 'nft_fib4_eval':
> > net/ipv4/netfilter/nft_fib_ipv4.c:80:6: error: unused variable 'i' [-Werror=unused-variable]
> > net/ipv4/netfilter/nft_fib_ipv4.c: In function ‘nft_fib4_eval’:
> > net/ipv4/netfilter/nft_fib_ipv4.c:137:6: error: ‘oif’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > 
> > The first one is obvious as the only user of that variable is
> > inside of an #ifdef
> > 
> > The second one is a bit trickier. It's clear that oif is in fact
> > uninitialized when it gets used when neither NFTA_FIB_F_IIF nor
> > NFTA_FIB_F_OIF are set, and just setting it to NULL won't work
> > as it may later get dereferenced.
> > 
> > However, there is no need to search the result list if it is
> > NULL, as Florian pointed out. This integrates his (untested)
> > change to do so. I have confirmed that the combined patch
> > solves both warnings, but as I don't fully understand Florian's
> > change, I can't tell if it's correct.
> > 
> > Suggested-by: Florian Westphal <fw@strlen.de>
> > Fixes: 84f5eedb983e ("netfilter: nf_tables: add fib expression")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
[...] 
> Tested-by: Florian Westphal <fw@strlen.de>

Applied, thanks!
