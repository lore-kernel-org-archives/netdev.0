From: Tejun Heo <tj@kernel.org>
Subject: Re: netlink: Add barrier to netlink_connect for theoretical case
Date: Fri, 25 Sep 2015 11:01:13 -0400
Message-ID: <20150925150113.GD4449@mtj.duckdns.org>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
 <20150924200510.GE25415@mtj.duckdns.org>
 <20150925014327.GA3725@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:34097 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755528AbbIYPBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 11:01:18 -0400
Content-Disposition: inline
In-Reply-To: <20150925014327.GA3725@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Herbert.

On Fri, Sep 25, 2015 at 09:43:27AM +0800, Herbert Xu wrote:
> Well had you said this in the first place I would've fixed it a
> long time ago.  There aren't any in-kernel users right now and
> even if there were they'd have to do a connect/bind/sendmsg on
> the same socket in two threads at the same time.  But let's close
> this theoretical hole:

I'm not even sure we guarantee memory barrier on kernel/user
crossings.  In practice, we probably have enough barriers (e.g. some
syscall traps imply barrier) but I can't think of a reason why we'd
guarantee the existence of barrier there.  As an extreme example,
imagine UML on an architecture with relaxed memory model.

Thanks.

-- 
tejun
