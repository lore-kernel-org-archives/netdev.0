From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] netlink: Fix autobind race condition that leads to
 zero port ID
Date: Sun, 20 Sep 2015 23:11:04 -0700 (PDT)
Message-ID: <20150920.231104.525285577747035896.davem@davemloft.net>
References: <20150918111650.GA7508@gondor.apana.org.au>
	<20150920.225521.1063980101511317898.davem@davemloft.net>
	<20150921060636.GA30807@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, cwang@twopensource.com, tom@herbertland.com,
	kafai@fb.com, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org,
	jiri@resnulli.us, nicolas.dichtel@6wind.com, tgraf@suug.ch,
	sfeldma@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064AbbIUGLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 02:11:05 -0400
In-Reply-To: <20150921060636.GA30807@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 21 Sep 2015 14:06:36 +0800

> On Sun, Sep 20, 2015 at 10:55:21PM -0700, David Miller wrote:
>> From: Herbert Xu <herbert@gondor.apana.org.au>
>> Date: Fri, 18 Sep 2015 19:16:50 +0800
>> 
>> > The commit c0bb07df7d981e4091432754e30c9c720e2c0c78 ("netlink:
>> > Reset portid after netlink_insert failure") introduced a race
>> > condition where if two threads try to autobind the same socket
>> > one of them may end up with a zero port ID.  This led to kernel
>> > deadlocks that were observed by multiple people.
>> > 
>> > This patch reverts that commit and instead fixes it by introducing
>> > a separte rhash_portid variable so that the real portid is only set
>> > after the socket has been successfully hashed.
>> > 
>> > Fixes: c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
>> > Reported-by: Tejun Heo <tj@kernel.org>
>> > Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
>> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>> 
>> Applied and queued up for -stable, thanks Herbert.
> 
> Sorry but Dave but there are still races with v4 as Tejun pointed
> out.  I'm still working on it and I could post them as incremental
> patches if that's the easiest.

Oops, sorry about that.

Yeah at this point incremental patches work the best.

Thanks.
