From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] [rfc, netfilter-next] netfilter: nf_tables: fib warnings
Date: Fri, 28 Oct 2016 17:50:31 +0200
Message-ID: <20161028155031.GI23011@breakpoint.cc>
References: <20161028153124.3773180-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161028153124.3773180-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> The newly added nft fib code produces two warnings:
> 
> net/ipv4/netfilter/nft_fib_ipv4.c: In function 'nft_fib4_eval':
> net/ipv4/netfilter/nft_fib_ipv4.c:80:6: error: unused variable 'i' [-Werror=unused-variable]
> net/ipv4/netfilter/nft_fib_ipv4.c: In function ‘nft_fib4_eval’:
> net/ipv4/netfilter/nft_fib_ipv4.c:137:6: error: ‘oif’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> The first one is obvious as the only user of that variable is
> inside of an #ifdef, but the second one is a bit trickier.
> It is clear that 'oif' is uninitialized here if neither
> NFTA_FIB_F_OIF nor NFTA_FIB_F_IIF are set.
> 
> I have no idea how that should be handled, this patch just
> returns without doing anything, which may or may not be
> the right thing to do.

It should be initialized to NULL.
