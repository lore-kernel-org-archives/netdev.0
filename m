From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/28] [v2] netfilter: nf_tables: avoid uninitialized
 variable warning
Date: Tue, 18 Oct 2016 17:23:54 +0200
Message-ID: <20161018152354.GA2759@salvia>
References: <20161017220342.1627073-1-arnd@arndb.de>
 <20161017220557.1688282-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161017220557.1688282-1-arnd@arndb.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2016 at 12:05:30AM +0200, Arnd Bergmann wrote:
> The newly added nft_range_eval() function handles the two possible
> nft range operations, but as the compiler warning points out,
> any unexpected value would lead to the 'mismatch' variable being
> used without being initialized:
> 
> net/netfilter/nft_range.c: In function 'nft_range_eval':
> net/netfilter/nft_range.c:45:5: error: 'mismatch' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This removes the variable in question and instead moves the
> condition into the switch itself, which is potentially more
> efficient than adding a bogus 'default' clause as in my
> first approach, and is nicer than using the 'uninitialized_var'
> macro.

Applied to the nf tree, thanks Arnd.
