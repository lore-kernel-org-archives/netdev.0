From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2] net: frag queue per hash bucket locking
Date: Thu, 04 Apr 2013 11:27:52 +0200
Message-ID: <1365067672.12728.46.camel@localhost>
References: <1365027060.12728.30.camel@localhost>
	 <20130404075226.18493.75426.stgit@dragon>
	 <20130404090349.GE20292@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758421Ab3DDJ2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 05:28:04 -0400
In-Reply-To: <20130404090349.GE20292@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 11:03 +0200, Hannes Frederic Sowa wrote:
> On Thu, Apr 04, 2013 at 09:52:26AM +0200, Jesper Dangaard Brouer wrote:
> > +struct inet_frag_bucket {
> > +	struct hlist_head	chain;
> > +	spinlock_t		chain_lock;
> > +	u16			chain_len;
> > +};
> > +
> 
> I just noticed and wanted to ask for what chain_len is needed?  Could it
> be dropped?

It could be dropped from this patch.  Its part of my future hash cleanup
strategy.
I also wanted to use it to replace the nqueues counter, but its would
not be correct, because nqueues counter is maintained per netns (network
namespace).

Its currently the netns separation, which is causing "headaches" for my
removal of LRU and direct-hash-cleaning solution...


> If the elements are swapped between the hash buckets in
> inet_frag_secret_rebuild it seems you forgot to update chain_len
> correctly.

Ah, good catch.
Given its not even correct, I'll remove the chain_len and repost a V3.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
