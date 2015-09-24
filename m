From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Thu, 24 Sep 2015 16:05:10 -0400
Message-ID: <20150924200510.GE25415@mtj.duckdns.org>
References: <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150924.121142.870602292135442487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36251 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbbIXUFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 16:05:15 -0400
Content-Disposition: inline
In-Reply-To: <20150924.121142.870602292135442487.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, David.

On Thu, Sep 24, 2015 at 12:11:42PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 22 Sep 2015 11:38:56 +0800
> 
> > The commit 1f770c0a09da855a2b51af6d19de97fb955eca85 ("netlink:
> > Fix autobind race condition that leads to zero port ID") created
> > some new races that can occur due to inconcsistencies between the
> > two port IDs.
...
> I've decided to apply this and queue it up for -stable.

This is mostly correct; however, if there are or can be in-kernel
users which create the client side of netlink socket, it isn't.  Let's
say such in-kernel user does kernel_connect() and then query the
assigned port number by kernel_getsockname().  That can just return
zero.  Maybe such scenario is not possible for some combination of
reasons but why leak this level of synchronization detail to the users
in the first place?  This should be terminated from the site where
such synchronization scheme is implemented.  This expands the scope of
correctness verification to all possible users of these functions.

Thanks.

-- 
tejun
