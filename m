From: Tejun Heo <tj@kernel.org>
Subject: Re: netlink: Add netlink_bound helper and use it in netlink_getname
Date: Sat, 26 Sep 2015 16:05:18 -0400
Message-ID: <20150926200518.GG3572@htj.duckdns.org>
References: <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
 <20150925150113.GD4449@mtj.duckdns.org>
 <20150926131621.GA16724@gondor.apana.org.au>
 <20150926180903.GD3572@htj.duckdns.org>
 <20150926194110.GA18815@gondor.apana.org.au>
 <20150926194554.GE3572@htj.duckdns.org>
 <20150926194916.GA18975@gondor.apana.org.au>
 <20150926195245.GF3572@htj.duckdns.org>
 <20150926195548.GA19064@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:33196 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbbIZUFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 16:05:23 -0400
Content-Disposition: inline
In-Reply-To: <20150926195548.GA19064@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Sun, Sep 27, 2015 at 03:55:48AM +0800, Herbert Xu wrote:
> Well I disagree.  When I say that it returns to user-space I really
> mean that the next time we use portid via the same call path that
> triggered the connect we must be checking nlk->bound anyway.
> 
> Good luck finding more bugs in this code :)

Frankly, I don't understand what you've been trying to achieve.
You're actively disregarding best practices (like terminating
synchronization where it starts) and reach the target state by doing a
browian motion in the solution space.  Sure, if you do enough of that,
eventually you can arrive somewhere where it's not broken but it leads
to a lot more overhead for everyone involved - the author, reviewers
and later readers of the code and if you spread barrier usages like
this across the kernel, we'll end up with code base which is a lot
harder to verify and maintain.  I hope you stop doing things this way
but suppose that you're ignoring any conceptual arguments in this
thread.

Thanks.

-- 
tejun
