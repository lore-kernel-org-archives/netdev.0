From: Tejun Heo <tj@kernel.org>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sat, 26 Sep 2015 16:17:56 -0400
Message-ID: <20150926201756.GH3572@htj.duckdns.org>
References: <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
 <20150926180903.GD3572@htj.duckdns.org>
 <20150926194110.GA18815@gondor.apana.org.au>
 <20150926194554.GE3572@htj.duckdns.org>
 <20150926194916.GA18975@gondor.apana.org.au>
 <20150926195245.GF3572@htj.duckdns.org>
 <20150926195548.GA19064@gondor.apana.org.au>
 <20150926200518.GG3572@htj.duckdns.org>
 <20150926201041.GA19187@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150926201041.GA19187@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sun, Sep 27, 2015 at 04:10:41AM +0800, Herbert Xu wrote:
> Well guess what the bug that you have discovered supposedly due to
> a missing barrier in netlink_connect has nothing to do with the
> barrier.  Instead it is caused by a logical error elsewhere that
> would have gone unnoticed otherwise.

It's a combination of two problems.  The garbage port number is a
logical error but there still is an ordering problem there between
->bound and ->portid.  We need to test ->bind there again because of
the garbage port problem.

> So I retain my position that blindly adding barriers do not make
> bugs go away.  Instead you need to have real understanding of what

That's a dishonest summary of what I've been saying.

> the code is doing and every spot where a barrier may be needed must
> be audited manually.

What I've been saying is that we do need to be careful and audit each
barrier usages but at the same time there are established patterns
that we can use to make the process significantly easier and more
reliable.

Thanks.

-- 
tejun
