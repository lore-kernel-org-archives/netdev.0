From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] netlink: add netlink_dump_control structure for
 netlink_dump_start()
Date: Sat, 25 Feb 2012 14:22:44 +0100
Message-ID: <20120225132244.GB15774@1984>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
 <1330129817-28199-2-git-send-email-pablo@netfilter.org>
 <alpine.LNX.2.01.1202250210240.17151@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	davem@davemloft.net
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1202250210240.17151@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 25, 2012 at 02:12:22AM +0100, Jan Engelhardt wrote:
> On Saturday 2012-02-25 01:30, pablo@netfilter.org wrote:
> 
> >From: Pablo Neira Ayuso <pablo@netfilter.org>
> >
> >Davem considers that the argument list of this interface is getting
> >out of control. This patch tries to address this issue following
> >his proposal:
> >
> >struct netlink_dump_control c = { .dump = dump, .done = done, ... };
> >
> >netlink_dump_start(..., &c);
> 
> What about adding skb and nlh into c as well? After all, skb
> is not nearly as much {used directly} as it is in Xtables.

If you look at all netlink_dump_start invocations. Those are always
included. The idea was to add to the structure fields that may be
unset.

> >+		{
> >+			struct netlink_dump_control c = {
> >+				.dump = link->dump,
> >+				.done = link->done,
> >+			};
> >+			return netlink_dump_start(crypto_nlsk, skb, nlh, &c);
> >+		}
> 
> You can also use
> 
> 		return netlink_dump_start(crypto_nlsk, skb,
> 		       &(const struct netlink_dump_control)
> 		       {.dump = link->dump, .done = link->done}));

Nice to know, thanks. Haven't see this in any other part of the kernel
code though and it looks a bit ugly IMO. I think I prefer the way it is
now.
