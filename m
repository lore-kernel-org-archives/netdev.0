From: David Miller <davem@davemloft.net>
Subject: Re: skb_shared_info()
Date: Tue, 08 Aug 2006 17:58:39 -0700 (PDT)
Message-ID: <20060808.175839.85396148.davem@davemloft.net>
References: <20060808.163915.03600382.davem@davemloft.net>
	<20060809003616.GC19881@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7613
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030381AbWHIA6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 20:58:49 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060809003616.GC19881@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 9 Aug 2006 10:36:16 +1000

> I'm not sure whether the problem is where we store skb_shared_info,
> or the fact that we can't put kmalloc'ed memory into
> skb_shinfo->frags.

That's a good point.

I guess we could do something like:

struct skb_frag_struct {
	union {
		struct page *page;
		void *data;
	} u;
	__u16 page_offset;
	__u16 size;
};

and something clever like a special page_offset encoding
means "use data, not page".
