From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Thu, 3 Feb 2005 10:14:20 -0800
Message-ID: <20050203101420.468c1607.davem@davemloft.net>
References: <20050131102920.GC4170@suse.de>
	<E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
	<20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, okir@suse.de, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050203142705.GA11318@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005 01:27:05 +1100
Anton Blanchard <anton@samba.org> wrote:

> Architectures should guarantee that any of the atomics and bitops that
> return values order in both directions. So you dont need the
> smp_mb__before_atomic_dec here.
> 
> It is, however, required on the atomics and bitops that dont return
> values. Its difficult stuff, everyone gets it wrong and Andrew keeps
> hassling me to write up a document explaining it.

Sparc64 happens to order the atomic we use in the bitops and atomic_t
ops, so sparc64 gets this right by accident.

I had no idea about this requirement before reading your email.

If IBM is seeing race this on ppc64, then I'm even more confused.
If Anton understands the requirements, then ppc64 should have
the return value atomic's implemented with the proper barriers.
