From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC net-next PATCH V1 9/9] net: frag remove readers-writer
 lock (hack)
Date: Sun, 25 Nov 2012 22:03:16 -0800
Message-ID: <20121125220316.7bbc2287@nehalam.linuxnetplumber.net>
References: <20121123130749.18764.25962.stgit@dragon>
	<20121123130847.18764.87682.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50345 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311Ab2KZGE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2012 01:04:26 -0500
In-Reply-To: <20121123130847.18764.87682.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Nov 2012 14:08:47 +0100
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Do NOT APPLY this patch.
> 
> After all the other patches, the rw_lock is now the contention point.

Reader-writer locks are significantly slower than a simple spinlock.
Unless the reader holds the lock for "significant" number of cycles,
a spin lock will be faster. 

Did you try just changing it to a spinlock?
