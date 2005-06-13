From: "David S. Miller" <davem@davemloft.net>
Subject: Re: udp.c
Date: Mon, 13 Jun 2005 16:20:52 -0700 (PDT)
Message-ID: <20050613.162052.41635836.davem@davemloft.net>
References: <E1Dhwho-0001mn-00@gondolin.me.apana.org.au>
	<20050613.145716.88477054.davem@davemloft.net>
	<20050613230422.GA7269@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, mru@inprovide.com, rommer@active.by,
	bernd@firmix.at, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261602AbVFMXZF@vger.kernel.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050613230422.GA7269@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 14 Jun 2005 09:04:22 +1000

> On Mon, Jun 13, 2005 at 02:57:16PM -0700, David S. Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Tue, 14 Jun 2005 07:42:52 +1000
> > 
> > > It'll dump the stack anyway if we just make it a NULL pointer.
> > 
> > Some platforms don't handle that very cleanly, for example
> > it may be necessary to have something mapped at page zero
> > for one reason or another.
> 
> Are there any existing platforms that do that in kernel mode?

X86 did, especially during bootup, for a long time.

I know the highly optimized sparc64 instruction TLB miss handler
doesn't handle this properly and this usually hangs the machine.
I've put some checks in there that tries to handle it properly,
but there are still some cases that pass through.
