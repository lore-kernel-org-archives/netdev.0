From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG INFO]IPv6: sleeping function called from invalid context.
Date: Sun, 20 Nov 2005 09:38:54 +1100
Message-ID: <20051119223854.GC1751@gondor.apana.org.au>
References: <20051118123557.GD20395@postel.suug.ch> <E1EdRCZ-0007uy-00@gondolin.me.apana.org.au> <20051119210411.GE20395@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, yanzheng@21cn.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751007AbVKSWjP@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20051119210411.GE20395@postel.suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 19, 2005 at 10:04:11PM +0100, Thomas Graf wrote:
> 
> The continued dumps wouldn't be the problem, the walker is allocated
> on the initial dump call. It was a mistake though, nlk->cb_lock spin
> lock is always held for cb->dump() even though it should only be
> required during the nlk->cb != NULL check. netlink_dump_start()
> guarantees to only allow one dumper per socket at a time.

You're certainly right that the initial dump is what's causing the
problem.

I think the spin lock is still required though because we also need
to guard against netlink_release which can occur at any time since
the packet processing could be occuring in a different thread from
the one that did the sendmsg.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
