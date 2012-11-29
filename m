From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 8/9] net: frag queue locking per hash bucket
Date: Thu, 29 Nov 2012 09:08:40 -0800
Message-ID: <1354208920.14302.1907.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161512.17754.93933.stgit@dragon>
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
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:46410 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab2K2RIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:08:45 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so7758810pad.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 09:08:45 -0800 (PST)
In-Reply-To: <20121129161512.17754.93933.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 17:15 +0100, Jesper Dangaard Brouer wrote:
> This patch implements per hash bucket locking for the frag queue
> hash.  This removes two write locks, and the only remaining write
> lock is for protecting hash rebuild.  This essentially reduce the
> readers-writer lock to a rebuild lock.

So we still have this huge contention on the reader-writer lock cache
line...

I would just remove it. (And remove hash rebuild, or make it RCU
compatible )
