From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 8/9] net: frag queue locking per hash bucket
Date: Fri, 30 Nov 2012 13:55:32 +0100
Message-ID: <1354280132.11754.435.camel@localhost>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161512.17754.93933.stgit@dragon>
	 <1354208920.14302.1907.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab2K3M4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 07:56:54 -0500
In-Reply-To: <1354208920.14302.1907.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 09:08 -0800, Eric Dumazet wrote:

> So we still have this huge contention on the reader-writer lock cache
> line...
> I would just remove it. (And remove hash rebuild, or make it RCU
> compatible )

I vote for removing the rebuild feature.  It really doesn't make sense
to protect a 256Kb memory (using) hash, with very short lived elements,
against hash collision attacks, every 10 minutes. (Especially as we saw
a 7 GBit/s performance improvement)

Making the hash RCU "compatible" is not going to work, because the
elements are too short lived, thus we cannot free them fast enough
(call_rcu stuff). (I actually did the RCU implementation, to realize
this...)
