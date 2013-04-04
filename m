From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH V2] net: frag queue per hash bucket locking
Date: Thu, 4 Apr 2013 11:03:49 +0200
Message-ID: <20130404090349.GE20292@order.stressinduktion.org>
References: <1365027060.12728.30.camel@localhost> <20130404075226.18493.75426.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50344 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab3DDJDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 05:03:51 -0400
Content-Disposition: inline
In-Reply-To: <20130404075226.18493.75426.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 04, 2013 at 09:52:26AM +0200, Jesper Dangaard Brouer wrote:
> +struct inet_frag_bucket {
> +	struct hlist_head	chain;
> +	spinlock_t		chain_lock;
> +	u16			chain_len;
> +};
> +

I just noticed and wanted to ask for what chain_len is needed?  Could it
be dropped?

If the elements are swapped between the hash buckets in
inet_frag_secret_rebuild it seems you forgot to update chain_len
correctly.

Thanks,

  Hannes
