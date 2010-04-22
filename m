From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Thu, 22 Apr 2010 17:49:08 +0200
Message-ID: <20100422154908.GA31568@midget.suse.cz>
References: <20100420174401.GB1334@midget.suse.cz>
 <20100421213429.GA2799@midget.suse.cz>
 <20100422023211.GA7109@gondor.apana.org.au>
 <20100422.004324.67422011.davem@davemloft.net>
 <20100422142506.GA15858@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35371 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754701Ab0DVPtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 11:49:11 -0400
Content-Disposition: inline
In-Reply-To: <20100422142506.GA15858@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 10:25:06PM +0800, Herbert Xu wrote:
> This patch fixes this by using the DADFAILED bit to synchronise
> the two paths while holding the ifp lock.  It relies on the fact
> that the TENTATIVE bit is always set during DAD, and that the
> DADFAILED bit is only set on failure.

But the addr_dad_failure()->...->ipv6_del_addr() path will
still race with any other path calling ipv6_del_addr() (e.g. a
manual address removal). Won't it?

I still don't see why __ipv6_ifa_notify() needs to call
dst_free(). Shouldn't that be dst_release() instead, to drop the
reference obtained by dst_hold(&ifp->rt->u.dst)?

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

