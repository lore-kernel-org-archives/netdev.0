From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 14:13:56 +0200
Message-ID: <20060816121356.GB14627@postel.suug.ch>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch> <20060816111240.GA28846@gondor.apana.org.au> <20060816113950.GA29003@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:28050 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751147AbWHPMNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 08:13:36 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060816113950.GA29003@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Herbert Xu <herbert@gondor.apana.org.au> 2006-08-16 21:39
> For a broadcast notification, the nlmsg_pid field is meaningless
> because the nlmsg_seq field is also meaningless.  I'm not denying
> that it wouldn't be useful to have the originator's socket address
> in there.  What I'm saying is that it's the wrong place to put
> that information.

It might not be the best place to put it considering the original
intend of nlmsg_pid as you explained correctly. However, as you
state yourself, the nlmsg_pid field is meaningless/unused for
notifications so extending the definition of nlmsg_pid to have
a special meaning for broadcasts doesn't harm anyone.

When setting nlmsg_seq to the seq of the request it becomes a
meaning together with nlmsg_pid as applications can then easly
assign notifications to their own sent requests.

Secondly we already have applications depending on this whereas
the eventual breaking of aplications depending on nlmsg_pid == 0
is uncertain.
