From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] netfilter: conntrack: remove uninitialized shadow variable
Date: Mon, 09 May 2016 22:12:31 +0200
Message-ID: <5600782.TOr8CDRnac@wuerfel>
References: <1462823254-3137116-1-git-send-email-arnd@arndb.de> <20160509200117.GA6957@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Sasha Levin <sasha.levin@oracle.com>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160509200117.GA6957@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 09 May 2016 22:01:17 Pablo Neira Ayuso wrote:
> On Mon, May 09, 2016 at 09:47:23PM +0200, Arnd Bergmann wrote:
> > A recent commit introduced an unconditional use of an uninitialized
> > variable, as reported in this gcc warning:
> > 
> > net/netfilter/nf_conntrack_core.c: In function '__nf_conntrack_confirm':
> > net/netfilter/nf_conntrack_core.c:632:33: error: 'ctinfo' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> >    bytes = atomic64_read(&counter[CTINFO2DIR(ctinfo)].bytes);
> >                                  ^
> > net/netfilter/nf_conntrack_core.c:628:26: note: 'ctinfo' was declared here
> >    enum ip_conntrack_info ctinfo;
> > 
> > The problem is that a local variable shadows the function parameter.
> > This removes the local variable, which looks like what Pablo originally
> > intended.
> 
> Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Sorry for this, I wonder why gcc didn't catch up this here.
> 
> @David, you can integrate this into your net-next tree.
> 
> Thanks for fixing up this Arnd.

By default, an allmodconfig build will hide these warnings because of
excessive false positives from CONFIG_CC_OPTIMIZE_FOR_SIZE. I've
tried twice to get a patch merged that disables CONFIG_CC_OPTIMIZE_FOR_SIZE
in allmodconfig so we get better warnings, but that patch unfortunately
got ignored.

	Arnd
