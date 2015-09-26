From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sun, 27 Sep 2015 04:10:41 +0800
Message-ID: <20150926201041.GA19187@gondor.apana.org.au>
References: <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
 <20150926180903.GD3572@htj.duckdns.org>
 <20150926194110.GA18815@gondor.apana.org.au>
 <20150926194554.GE3572@htj.duckdns.org>
 <20150926194916.GA18975@gondor.apana.org.au>
 <20150926195245.GF3572@htj.duckdns.org>
 <20150926195548.GA19064@gondor.apana.org.au>
 <20150926200518.GG3572@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150926200518.GG3572@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 26, 2015 at 04:05:18PM -0400, Tejun Heo wrote:
> 
> Frankly, I don't understand what you've been trying to achieve.
> You're actively disregarding best practices (like terminating
> synchronization where it starts) and reach the target state by doing a
> browian motion in the solution space.  Sure, if you do enough of that,
> eventually you can arrive somewhere where it's not broken but it leads
> to a lot more overhead for everyone involved - the author, reviewers
> and later readers of the code and if you spread barrier usages like
> this across the kernel, we'll end up with code base which is a lot
> harder to verify and maintain.  I hope you stop doing things this way
> but suppose that you're ignoring any conceptual arguments in this
> thread.

Your point so far has been that if you add barriers or use primitives
everywhere then races magically disappear.

Well guess what the bug that you have discovered supposedly due to
a missing barrier in netlink_connect has nothing to do with the
barrier.  Instead it is caused by a logical error elsewhere that
would have gone unnoticed otherwise.

So I retain my position that blindly adding barriers do not make
bugs go away.  Instead you need to have real understanding of what
the code is doing and every spot where a barrier may be needed must
be audited manually.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
