From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4] netlink: Fix autobind race condition that leads to
 zero port ID
Date: Mon, 21 Sep 2015 14:06:36 +0800
Message-ID: <20150921060636.GA30807@gondor.apana.org.au>
References: <20150917113034.GA14471@htj.duckdns.org>
 <20150918063609.GA31747@gondor.apana.org.au>
 <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tj@kernel.org, cwang@twopensource.com, tom@herbertland.com,
	kafai@fb.com, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org,
	jiri@resnulli.us, nicolas.dichtel@6wind.com, tgraf@suug.ch,
	sfeldma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150920.225521.1063980101511317898.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 20, 2015 at 10:55:21PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 18 Sep 2015 19:16:50 +0800
> 
> > The commit c0bb07df7d981e4091432754e30c9c720e2c0c78 ("netlink:
> > Reset portid after netlink_insert failure") introduced a race
> > condition where if two threads try to autobind the same socket
> > one of them may end up with a zero port ID.  This led to kernel
> > deadlocks that were observed by multiple people.
> > 
> > This patch reverts that commit and instead fixes it by introducing
> > a separte rhash_portid variable so that the real portid is only set
> > after the socket has been successfully hashed.
> > 
> > Fixes: c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
> > Reported-by: Tejun Heo <tj@kernel.org>
> > Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied and queued up for -stable, thanks Herbert.

Sorry but Dave but there are still races with v4 as Tejun pointed
out.  I'm still working on it and I could post them as incremental
patches if that's the easiest.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
